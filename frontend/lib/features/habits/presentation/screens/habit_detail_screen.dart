import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/widgets/analytics_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/challenges_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/habit_discussion_list_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class HabitDetailsScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailsScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  HabitDetailsScreenState createState() => HabitDetailsScreenState();
}

class HabitDetailsScreenState extends State<HabitDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final habitState = context.watch<HabitBloc>().state;

        if (profileState is ProfileAuthenticated &&
            habitState is HabitsLoaded) {
          final userLocale = profileState.profile.locale;

          final habit = habitState.habits[widget.habitId]!;
          final habitParticipation = habitState.habitParticipations
              .where((hp) => hp.habitId == widget.habitId)
              .firstOrNull;
          final habitDailyTrackings = habitState.habitDailyTrackings
              .where((hdt) => hdt.habitId == widget.habitId)
              .toList();

          final shortName = getRightTranslationFromJson(
            habit.shortName,
            userLocale,
          );

          final longName = getRightTranslationFromJson(
            habit.longName,
            userLocale,
          );

          final description = getRightTranslationFromJson(
            habit.description,
            userLocale,
          );

          final bool isLargeScreen = checkIfLargeScreen(context);
          final habitColor = getAppColorsFromString(
              habitParticipation != null ? habitParticipation.color : "");

          return Scaffold(
            appBar: AppBar(
              titleTextStyle: context.typographies.heading,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: getIconWidget(
                      iconString: habit.icon,
                      size: 30,
                      color: habitColor,
                    ),
                  ),
                  SelectableText(
                    isLargeScreen ? longName : shortName,
                    style: TextStyle(
                        color: habitColor, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: habitColor.withAlpha(105),
                        border: Border.all(width: 1, color: habitColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SelectableText(description),
                      ),
                    ),
                    AnalyticsCarouselWidget(),
                    if (habitDailyTrackings.isNotEmpty)
                      DailyTrackingCarouselWidget(
                        habitDailyTrackings: habitDailyTrackings,
                        habitColor: habitColor,
                      ),
                    ChallengesCarouselWidget(),
                    HabitDiscussionListWidget(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
