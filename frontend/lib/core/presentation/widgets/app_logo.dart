import 'package:flutter/material.dart';
import 'package:reallystick/core/presentation/widgets/custom_icons.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CustomIcons.reallystickLogo,
          size: size,
        ),
      ],
    );
  }
}
