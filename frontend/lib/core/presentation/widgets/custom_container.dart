import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;

  const CustomContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border.all(width: 1.5, color: context.colors.primary),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
