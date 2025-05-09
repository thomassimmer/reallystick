import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FullWidthPositionnedListView extends StatelessWidget {
  final List<Widget> children;
  final double maxContentWidth;
  final ItemScrollController? itemScrollController;
  final ItemPositionsListener? itemPositionsListener;
  final ScrollOffsetListener? scrollOffsetListener;

  const FullWidthPositionnedListView({
    super.key,
    required this.children,
    this.itemScrollController,
    this.itemPositionsListener,
    this.scrollOffsetListener,
    this.maxContentWidth = 700, // Set max width for content
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the horizontal padding needed to center content
        double horizontalPadding = (constraints.maxWidth > maxContentWidth)
            ? (constraints.maxWidth - maxContentWidth) / 2
            : 16;

        return ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            scrollOffsetListener: scrollOffsetListener,
            reverse: false, // or true if your messages list is reversed
            itemCount: children.length,
            initialScrollIndex: children.length - 1,
            itemBuilder: (context, index) {
              // Wrap each child with padding to apply max width constraint
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: children[index],
              );
            });
      },
    );
  }
}
