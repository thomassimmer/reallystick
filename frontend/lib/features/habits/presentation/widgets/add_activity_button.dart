import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';

class AddActivityButton extends StatelessWidget {
  final void Function() action;
  final Color? color;

  const AddActivityButton({
    required this.action,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FloatingActionButton.extended(
        onPressed: action,
        icon: Icon(
          Icons.add,
        ),
        label: Text(
          AppLocalizations.of(context)!.addActivity,
        ),
        elevation: 4.0,
        backgroundColor: color ?? context.colors.primary,
      ),
    );
  }
}
