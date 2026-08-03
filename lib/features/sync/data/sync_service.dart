import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../../database/database_helper.dart';

/// Per-table import counts.
class TableSyncStats {
  TableSyncStats({this.inserted = 0, this.updated = 0, this.skipped = 0});

  int inserted;
  int updated;
  int skipped;

  @override
  String toString() =>
      'inserted: $inserted, updated: $updated${skipped > 0 ? ', skipped: $skipped' : ''}';
}

/// Full summary of a completed sync-in operation.
class SyncSummary {
  final Map<String, TableSyncStats> tables = {};

  void add(String table, TableSyncStats stats) => tables[table] = stats;

  int get totalInserted => tables.values.fold(0, (sum, s) => sum + s.inserted);
  int get totalUpdated => tables.values.fold(0, (sum, s) => sum + s.updated);
  int get totalSkipped => tables.values.fold(0, (sum, s) => sum + s.skipped);
}

/// LAN Sync over a plain TCP socket.
///
/// This is a deliberately simple, manual-IP, pull-based sync:
/// one device "hosts" (listens for connections and streams its
/// data on request), another device "connects" and pulls that
/// data in. There is no auto-discovery (mDNS) and no two-way
/// merge negotiation — just a one-shot export/import.
///
/// Sync scope is intentionally limited to clinical/operational
/// tables that don't depend on per-device user accounts: user
/// logins, staff profiles and attendance are NOT synced, since
/// their foreign keys point at the Users table, which differs
/// per install. Patients are matched by UHID; dependent records
/// (visits, admissions, bills, lab tests) are matched by their
/// own business number and re-linked to the *local* patient via
/// UHID lookup — their `doctor_id` is cleared on import since a
/// remote user id has no meaning on this device (the doctor's
/// name, which is stored alongside it, is kept).
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  static const List<String> _independentTables = ['patients', 'medicines', 'inventory_items'];

  static const Map<String, String> _dependentTables = {
    'opd_visits': 'visit_no',
    'ipd_admissions': 'admission_no',
    'bills': 'invoice_no',
    'lab_tests': 'test_no',
  };

  ServerSocket? _server;

  final StreamController<String> _logController = StreamController<String>.broadcast();

  /// Stream of human-readable status lines for the Sync screen to display.
  Stream<String> get logs => _logController.stream;

  bool get isHosting => _server != null;

  int? get hostingPort => _server?.port;

  void _log(String message) {
    if (!_logController.isClosed) {
      _logController.add(message);
    }
  }

  // ============================
  // HOST MODE
  // ============================

  Future<int> startHosting({int port = 8888}) async {
    if (_server != null) {
      return _server!.port;
    }

    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _log('Hosting started on port ${_server!.port}.');

    _server!.listen((socket) async {
      final remote = socket.remoteAddress.address;
      _log('Incoming connection from $remote...');

      try {
        final payload = await _exportData();
        final jsonBytes = utf8.encode(jsonEncode(payload));

        socket.add(jsonBytes);
        await socket.flush();

        _log('Sent ${jsonBytes.length} bytes to $remote.');
      } catch (e) {
        _log('Failed to serve $remote: $e');
      } finally {
        await socket.close();
      }
    });

    return _server!.port;
  }

  Future<void> stopHosting() async {
    await _server?.close();
    _server = null;
    _log('Hosting stopped.');
  }

  /// Non-loopback IPv4 addresses of this device, to show the host
  /// which address(es) other devices should connect to.
  static Future<List<String>> getLocalIpAddresses() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      return interfaces.expand((i) => i.addresses).map((a) => a.address).toList();
    } catch (_) {
      return const [];
    }
  }

  // ============================
  // CLIENT MODE
  // ============================

  Future<SyncSummary> connectAndSync({
    required String host,
    required int port,
  }) async {
    _log('Connecting to $host:$port...');

    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    );

    final buffer = BytesBuilder();
    final completer = Completer<void>();

    socket.listen(
      buffer.add,
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      onError: (Object e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      cancelOnError: true,
    );

    await completer.future;
    await socket.close();

    _log('Received ${buffer.length} bytes. Importing...');

    final jsonStr = utf8.decode(buffer.toBytes());
    final payload = jsonDecode(jsonStr) as Map<String, dynamic>;

    final summary = await _importData(payload);

    _log('Sync complete.');

    return summary;
  }

  // ============================
  // EXPORT
  // ============================

  Future<Map<String, dynamic>> _exportData() async {
    final db = await DatabaseHelper.instance.database;
    final tables = <String, dynamic>{};

    for (final table in [..._independentTables, ..._dependentTables.keys]) {
      tables[table] = await db.query(table);
    }

    return {
      'exported_at': DateTime.now().toIso8601String(),
      'tables': tables,
    };
  }

  // ============================
  // IMPORT
  // ============================

  Future<SyncSummary> _importData(Map<String, dynamic> payload) async {
    final db = await DatabaseHelper.instance.database;
    final tables = payload['tables'] as Map<String, dynamic>? ?? {};
    final summary = SyncSummary();

    // Patients must be imported first — dependent tables resolve
    // their local patient_id via UHID lookup below.
    if (tables['patients'] is List) {
      summary.add(
        'patients',
        await _upsertIndependent(db, 'patients', tables['patients'] as List, matchColumn: 'uhid'),
      );
    }

    if (tables['medicines'] is List) {
      summary.add(
        'medicines',
        await _upsertIndependent(
          db,
          'medicines',
          tables['medicines'] as List,
          matchColumn: 'name',
          caseInsensitive: true,
        ),
      );
    }

    if (tables['inventory_items'] is List) {
      summary.add(
        'inventory_items',
        await _upsertIndependent(
          db,
          'inventory_items',
          tables['inventory_items'] as List,
          matchColumn: 'serial_number',
        ),
      );
    }

    for (final entry in _dependentTables.entries) {
      final rows = tables[entry.key];
      if (rows is List) {
        summary.add(entry.key, await _upsertDependent(db, entry.key, rows, matchColumn: entry.value));
      }
    }

    return summary;
  }

  /// Upserts rows for a table that doesn't reference other synced
  /// tables. Matches on [matchColumn]; updates in place if a local
  /// row with the same value exists, otherwise inserts a new row
  /// (so the local autoincrement id is used, never the remote one).
  Future<TableSyncStats> _upsertIndependent(
    Database db,
    String table,
    List<dynamic> rows, {
    required String matchColumn,
    bool caseInsensitive = false,
  }) async {
    final stats = TableSyncStats();

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      row.remove('id');

      final matchValue = row[matchColumn];

      List<Map<String, dynamic>> existing = const [];

      if (matchValue != null) {
        existing = caseInsensitive
            ? await db.query(
                table,
                where: 'LOWER($matchColumn) = LOWER(?)',
                whereArgs: [matchValue],
                limit: 1,
              )
            : await db.query(
                table,
                where: '$matchColumn = ?',
                whereArgs: [matchValue],
                limit: 1,
              );
      }

      if (existing.isNotEmpty) {
        await db.update(table, row, where: 'id = ?', whereArgs: [existing.first['id']]);
        stats.updated++;
      } else {
        await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
        stats.inserted++;
      }
    }

    return stats;
  }

  /// Upserts rows for a table that references a patient (and,
  /// historically, a doctor user). The row's `patient_uhid` is used
  /// to resolve the correct *local* `patient_id`; rows whose patient
  /// isn't present locally are skipped rather than imported with a
  /// dangling reference. `doctor_id` is cleared since remote user
  /// ids don't correspond to anything on this device — `doctor_name`
  /// is kept as-is for display.
  Future<TableSyncStats> _upsertDependent(
    Database db,
    String table,
    List<dynamic> rows, {
    required String matchColumn,
  }) async {
    final stats = TableSyncStats();

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final uhid = row['patient_uhid'] as String?;

      if (uhid == null || uhid.isEmpty) {
        stats.skipped++;
        continue;
      }

      final patientMatch = await db.query(
        'patients',
        columns: ['id'],
        where: 'uhid = ?',
        whereArgs: [uhid],
        limit: 1,
      );

      if (patientMatch.isEmpty) {
        stats.skipped++;
        continue;
      }

      row['patient_id'] = patientMatch.first['id'];
      row['doctor_id'] = null;
      row.remove('id');

      final matchValue = row[matchColumn];

      final existing = matchValue == null
          ? const <Map<String, dynamic>>[]
          : await db.query(table, where: '$matchColumn = ?', whereArgs: [matchValue], limit: 1);

      if (existing.isNotEmpty) {
        await db.update(table, row, where: 'id = ?', whereArgs: [existing.first['id']]);
        stats.updated++;
      } else {
        await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
        stats.inserted++;
      }
    }

    return stats;
  }
}
