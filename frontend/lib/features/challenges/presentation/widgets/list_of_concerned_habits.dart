import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/widgets/habit_card_widget.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ListOfConcernedHabits extends StatelessWidget {
  final Color challengeColor;
  final String challengeId;
  final bool previewMode;

  const ListOfConcernedHabits({
    required this.challengeColor,
    required this.challengeId,
    required this.previewMode,
  });

  @override
  Widget build(BuildContext context) {
    final profileState = previewMode
        ? getProfileAuthenticatedForPreview(context)
        : context.watch<ProfileBloc>().state;
    final challengeState = previewMode
        ? getChallengeStateForPreview(context)
        : context.watch<ChallengeBloc>().state;
    final habitState = previewMode
        ? getHabitsLoadedForPreview(context)
        : context.watch<HabitBloc>().state;

    if (challengeState is ChallengesLoaded &&
        profileState is ProfileAuthenticated &&
        habitState is HabitsLoaded) {
      final userLocale = profileState.profile.locale;
      final challengeDailyTrackings =
          challengeState.challengeDailyTrackings[challengeId] ?? [];
      final habitIds =
          Set.from(challengeDailyTrackings.map((cdt) => cdt.habitId));
      final habits = habitIds
          .map((habitId) => habitState.habits[habitId])
          .where((h) => h != null)
          .toList();

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list,
                size: 20,
                color: challengeColor,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.habitsConcerned,
                style: TextStyle(
                  fontSize: 20,
                  color: challengeColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (habits.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: habits.map((habit) {
                  return HabitCardWidget(
                    habit: habit!,
                    userLocale: userLocale,
                    color: challengeColor,
                    hasParticipation: habitState.habitParticipations
                        .where((hp) => hp.habitId == habit.id)
                        .isNotEmpty,
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            Text(AppLocalizations.of(context)!.noConcernedHabitsYet),
          ]
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(challengeColor),
        ),
      );
    }
  }
}
