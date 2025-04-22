import 'package:flutter/material.dart';
import 'package:reallystick/core/presentation/screens/root_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/habits_screen.dart';

class HabitsScreenScreenshot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RootScreen(
                      previewMode: true,
                      previewTab: 0,
                      child: HabitsScreen(
                        previewMode: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
