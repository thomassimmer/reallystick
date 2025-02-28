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
    return FloatingActionButton.extended(
      onPressed: action,
      icon: Icon(Icons.add),
      label: Text(AppLocalizations.of(context)!.addActivity),
      backgroundColor: color ?? context.colors.primary,
      extendedTextStyle: TextStyle(letterSpacing: 1, fontFamily: 'Montserrat'),
    );
  }
}
