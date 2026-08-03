import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../database/database_helper.dart';

/// Result of a completed backup or restore operation.
class BackupResult {
  const BackupResult({required this.success, required this.message, this.path});

  final bool success;
  final String message;
  final String? path;
}

/// A single backup file listed in the app's own backups folder.
class BackupFileInfo {
  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String path;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Backup/Restore kept fully self-contained inside the app's own
/// documents folder — no OS file/folder picker involved. Backups
/// are listed in-app; restoring means picking one from that list,
/// not browsing the filesystem.
class BackupService {
  BackupService._();

  /// Full path to the live app database file on disk.
  static Future<String> getDatabaseFilePath() async {
    final databasePath = await getDatabasesPath();
    return p.join(databasePath, 'aks_medicare_pro.db');
  }

  static Future<Directory> _getBackupsDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(p.join(documentsDir.path, 'aks_medicare_backups'));

    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }

    return backupsDir;
  }

  /// Copies the current database into the app's backups folder,
  /// timestamped so multiple backups never collide.
  static Future<BackupResult> backupDatabase() async {
    final dbPath = await getDatabaseFilePath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      return const BackupResult(
        success: false,
        message: 'Database file not found — nothing to back up yet.',
      );
    }

    try {
      final backupsDir = await _getBackupsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = p.join(backupsDir.path, 'aks_medicare_backup_$timestamp.db');

      await dbFile.copy(backupPath);

      return BackupResult(
        success: true,
        message: 'Backup saved successfully.',
        path: backupPath,
      );
    } catch (e) {
      return BackupResult(success: false, message: 'Backup failed: $e');
    }
  }

  /// Lists all backups in the app's backups folder, most recent first.
  static Future<List<BackupFileInfo>> listBackups() async {
    final backupsDir = await _getBackupsDirectory();

    final files = backupsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();

    final infos = <BackupFileInfo>[];

    for (final file in files) {
      final stat = await file.stat();
      infos.add(
        BackupFileInfo(
          path: file.path,
          fileName: p.basename(file.path),
          createdAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }

    infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return infos;
  }

  /// Replaces the live database with the backup at [backupPath].
  /// The app should be restarted after a successful restore so
  /// every screen re-reads fresh data.
  static Future<BackupResult> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        return const BackupResult(success: false, message: 'Backup file no longer exists.');
      }

      final dbPath = await getDatabaseFilePath();

      // Close the live connection before overwriting the file on disk.
      await DatabaseHelper.instance.closeDatabase();

      await backupFile.copy(dbPath);

      return const BackupResult(
        success: true,
        message: 'Database restored. Please restart the app to load it.',
      );
    } catch (e) {
      return BackupResult(success: false, message: 'Restore failed: $e');
    }
  }

  /// Deletes a backup from the app's backups folder.
  static Future<bool> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
