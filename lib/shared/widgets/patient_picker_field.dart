import 'package:flutter/material.dart';

import '../../core/helpers/patient_helper.dart';
import '../../features/patients/data/repositories/patient_repository.dart';
import '../../features/patients/models/patient_model.dart';

/// A tappable field that opens a searchable bottom sheet for picking
/// a registered patient. Used by OPD, IPD and Billing forms so a
/// patient never needs to be re-typed once registered.
class PatientPickerField extends StatelessWidget {
  const PatientPickerField({
    super.key,
    required this.selectedPatient,
    required this.onSelected,
    this.enabled = true,
  });

  final PatientModel? selectedPatient;
  final ValueChanged<PatientModel> onSelected;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<PatientModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _PatientPickerSheet(),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = selectedPatient;

    return InkWell(
      onTap: enabled ? () => _openPicker(context) : null,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Patient',
          prefixIcon: Icon(Icons.personal_injury_outlined),
          suffixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        child: Text(
          patient == null
              ? 'Search and select a patient'
              : '${patient.fullName}  (${patient.uhid})',
        ),
      ),
    );
  }
}

class _PatientPickerSheet extends StatefulWidget {
  const _PatientPickerSheet();

  @override
  State<_PatientPickerSheet> createState() => _PatientPickerSheetState();
}

class _PatientPickerSheetState extends State<_PatientPickerSheet> {
  final PatientRepository _repository = PatientRepository.instance;
  final TextEditingController _controller = TextEditingController();

  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load([String query = '']) async {
    setState(() {
      _isLoading = true;
    });

    final result = query.trim().isEmpty
        ? await _repository.getAllPatients()
        : await _repository.searchPatients(query.trim());

    if (!mounted) return;

    setState(() {
      _patients = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          children: [
            Text(
              'Select Patient',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, UHID or mobile...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _load,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _patients.isEmpty
                      ? const Center(child: Text('No patients found'))
                      : ListView.builder(
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            final patient = _patients[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  PatientHelper.getInitials(patient.fullName),
                                ),
                              ),
                              title: Text(patient.fullName),
                              subtitle: Text(
                                'UHID: ${patient.uhid}  •  ${patient.mobile}',
                              ),
                              onTap: () => Navigator.pop(context, patient),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
