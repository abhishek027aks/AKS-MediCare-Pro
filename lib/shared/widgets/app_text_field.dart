import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ===============================================================
/// AppTextField
/// ---------------------------------------------------------------
/// Reusable Material 3 TextFormField
///
/// Features:
/// • Validation
/// • Password Visibility
/// • Read Only
/// • Prefix/Suffix Icon
/// • Multi-line
/// • Keyboard Types
/// • Input Formatter
/// • Character Limit
/// • Theme Aware
/// • Material 3
/// ===============================================================
class AppTextField extends StatefulWidget {
  final TextEditingController controller;

  final String label;

  final String? hint;

  final IconData? prefixIcon;

  final Widget? suffix;

  final TextInputType keyboardType;

  final bool readOnly;

  final bool enabled;

  final bool obscureText;

  final int maxLines;

  final int? maxLength;

  final String? Function(String?)? validator;

  final VoidCallback? onTap;

  final ValueChanged<String>? onChanged;

  final List<TextInputFormatter>? inputFormatters;

  final TextInputAction textInputAction;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidePassword;

  @override
  void initState() {
    super.initState();
    _hidePassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      obscureText: _hidePassword,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,

        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon),

        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              )
            : widget.suffix,

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
    );
  }
}