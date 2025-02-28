import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/widgets/habit_card_widget.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ListOfConcernedHabits extends StatelessWidget {
  final Color challengeColor;
  final String challengeId;

  const ListOfConcernedHabits({
    required this.challengeColor,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    final challengeState = context.watch<ChallengeBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

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
                size: 30,
                color: challengeColor,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.habitsConcerned,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
