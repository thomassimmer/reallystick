import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class FinishChallengeModal extends StatelessWidget {
  final String challengeId;
  final ChallengeParticipation challengeParticipation;

  const FinishChallengeModal({
    super.key,
    required this.challengeId,
    required this.challengeParticipation,
  });

  void markChallengeAsFinished(BuildContext context) {
    context.read<ChallengeBloc>().add(
          UpdateChallengeParticipationEvent(
            challengeParticipationId: challengeParticipation.id,
            color: challengeParticipation.color,
            startDate: challengeParticipation.startDate,
            notificationsReminderEnabled:
                challengeParticipation.notificationsReminderEnabled,
            reminderTime: challengeParticipation.reminderTime,
            reminderBody: challengeParticipation.reminderBody,
            finished: true,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Wrap(
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.challengeFinished,
                  textAlign: TextAlign.center,
                  style: context.typographies.headingSmall,
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.markChallengeAsFinished,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => markChallengeAsFinished(context),
                  child: Text(AppLocalizations.of(context)!.finished),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
