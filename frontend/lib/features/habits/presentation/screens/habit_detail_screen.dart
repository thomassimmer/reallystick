import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/habits/presentation/screens/color_picker_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/add_activity_button.dart';
import 'package:reallystick/features/habits/presentation/widgets/analytics_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/challenges_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/discussion_list_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class HabitDetailsScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailsScreen({
    Key? key,
    required this.habitId,
  }) : super(key: key);

  @override
  HabitDetailsScreenState createState() => HabitDetailsScreenState();
}

class HabitDetailsScreenState extends State<HabitDetailsScreen> {
  void _showAddDailyTrackingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [AddDailyTrackingModal(habitId: widget.habitId)],
          ),
        );
      },
    );
  }

  void _quitHabit(String habitParticipationId) {
    final deleteHabitParticipationEvent = DeleteHabitParticipationEvent(
      habitParticipationId: habitParticipationId,
    );
    context.read<HabitBloc>().add(deleteHabitParticipationEvent);
  }

  void _openColorPicker(String habitParticipationId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return ColorPickerModal(
          onColorSelected: (selectedColor) {
            final updateHabitParticipationEvent = UpdateHabitParticipationEvent(
              habitParticipationId: habitParticipationId,
              color: selectedColor.toShortString(),
            );
            context.read<HabitBloc>().add(updateHabitParticipationEvent);

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _startTrackingThisHabit() {
    final createHabitParticipationEvent = CreateHabitParticipationEvent(
      habitId: widget.habitId,
    );
    context.read<HabitBloc>().add(createHabitParticipationEvent);
  }

  Future<void> _pullRefresh() async {
    BlocProvider.of<HabitBloc>(context).add(HabitInitializeEvent());
    await Future.delayed(Duration(seconds: 2));
  }

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

          final habitColor = AppColorExtension.fromString(
            habitParticipation != null ? habitParticipation.color : "",
          ).color;

          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
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
                    style: TextStyle(color: habitColor),
                  ),
                ],
              ),
              actions: [
                if (habitParticipation != null)
                  PopupMenuButton<String>(
                    color: context.colors.backgroundDark,
                    onSelected: (value) async {
                      if (value == 'quit') {
                        _quitHabit(habitParticipation.id);
                      } else if (value == 'change_color') {
                        _openColorPicker(habitParticipation.id);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'quit',
                        child:
                            Text(AppLocalizations.of(context)!.quitThisHabit),
                      ),
                      PopupMenuItem(
                        value: 'change_color',
                        child: Text(AppLocalizations.of(context)!.changeColor),
                      ),
                    ],
                  ),
              ],
            ),
            floatingActionButton: habitParticipation != null
                ? AddActivityButton(
                    action: _showAddDailyTrackingBottomSheet,
                    color: habitColor,
                  )
                : FloatingActionButton.extended(
                    onPressed: _startTrackingThisHabit,
                    icon: Icon(Icons.login),
                    label: Text(
                        AppLocalizations.of(context)!.startTrackingThisHabit),
                    backgroundColor: context.colors.primary,
                    extendedTextStyle:
                        TextStyle(letterSpacing: 1, fontFamily: 'Montserrat'),
                  ),
            body: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: habitColor.withAlpha(155),
                        // border: Border.all(width: 1, color: habitColor),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          description,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    AnalyticsCarouselWidget(
                      habitColor: habitColor,
                      habitId: habit.id,
                    ),
                    SizedBox(height: 16),
                    if (habitParticipation != null) ...[
                      DailyTrackingCarouselWidget(
                        habitDailyTrackings: habitDailyTrackings,
                        habitColor: habitColor,
                        habitId: widget.habitId,
                        canOpenDayBoxes: true,
                        displayTitle: true,
                      ),
                      SizedBox(height: 16),
                    ],
                    ChallengesCarouselWidget(habitColor: habitColor),
                    SizedBox(height: 16),
                    HabitDiscussionListWidget(habitColor: habitColor),
                    SizedBox(height: 64),
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
