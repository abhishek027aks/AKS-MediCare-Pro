import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/id_helper.dart';
import '../../../shared/widgets/unsaved_changes_guard.dart';
import '../../patients/models/patient_model.dart';
import '../data/repositories/opd_repository.dart';
import '../models/opd_visit_model.dart';
import '../widgets/opd_visit_form.dart';

class AddOpdVisitScreen extends ConsumerStatefulWidget {
  const AddOpdVisitScreen({
    super.key,
    this.prefillPatient,
    this.prefillDoctorId,
    this.prefillDoctorName,
  });

  /// Lets another module (e.g. Appointments "Check In") hand off
  /// directly into a pre-populated OPD visit.
  final PatientModel? prefillPatient;
  final int? prefillDoctorId;
  final String? prefillDoctorName;

  @override
  ConsumerState<AddOpdVisitScreen> createState() => _AddOpdVisitScreenState();
}

class _AddOpdVisitScreenState extends ConsumerState<AddOpdVisitScreen> {
  bool _isSaving = false;
  bool _hasInteracted = false;

  Future<void> _saveVisit(OpdVisitModel visit) async {
    setState(() => _isSaving = true);

    try {
      final visitNo = await IdHelper.generateVisitNumber();

      await OpdRepository.instance.createVisit(visit.copyWith(visitNo: visitNo));

      if (!mounted) return;

      _hasInteracted = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Visit created successfully. Visit No: $visitNo'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New OPD Visit'), centerTitle: true),
      body: UnsavedChangesGuard(
        hasUnsavedChanges: () => _hasInteracted && !_isSaving,
        child: SafeArea(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (!_hasInteracted) setState(() => _hasInteracted = true);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: OpdVisitForm(
                onSave: _saveVisit,
                isLoading: _isSaving,
                onCancel: () => Navigator.pop(context),
                prefillPatient: widget.prefillPatient,
                prefillDoctorId: widget.prefillDoctorId,
                prefillDoctorName: widget.prefillDoctorName,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
