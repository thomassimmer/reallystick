import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/habits/presentation/screens/color_picker_modal.dart';
import 'package:reallystick/features/habits/presentation/screens/set_reminder_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/add_activity_button.dart';
import 'package:reallystick/features/habits/presentation/widgets/analytics_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/challenges_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/discussion_list_widget.dart';

class HabitDetailsScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailsScreen({
    super.key,
    required this.habitId,
  });

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
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
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

  void _showNotificationsReminderBottomSheet({
    required HabitParticipation habitParticipation,
    required String habitName,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
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
            children: [
              SetReminderModal(
                habitParticipation: habitParticipation,
                habitName: habitName,
              )
            ],
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

  void _openColorPicker(HabitParticipation habitParticipation) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return ColorPickerModal(
          onColorSelected: (selectedColor) {
            final updateHabitParticipationEvent = UpdateHabitParticipationEvent(
              habitParticipationId: habitParticipation.id,
              color: selectedColor.toShortString(),
              notificationsReminderEnabled:
                  habitParticipation.notificationsReminderEnabled,
              reminderTime: habitParticipation.reminderTime,
              reminderBody: habitParticipation.reminderBody,
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
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final profileState = context.watch<ProfileBloc>().state;

    if (profileState is ProfileAuthenticated) {
      BlocProvider.of<PublicMessageBloc>(context).add(
        PublicMessageInitializeEvent(
          habitId: widget.habitId,
          challengeId: null,
          isAdmin: profileState.profile.isAdmin,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    if (profileState is ProfileAuthenticated && habitState is HabitsLoaded) {
      final userLocale = profileState.profile.locale;

      final habit = habitState.habits[widget.habitId]!;
      final habitParticipation = habitState.habitParticipations
          .where((hp) => hp.habitId == widget.habitId)
          .firstOrNull;
      final habitDailyTrackings = habitState.habitDailyTrackings
          .where((hdt) => hdt.habitId == widget.habitId)
          .toList();

      final name = getRightTranslationFromJson(
        habit.name,
        userLocale,
      );

      final description = getRightTranslationFromJson(
        habit.description,
        userLocale,
      );

      final habitColor = AppColorExtension.fromString(
        habitParticipation != null ? habitParticipation.color : "",
      ).color;

      return Scaffold(
        appBar: CustomAppBar(
          title: Text(
            name,
            style: context.typographies.heading.copyWith(
              color: habitColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          actions: [
            if (habitParticipation != null)
              PopupMenuButton<String>(
                color: context.colors.backgroundDark,
                onSelected: (value) async {
                  if (value == 'quit') {
                    _quitHabit(habitParticipation.id);
                  } else if (value == 'change_color') {
                    _openColorPicker(habitParticipation);
                  } else if (value == 'set_reminder') {
                    _showNotificationsReminderBottomSheet(
                      habitParticipation: habitParticipation,
                      habitName: name,
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'quit',
                    child: Text(AppLocalizations.of(context)!.quitThisHabit),
                  ),
                  PopupMenuItem(
                    value: 'change_color',
                    child: Text(AppLocalizations.of(context)!.changeColor),
                  ),
                  PopupMenuItem(
                    value: 'set_reminder',
                    child: Text(AppLocalizations.of(context)!.notifications),
                  ),
                ],
              ),
          ],
        ),
        floatingActionButton: habitParticipation != null
            ? AddActivityButton(
                action: _showAddDailyTrackingBottomSheet,
                color: habitColor,
                label: null,
              )
            : FloatingActionButton.extended(
                onPressed: _startTrackingThisHabit,
                icon: Icon(Icons.login),
                label:
                    Text(AppLocalizations.of(context)!.startTrackingThisHabit),
                backgroundColor: context.colors.primary,
                extendedTextStyle:
                    TextStyle(letterSpacing: 1, fontFamily: 'Montserrat'),
              ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: FullWidthListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: habitColor.withAlpha(155),
                  border: Border.all(width: 1, color: habitColor),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        habit.icon,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!
                            .descriptionWithTwoPoints(description),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              AnalyticsCarouselWidget(
                habitColor: habitColor,
                habitId: habit.id,
              ),
              SizedBox(height: 40),
              if (habitParticipation != null) ...[
                DailyTrackingCarouselWidget(
                  habitDailyTrackings: habitDailyTrackings,
                  habitColor: habitColor,
                  habit: habit,
                  canOpenDayBoxes: true,
                  displayTitle: true,
                ),
                SizedBox(height: 16),
              ],
              ChallengesCarouselWidget(
                habitColor: habitColor,
                habitId: widget.habitId,
              ),
              SizedBox(height: 40),
              DiscussionListWidget(
                color: habitColor,
                habitId: widget.habitId,
                challengeId: null,
                challengeParticipationId: null,
              ),
              SizedBox(height: 72),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
