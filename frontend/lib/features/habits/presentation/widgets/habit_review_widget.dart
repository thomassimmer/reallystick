import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class HabitReviewWidget extends StatelessWidget {
  final Habit habit;

  const HabitReviewWidget({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final userLocale = profileState.profile!.locale;

        final shortName = getRightTranslationFromJson(
          habit.shortName,
          userLocale,
        );

        final longName = getRightTranslationFromJson(
          habit.longName,
          userLocale,
        );

        // Define screen size breakpoint
        final bool isLargeScreen = checkIfLargeScreen(context);

        return InkWell(
          onTap: () {
            context.pushNamed(
              'reviewHabit',
              pathParameters: {'habitId': habit.id},
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Habit icon
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: getIconWidget(
                          iconString: habit.icon,
                          size: 30,
                          color: context.colors.text,
                        ),
                      ),

                      // Short or Long name based on screen size
                      Expanded(
                        child: Text(
                          isLargeScreen ? longName : shortName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
