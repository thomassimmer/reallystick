import 'package:flutter/material.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class MessageNotFoundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context)!.messageNotFoundError,
        textAlign: TextAlign.center,
      ),
    );
  }
}
