import 'package:flutter/material.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  SliverAppBarDelegate({required this.title});

  @override
  double get minExtent => 50; // Minimum height of the header
  @override
  double get maxExtent => 50; // Maximum height of the header

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
