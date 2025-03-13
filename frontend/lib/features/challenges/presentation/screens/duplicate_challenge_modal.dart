import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';

class DuplicateChallengeModal extends StatelessWidget {
  final String challengeId;

  const DuplicateChallengeModal({
    super.key,
    required this.challengeId,
  });

  void duplicateChallenge(BuildContext context) {
    context
        .read<ChallengeBloc>()
        .add(DuplicateChallengeEvent(challengeId: challengeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengesLoaded && state.message is SuccessMessage) {
          final message = state.message as SuccessMessage;

          if (message.messageKey == "challengeDuplicated") {
            final newChallenge = state.newlyCreatedChallenge;

            if (newChallenge != null) {
              context.pushNamed(
                'challengeDetails',
                pathParameters: {'challengeId': newChallenge.id},
              );
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.duplicateChallenge,
                        textAlign: TextAlign.center,
                        style: context.typographies.headingSmall,
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.confirmDuplicateChallenge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => duplicateChallenge(context),
                        child: Text(AppLocalizations.of(context)!.duplicate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
