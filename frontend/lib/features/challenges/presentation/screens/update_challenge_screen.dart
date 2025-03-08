import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/screens/loading_screen.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/custom_elevated_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/emoji_selector.dart';
import 'package:reallystick/core/presentation/widgets/multi_language_input_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_Update/challenge_Update_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_update/challenge_update_bloc.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenge_not_found_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/user_is_not_challenge_creator_screen.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class UpdateChallengeScreen extends StatefulWidget {
  final String challengeId;

  const UpdateChallengeScreen({required this.challengeId});

  @override
  UpdateChallengeScreenState createState() => UpdateChallengeScreenState();
}

class UpdateChallengeScreenState extends State<UpdateChallengeScreen> {
  Map<String, String> _nameControllerForChallenge = {};
  Map<String, String> _descriptionControllerForChallenge = {};
  bool _isFixedDatesEnabled = true;
  String? _icon;
  DateTime _startDateTime = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final challengeState = context.watch<ChallengeBloc>().state;

    if (challengeState is ChallengesLoaded) {
      final challenge = challengeState.challenges[widget.challengeId]!;

      setState(() {
        _nameControllerForChallenge = challenge.name;
        _descriptionControllerForChallenge = challenge.description;
        _isFixedDatesEnabled = challenge.startDate != null;
        _icon = challenge.icon;
        _startDateTime = challenge.startDate ?? DateTime.now();
      });
    }
  }

  void _showEmojiPicker(BuildContext context, String userLocale) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomEmojiSelector(
        userLocale: userLocale,
        onEmojiSelected: (category, emoji) {
          if (mounted) {
            BlocProvider.of<ChallengeUpdateFormBloc>(context).add(
              ChallengeUpdateFormIconChangedEvent(emoji.emoji),
            );
          }

          setState(() {
            _icon = emoji.emoji;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _updateChallenge(String locale) {
    final challengeFormBloc = context.read<ChallengeUpdateFormBloc>();

    // Dispatch validation events for all fields
    challengeFormBloc
        .add(ChallengeUpdateFormNameChangedEvent(_nameControllerForChallenge));
    challengeFormBloc.add(ChallengeUpdateFormDescriptionChangedEvent(
        _descriptionControllerForChallenge));
    challengeFormBloc.add(ChallengeUpdateFormIconChangedEvent(_icon ?? ""));
    challengeFormBloc.add(ChallengeUpdateFormStartDateChangedEvent(
        _isFixedDatesEnabled ? _startDateTime : null));

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (challengeFormBloc.state.isValid) {
          final newChallengeEvent = UpdateChallengeEvent(
            challengeId: widget.challengeId,
            name: _nameControllerForChallenge,
            description: _descriptionControllerForChallenge,
            icon: _icon ?? "",
            startDate: _isFixedDatesEnabled ? _startDateTime : null,
          );

          if (mounted) {
            context.read<ChallengeBloc>().add(newChallengeEvent);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final challengeState = context.watch<ChallengeBloc>().state;

    return BlocListener<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengesLoaded && state.message is SuccessMessage) {
          final message = state.message as SuccessMessage;

          if (message.messageKey == "challengeUpdated") {
            final newChallenge = state.newlyUpdatedChallenge;

            if (newChallenge != null) {
              context.goNamed(
                'challengeDetails',
                pathParameters: {'challengeId': newChallenge.id},
              );
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          if (profileState is ProfileAuthenticated &&
              challengeState is ChallengesLoaded) {
            final challenge = challengeState.challenges[widget.challengeId];

            if (challenge == null) {
              if (challengeState.notFoundChallenge == widget.challengeId) {
                return ChallengeNotFoundScreen();
              } else {
                context
                    .read<ChallengeBloc>()
                    .add(GetChallengeEvent(challengeId: widget.challengeId));
                return LoadingScreen();
              }
            }

            if (challenge.creator != profileState.profile.id ||
                !profileState.profile.isAdmin) {
              return UserIsNotChallengeCreatorScreen();
            }

            final userLocale = profileState.profile.locale;

            final nameErrorMap = context.select(
              (ChallengeUpdateFormBloc challengeUpdateFormBloc) =>
                  Map.fromEntries(
                challengeUpdateFormBloc.state.name.entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    entry.value.displayError != null
                        ? getTranslatedMessage(
                            context,
                            ErrorMessage(entry.value.displayError!.messageKey),
                          )
                        : null,
                  ),
                ),
              ),
            );

            final descriptionErrorMap = context.select(
              (ChallengeUpdateFormBloc challengeUpdateFormBloc) =>
                  Map.fromEntries(
                challengeUpdateFormBloc.state.description.entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    entry.value.displayError != null
                        ? getTranslatedMessage(
                            context,
                            ErrorMessage(entry.value.displayError!.messageKey),
                          )
                        : null,
                  ),
                ),
              ),
            );

            final displayIconError = context.select(
              (ChallengeUpdateFormBloc challengeUpdateFormBloc) =>
                  challengeUpdateFormBloc.state.icon.displayError,
            );
            final displayIconErrorMessage = displayIconError != null
                ? getTranslatedMessage(
                    context, ErrorMessage(displayIconError.messageKey))
                : null;

            final displayStartDateTimeErrorMessage = context.select(
              (ChallengeUpdateFormBloc bloc) {
                final error = bloc.state.startDate.displayError;
                return error != null
                    ? getTranslatedMessage(
                        context, ErrorMessage(error.messageKey))
                    : null;
              },
            );

            return Scaffold(
              appBar: CustomAppBar(
                title: Text(
                  AppLocalizations.of(context)!.editChallenge,
                  style: context.typographies.headingSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //  Name Input
                          MultiLanguageInputField(
                            initialTranslations: _nameControllerForChallenge,
                            onTranslationsChanged:
                                (Map<String, String> translations) {
                              _nameControllerForChallenge = translations;
                              BlocProvider.of<ChallengeUpdateFormBloc>(context)
                                  .add(
                                ChallengeUpdateFormNameChangedEvent(
                                    translations),
                              );
                            },
                            label: AppLocalizations.of(context)!.challengeName,
                            errors: nameErrorMap,
                          ),

                          const SizedBox(height: 16.0),

                          // Description Input
                          MultiLanguageInputField(
                            initialTranslations:
                                _descriptionControllerForChallenge,
                            onTranslationsChanged:
                                (Map<String, String> translations) {
                              _descriptionControllerForChallenge = translations;
                              BlocProvider.of<ChallengeUpdateFormBloc>(context)
                                  .add(
                                ChallengeUpdateFormDescriptionChangedEvent(
                                    translations),
                              );
                            },
                            label: AppLocalizations.of(context)!.description,
                            errors: descriptionErrorMap,
                          ),

                          const SizedBox(height: 16.0),

                          // Toggle Switch for "Precise Dates"
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.fixedDates,
                              ),
                              Switch(
                                value: _isFixedDatesEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isFixedDatesEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          // Precise Dates Section
                          if (_isFixedDatesEnabled) ...[
                            // Start Date & Time Selector
                            Text(AppLocalizations.of(context)!.startDate),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Day Selector
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: _startDateTime,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _startDateTime = DateTime(
                                              pickedDate.year,
                                              pickedDate.month,
                                              pickedDate.day,
                                              _startDateTime.hour,
                                              _startDateTime.minute);
                                        });
                                      }
                                      BlocProvider.of<ChallengeUpdateFormBloc>(
                                              context)
                                          .add(
                                              ChallengeUpdateFormStartDateChangedEvent(
                                                  _startDateTime));
                                    },
                                    child: Text(
                                      DateFormat.yMMMd().format(_startDateTime),
                                      style: context.typographies.body,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Time Selector
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async {
                                      final pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            _startDateTime),
                                      );
                                      if (pickedTime != null) {
                                        setState(() {
                                          _startDateTime = DateTime(
                                            _startDateTime.year,
                                            _startDateTime.month,
                                            _startDateTime.day,
                                            pickedTime.hour,
                                            pickedTime.minute,
                                          );
                                        });
                                        BlocProvider.of<
                                                    ChallengeUpdateFormBloc>(
                                                context)
                                            .add(
                                          ChallengeUpdateFormStartDateChangedEvent(
                                              _startDateTime),
                                        );
                                      }
                                    },
                                    child: Text(
                                      DateFormat.Hm().format(_startDateTime),
                                      style: context.typographies.body,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (displayStartDateTimeErrorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 8),
                                child: Text(
                                  displayStartDateTimeErrorMessage,
                                  style: TextStyle(
                                    color: context.colors.error,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 16.0),

                          // Icon Selector with error display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomElevatedButtonFormField(
                                    onPressed: () =>
                                        _showEmojiPicker(context, userLocale),
                                    iconData: Icons.emoji_emotions,
                                    label: AppLocalizations.of(context)!.icon,
                                    errorText: displayIconErrorMessage,
                                  ),
                                  const SizedBox(width: 16.0),
                                  if (_icon != null)
                                    Text(
                                      _icon!,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16.0),

                          // Update Challenge Button
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _updateChallenge(userLocale),
                                child: Text(AppLocalizations.of(context)!
                                    .updateChallenge),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return LoadingScreen();
          }
        },
      ),
    );
  }
}
