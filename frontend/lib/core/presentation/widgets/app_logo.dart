import 'package:flutter/material.dart';

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
        Image.asset(
          'assets/images/reallystick_logo.png',
          width: size,
        ),
        
      ],
    );
  }
}
