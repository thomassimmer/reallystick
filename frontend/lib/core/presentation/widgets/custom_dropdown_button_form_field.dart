import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class CustomDropdownButtonFormField extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String?>? onChanged;

  CustomDropdownButtonFormField({
    required this.value,
    required this.items,
    this.label,
    this.hint,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorMaxLines: 10,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: context.colors.secondary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: context.colors.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: context.colors.alert,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: context.colors.error,
          ),
        ),
        errorText: errorText,
      ),
      validator: validator,
    );
  }
}
