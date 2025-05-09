import 'package:flutter/material.dart';

class FullWidthListView extends StatelessWidget {
  final List<Widget> children;
  final double maxContentWidth;
  final ScrollController? controller;
  final bool reverse;

  const FullWidthListView({
    super.key,
    required this.children,
    this.controller,
    this.maxContentWidth = 700, // Set max width for content
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the horizontal padding needed to center content
        double horizontalPadding = (constraints.maxWidth > maxContentWidth)
            ? (constraints.maxWidth - maxContentWidth) / 2
            : 16;

        final childrenInTheRightOrder = reverse ? children.reversed : children;

        return ListView(
          controller: controller,
          reverse: reverse,
          children: childrenInTheRightOrder.map((child) {
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
