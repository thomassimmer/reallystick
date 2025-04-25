import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_button.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';

class ChangeParticipationStartDateModal extends StatefulWidget {
  final String challengeId;
  final ChallengeParticipation challengeParticipation;
  final String userLocale;

  const ChangeParticipationStartDateModal({
    super.key,
    required this.challengeId,
    required this.challengeParticipation,
    required this.userLocale,
  });

  @override
  ChangeParticipationStartDateModalState createState() =>
      ChangeParticipationStartDateModalState();
}

class ChangeParticipationStartDateModalState
    extends State<ChangeParticipationStartDateModal> {
  DateTime _startDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startDate = widget.challengeParticipation.startDate;
  }

  void updateChallengeParticipationStartDate(BuildContext context) {
    context.read<ChallengeBloc>().add(
          UpdateChallengeParticipationEvent(
            challengeParticipationId: widget.challengeParticipation.id,
            color: widget.challengeParticipation.color,
            startDate: _startDate,
            notificationsReminderEnabled:
                widget.challengeParticipation.notificationsReminderEnabled,
            reminderTime: widget.challengeParticipation.reminderTime,
            reminderBody: widget.challengeParticipation.reminderBody,
            finished: widget.challengeParticipation.finished,
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
                  AppLocalizations.of(context)!
                      .changeChallengeParticipationStartDate,
                  textAlign: TextAlign.center,
                  style: context.typographies.headingSmall,
                ),
                SizedBox(height: 16),
                CustomTextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          _startDate.hour,
                          _startDate.minute,
                        );
                      });
                    }
                  },
                  labelText: AppLocalizations.of(context)!.date,
                  text: DateFormat.yMMMd(widget.userLocale).format(_startDate),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      updateChallengeParticipationStartDate(context),
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
