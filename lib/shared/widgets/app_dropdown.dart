import 'package:flutter/material.dart';

/// ===============================================================
/// Generic Material 3 Dropdown Widget
/// ===============================================================
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabelBuilder,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHint = hint ?? 'Select $label';

    return DropdownButtonFormField<T>(
      // Use 'value' instead of 'initialValue' for controlled state updates
      initialValue: value,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      
      // 1. Menu popup height limit (Prevents full-screen overflow on long lists)
      menuMaxHeight: 300,
      
      // 2. Material 3 rounded corners for popup menu
      borderRadius: BorderRadius.circular(12),
      
      // Secondary disabled state UX
      disabledHint: Text(
        effectiveHint,
        style: TextStyle(color: theme.disabledColor),
      ),
      
      decoration: InputDecoration(
        labelText: label,
        // 3. Fallback hint text automatically generates 'Select [Label]'
        hintText: effectiveHint,
        filled: true,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
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
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabelBuilder(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}