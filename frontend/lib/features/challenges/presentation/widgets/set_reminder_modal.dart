import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/time.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class SetReminderModal extends StatefulWidget {
  final ChallengeParticipation challengeParticipation;
  final String challengeName;

  const SetReminderModal({
    required this.challengeParticipation,
    required this.challengeName,
  });

  @override
  SetReminderModalState createState() => SetReminderModalState();
}

class SetReminderModalState extends State<SetReminderModal> {
  bool notificationsReminderEnabled = false;
  DateTime reminderTime = DateTime.now();
  String? reminderBody;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      notificationsReminderEnabled =
          widget.challengeParticipation.notificationsReminderEnabled;

      // Convert the reminderTime from UTC String ("HH:mm:ss") to DateTime
      reminderTime = parseTime(widget.challengeParticipation.reminderTime);
      reminderBody = widget.challengeParticipation.reminderBody ??
          AppLocalizations.of(context)!
              .defaultReminderHabit(widget.challengeName);
    });
  }

  void saveReminderSettings() {
    final event = UpdateHabitParticipationEvent(
      habitParticipationId: widget.challengeParticipation.id,
      color: widget.challengeParticipation.color,
      notificationsReminderEnabled: notificationsReminderEnabled,
      reminderTime: formatTime(reminderTime),
      reminderBody: reminderBody,
    );

    context.read<HabitBloc>().add(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;

    if (profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.notifications,
            textAlign: TextAlign.center,
            style: context.typographies.headingSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.enableNotificationsReminder,
              ),
              Spacer(),
              Switch(
                value: notificationsReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsReminderEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(reminderTime),
              );
              if (pickedTime != null) {
                setState(() {
                  reminderTime = DateTime(
                    reminderTime.year,
                    reminderTime.month,
                    reminderTime.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }
            },
            child: Text(
              DateFormat.Hm(userLocale).format(reminderTime),
              style: context.typographies.body.copyWith(
                color: notificationsReminderEnabled
                    ? context.colors.primary
                    : context.colors.hint,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            initialValue: reminderBody,
            enabled: notificationsReminderEnabled,
            maxLines: null,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            label: AppLocalizations.of(context)!.message,
            onChanged: (value) {
              setState(() {
                reminderBody = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: saveReminderSettings,
            child: Text(AppLocalizations.of(context)!.save),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
