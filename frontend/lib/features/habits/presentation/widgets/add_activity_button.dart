import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class AddActivityButton extends StatelessWidget {
  final void Function() action;
  final Color? color;
  final String label;

  const AddActivityButton({
    required this.action,
    this.color,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: action,
      icon: Icon(Icons.add),
      label: Text(label),
      backgroundColor: color ?? context.colors.primary,
      extendedTextStyle: TextStyle(letterSpacing: 1, fontFamily: 'Montserrat'),
    );
  }
}
