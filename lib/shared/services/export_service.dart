import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Result of a completed export.
class ExportResult {
  const ExportResult({required this.success, required this.message, this.path});

  final bool success;
  final String message;
  final String? path;
}

/// Exports tabular data to CSV or Excel, saved into the app's own
/// documents folder (same approach as Backup) — deliberately not
/// using an OS save-file picker, since that package proved unreliable
/// in this environment previously.
class ExportService {
  ExportService._();

  static Future<Directory> _getExportsDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(documentsDir.path, 'aks_medicare_exports'));

    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    return exportsDir;
  }

  static String _timestampedFilename(String baseName, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${baseName}_$timestamp.$extension';
  }

  /// Escapes a single CSV field per RFC 4180: wrap in quotes if it
  /// contains a comma, quote, or newline, doubling any inner quotes.
  static String _csvField(dynamic value) {
    final text = value?.toString() ?? '';

    if (text.contains(',') || text.contains('"') || text.contains('\n') || text.contains('\r')) {
      return '"${text.replaceAll('"', '""')}"';
    }

    return text;
  }

  static String _csvRow(List<dynamic> values) {
    return values.map(_csvField).join(',');
  }

  /// [headers] are the column titles; [rows] are the data rows, each
  /// row's values in the same order as [headers].
  static Future<ExportResult> exportToCsv({
    required String baseName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    try {
      final lines = [
        _csvRow(headers),
        ...rows.map(_csvRow),
      ];

      // CRLF line endings — the conventional choice for CSV and what
      // Excel expects when opening the file directly.
      final csvData = lines.join('\r\n');

      final exportsDir = await _getExportsDirectory();
      final filePath = p.join(exportsDir.path, _timestampedFilename(baseName, 'csv'));

      await File(filePath).writeAsString(csvData);

      return ExportResult(success: true, message: 'CSV exported successfully.', path: filePath);
    } catch (e) {
      return ExportResult(success: false, message: 'Export failed: $e');
    }
  }

  static Future<ExportResult> exportToExcel({
    required String baseName,
    required String sheetName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    try {
      final workbook = Excel.createExcel();
      final sheet = workbook[sheetName];

      // Excel's default sheet is named "Sheet1" — rename/remove it if
      // it isn't the one we're using, so the file doesn't carry an
      // empty extra tab.
      if (workbook.sheets.keys.contains('Sheet1') && sheetName != 'Sheet1') {
        workbook.delete('Sheet1');
      }

      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      for (final row in rows) {
        sheet.appendRow(row.map((value) => TextCellValue(value?.toString() ?? '')).toList());
      }

      final bytes = workbook.save();

      if (bytes == null) {
        return const ExportResult(success: false, message: 'Failed to generate Excel file.');
      }

      final exportsDir = await _getExportsDirectory();
      final filePath = p.join(exportsDir.path, _timestampedFilename(baseName, 'xlsx'));

      await File(filePath).writeAsBytes(bytes);

      return ExportResult(success: true, message: 'Excel file exported successfully.', path: filePath);
    } catch (e) {
      return ExportResult(success: false, message: 'Export failed: $e');
    }
  }
}
