import 'package:flutter/material.dart';

class FullWidthColumn extends StatelessWidget {
  final List<Widget> children;
  final double maxContentWidth;

  const FullWidthColumn({
    Key? key,
    required this.children,
    this.maxContentWidth = 700,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalPadding = (constraints.maxWidth > maxContentWidth)
            ? (constraints.maxWidth - maxContentWidth) / 2
            : 16;

        return Column(
          children: children.map((child) {
            if (child is Expanded) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: child.child,
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: child,
              );
            }
          }).toList(),
        );
      },
    );
  }
}
