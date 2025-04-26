import 'package:flutter/material.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class MessageDeletedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        height: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Text(
              AppLocalizations.of(context)!.messageDeletedError,
              textAlign: TextAlign.left,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
