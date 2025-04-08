import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class CustomElevatedButtonFormField extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? iconData;
  final String label;
  final String? errorText;
  final Color? buttonColor;
  final double? labelSize;

  CustomElevatedButtonFormField({
    required this.onPressed,
    this.iconData,
    required this.label,
    this.errorText,
    this.buttonColor,
    this.labelSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: iconData != null
              ? Icon(
                  iconData,
                  color: context.colors.text,
                )
              : null,
          label: Text(
            label,
            style: context.typographies.bodySmall.copyWith(
              color: context.colors.text,
              fontSize: labelSize,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor ?? context.colors.backgroundDark,
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: errorText != null
                    ? context.colors.alert
                    : context.colors.primary,
                width: 1.0,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
            child: Text(
              errorText!,
              style: TextStyle(
                color: context.colors.error,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
