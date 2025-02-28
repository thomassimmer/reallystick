import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
