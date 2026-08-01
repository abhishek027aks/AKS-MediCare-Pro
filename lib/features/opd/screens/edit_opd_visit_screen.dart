import 'package:flutter/material.dart';

import '../data/repositories/opd_repository.dart';
import '../models/opd_visit_model.dart';
import '../widgets/opd_visit_form.dart';

class EditOpdVisitScreen extends StatefulWidget {
  const EditOpdVisitScreen({super.key, required this.visit});

  final OpdVisitModel visit;

  @override
  State<EditOpdVisitScreen> createState() => _EditOpdVisitScreenState();
}

class _EditOpdVisitScreenState extends State<EditOpdVisitScreen> {
  final OpdRepository _repository = OpdRepository.instance;
  bool _isLoading = false;

  Future<void> _saveVisit(OpdVisitModel visit) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateVisit(visit);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes were saved.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit OPD Visit'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: OpdVisitForm(
            initialVisit: widget.visit,
            isLoading: _isLoading,
            onSave: _saveVisit,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
