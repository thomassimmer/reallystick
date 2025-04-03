import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';

class HabitCardWidget extends StatelessWidget {
  final Habit habit;
  final String userLocale;
  final Color color;
  final bool hasParticipation;

  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.userLocale,
    required this.color,
    required this.hasParticipation,
  });

  @override
  Widget build(BuildContext context) {
    void startTrackingThisHabit() {
      final createHabitParticipationEvent = CreateHabitParticipationEvent(
        habitId: habit.id,
      );
      context.read<HabitBloc>().add(createHabitParticipationEvent);
    }

    return Container(
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.goNamed(
            'habitDetails',
            pathParameters: {'habitId': habit.id},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withAlpha(100),
                color.withBlue(100).withAlpha(100)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(habit.icon, style: TextStyle(fontSize: 25)),
                    SizedBox(width: 10),
                    Text(
                      getRightTranslationFromJson(
                        habit.name,
                        userLocale,
                      ),
                      style: TextStyle(
                        color: context.colors.text,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    if (hasParticipation) ...[
                      Icon(
                        Icons.check_box,
                        color: context.colors.text,
                      ),
                    ] else ...[
                      MaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        height: 10,
                        padding: EdgeInsets.all(5),
                        color: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textColor: context.colors.textOnPrimary,
                        onPressed: () {
                          startTrackingThisHabit();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.startHabitShort,
                          style: context.typographies.captionSmall,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
