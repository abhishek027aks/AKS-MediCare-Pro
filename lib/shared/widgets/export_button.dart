import 'package:flutter/material.dart';

import '../services/export_service.dart';

/// A reusable "Export" icon button for list screens — offers CSV or
/// Excel, runs the export, and shows the resulting file path (saved
/// under the app's own documents folder, see [ExportService]).
class ExportButton extends StatefulWidget {
  const ExportButton({
    super.key,
    required this.baseName,
    required this.sheetName,
    required this.headers,
    required this.rowsBuilder,
  });

  /// Used as the file name prefix, e.g. "patients" -> patients_20260804_1200.csv
  final String baseName;

  /// Excel sheet tab name.
  final String sheetName;

  final List<String> headers;

  /// Computed lazily at export time, so the button always exports
  /// whatever is currently visible/filtered in the list, not a
  /// stale snapshot from when the button was built.
  final List<List<dynamic>> Function() rowsBuilder;

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _isExporting = false;

  Future<void> _export(bool asExcel) async {
    final rows = widget.rowsBuilder();

    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    final result = asExcel
        ? await ExportService.exportToExcel(
            baseName: widget.baseName,
            sheetName: widget.sheetName,
            headers: widget.headers,
            rows: rows,
          )
        : await ExportService.exportToCsv(
            baseName: widget.baseName,
            headers: widget.headers,
            rows: rows,
          );

    if (!mounted) return;
    setState(() => _isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.path == null ? result.message : '${result.message}\n${result.path}'),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isExporting) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.file_download_outlined),
      tooltip: 'Export',
      onSelected: (value) => _export(value == 'excel'),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
        PopupMenuItem(value: 'excel', child: Text('Export as Excel')),
      ],
    );
  }
}
