import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class AddActivityButton extends StatelessWidget {
  final void Function() action;
  final Color? color;
  final String? label;

  const AddActivityButton({
    required this.action,
    this.color,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: action,
        icon: Icon(Icons.add),
        label: Text(label!),
        backgroundColor: color ?? context.colors.primary,
        extendedTextStyle:
            TextStyle(letterSpacing: 0.7, fontFamily: 'Montserrat'),
      );
    }

    return FloatingActionButton(
      onPressed: action,
      backgroundColor: color ?? context.colors.primary,
      child: const Icon(Icons.add),
    );
  }
}
