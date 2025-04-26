import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class UserIsNotChallengeCreatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.addNewChallenge,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .youAreNotTheCreatorOfThisChallenge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.goNamed('challenges'),
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.comeBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
