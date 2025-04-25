import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String labelText;
  final String text;

  const CustomTextButton({
    required this.onPressed,
    required this.labelText,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    return TextButton(
      style: context.appTheme.themeData.textButtonTheme.style?.copyWith(
        padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
      ),
      onPressed: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: context.colors.backgroundDark,
          errorMaxLines: 10,
          enabled: !isDisabled,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: context.colors.secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: context.colors.primary),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: context.colors.hint),
          ),
        ),
        child: Text(
          text,
          style: context.typographies.body.copyWith(
            color: isDisabled ? context.colors.hint : context.colors.text,
          ),
        ),
      ),
    );
  }
}
