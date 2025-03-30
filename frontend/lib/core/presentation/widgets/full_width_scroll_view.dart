import 'package:flutter/material.dart';

class FullWidthScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final double maxContentWidth;

  const FullWidthScrollView({
    super.key,
    required this.slivers,
    this.maxContentWidth = 700, // Max width constraint for content
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          slivers: slivers.map((sliver) {
            if (sliver is SliverPersistentHeader) {
              return sliver; // Do NOT apply width constraint to these!
            } else {
              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: (constraints.maxWidth > maxContentWidth)
                      ? (constraints.maxWidth - maxContentWidth) / 2
                      : 0,
                ),
                sliver: sliver,
              );
            }
          }).toList(),
        );
      },
    );
  }
}
