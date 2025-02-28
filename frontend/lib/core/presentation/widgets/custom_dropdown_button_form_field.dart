import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class CustomDropdownButtonFormField extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final String label;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String?>? onChanged;

  CustomDropdownButtonFormField({
    required this.value,
    required this.items,
    required this.label,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
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
      ),
    );
  }
}
