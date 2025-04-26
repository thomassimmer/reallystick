import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class HabitNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.habitNotFoundError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.goNamed('habits'),
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
