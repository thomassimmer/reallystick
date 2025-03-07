import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool? centerTitle;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    this.title,
    this.centerTitle,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: AppBar(
            title: title,
            centerTitle: centerTitle,
            actions: actions,
            backgroundColor: Colors.transparent, // Prevent duplicate background
            elevation: 0,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
