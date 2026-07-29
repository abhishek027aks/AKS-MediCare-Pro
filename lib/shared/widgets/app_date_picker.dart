import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ===============================================================
/// AppDatePicker
/// ---------------------------------------------------------------
/// Reusable Material 3 Date Picker
///
/// Features:
/// • Material 3
/// • Read Only Field
/// • Date Picker Dialog
/// • Validation
/// • Min/Max Date
/// • Custom Date Format
/// • Theme Aware
/// ===============================================================
class AppDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  final DateTime? firstDate;
  final DateTime? lastDate;

  final String dateFormat;

  final IconData? prefixIcon;

  final bool enabled;

  final String? Function(DateTime?)? validator;

  const AppDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'dd/MM/yyyy',
    this.prefixIcon,
    this.enabled = true,
    this.validator,
  });

  Future<void> _pickDate(BuildContext context) async {
    if (!enabled) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final controller = TextEditingController(
      text: selectedDate == null
          ? ''
          : DateFormat(dateFormat).format(selectedDate!),
    );

    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              readOnly: true,
              enabled: enabled,
              onTap: () => _pickDate(context),
              decoration: InputDecoration(
                labelText: label,

                prefixIcon: Icon(
                  prefixIcon ?? Icons.calendar_month,
                ),

                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                ),

                errorText: state.errorText,

                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                  ),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}