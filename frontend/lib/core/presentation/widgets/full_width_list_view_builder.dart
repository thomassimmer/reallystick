import 'package:flutter/material.dart';

class FullWidthListViewBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double maxContentWidth;
  final EdgeInsets padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const FullWidthListViewBuilder({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.maxContentWidth = 700, // Set max width for content
    this.padding = EdgeInsets.zero, // Optional global padding
    this.controller, // Scroll controller
    this.physics, // Scroll physics
    this.shrinkWrap = false, // Default behavior
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate horizontal padding to center content
        double horizontalPadding = (constraints.maxWidth > maxContentWidth)
            ? (constraints.maxWidth - maxContentWidth) / 2
            : 16;

        return ListView.builder(
          controller: controller,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding, // Apply any additional padding
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: itemBuilder(context, index),
            );
          },
        );
      },
    );
  }
}
