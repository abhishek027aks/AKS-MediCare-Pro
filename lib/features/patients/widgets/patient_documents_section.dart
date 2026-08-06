import 'package:flutter/material.dart';

import '../../../core/helpers/date_helper.dart';
import '../../../shared/services/patient_media_service.dart';
import '../data/repositories/patient_document_repository.dart';
import '../models/patient_document_model.dart';

/// A self-contained "Documents" card for the Patient Details screen —
/// manages its own loading state so it can be dropped into the
/// existing (stateless) screen without restructuring it.
class PatientDocumentsSection extends StatefulWidget {
  const PatientDocumentsSection({super.key, required this.patientId});

  final int patientId;

  @override
  State<PatientDocumentsSection> createState() => _PatientDocumentsSectionState();
}

class _PatientDocumentsSectionState extends State<PatientDocumentsSection> {
  final PatientDocumentRepository _repository = PatientDocumentRepository.instance;

  List<PatientDocumentModel> _documents = [];
  bool _isLoading = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final documents = await _repository.getDocumentsForPatient(widget.patientId);
    if (!mounted) return;
    setState(() {
      _documents = documents;
      _isLoading = false;
    });
  }

  Future<void> _addDocument() async {
    final path = await PatientMediaService.pickAndSaveImage(filePrefix: 'document');
    if (path == null) return;
    if (!mounted) return;

    final nameController = TextEditingController(text: 'Document');

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'e.g. Aadhaar Card, Insurance Card',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    setState(() => _isBusy = true);

    await _repository.addDocument(
      PatientDocumentModel(
        patientId: widget.patientId,
        filePath: path,
        documentName: name,
        uploadedAt: DateTime.now(),
      ),
    );

    await _load();
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _deleteDocument(PatientDocumentModel document) async {
    if (document.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Remove "${document.documentName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _repository.deleteDocument(document.id!);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Documents', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: _isBusy ? null : _addDocument,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              )
            else if (_documents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No documents attached yet.'),
              )
            else
              ..._documents.map(
                (doc) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(doc.documentName),
                  subtitle: Text(AppDateHelper.formatDateTime(doc.uploadedAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteDocument(doc),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
