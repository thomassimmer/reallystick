import 'package:flutter/material.dart';

const verticalPadding = 16.0;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool? centerTitle;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.centerTitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Center(
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(vertical: verticalPadding),
          constraints: const BoxConstraints(maxWidth: 700),
          child: AppBar(
            title: title != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: title,
                  )
                : null,
            centerTitle: centerTitle,
            actions: actions
                ?.map((action) => Align(
                      alignment: Alignment.centerRight,
                      child: action,
                    ))
                .toList(),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + verticalPadding * 2);
}
