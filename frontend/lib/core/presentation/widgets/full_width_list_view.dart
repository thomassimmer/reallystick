import 'package:flutter/material.dart';

class FullWidthListView extends StatelessWidget {
  final List<Widget> children;
  final double maxContentWidth;

  const FullWidthListView({
    Key? key,
    required this.children,
    this.maxContentWidth = 700, // Set max width for content
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the horizontal padding needed to center content
        double horizontalPadding = (constraints.maxWidth > maxContentWidth)
            ? (constraints.maxWidth - maxContentWidth) / 2
            : 16;

        return ListView(
          children: children.map((child) {
            // Wrap each child with padding to apply max width constraint
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}