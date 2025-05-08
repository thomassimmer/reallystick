import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/custom_elevated_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_button.dart';
import 'package:reallystick/core/presentation/widgets/emoji_selector.dart';
import 'package:reallystick/core/presentation/widgets/multi_language_input_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_creation/challenge_creation_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_creation/challenge_creation_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class CreateChallengeScreen extends StatefulWidget {
  @override
  CreateChallengeScreenState createState() => CreateChallengeScreenState();
}

class CreateChallengeScreenState extends State<CreateChallengeScreen> {
  Map<String, String> _nameControllerForChallenge = {};
  Map<String, String> _descriptionControllerForChallenge = {};
  bool _isFixedDatesEnabled = false;
  String? _icon;
  DateTime _startDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    final profileState = context.read<ProfileBloc>().state;

    if (profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;

      _nameControllerForChallenge = {userLocale: ''};
      _descriptionControllerForChallenge = {userLocale: ''};
    }
  }

  void _showEmojiPicker(BuildContext context, String userLocale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      builder: (context) => CustomEmojiSelector(
        userLocale: userLocale,
        onEmojiSelected: (category, emoji) {
          setState(() {
            _icon = emoji.emoji;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _createChallenge(String locale) {
    final challengeFormBloc = context.read<ChallengeCreationFormBloc>();

    // Dispatch validation events for all fields
    challengeFormBloc.add(
        ChallengeCreationFormNameChangedEvent(_nameControllerForChallenge));
    challengeFormBloc.add(ChallengeCreationFormDescriptionChangedEvent(
        _descriptionControllerForChallenge));
    challengeFormBloc.add(ChallengeCreationFormIconChangedEvent(_icon ?? ""));
    challengeFormBloc.add(ChallengeCreationFormStartDateChangedEvent(
        _isFixedDatesEnabled ? _startDateTime : null));

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (challengeFormBloc.state.isValid) {
          final newChallengeEvent = CreateChallengeEvent(
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

          if (message.messageKey == "challengeCreated") {
            final newChallenge = state.newlyCreatedChallenge;

            if (newChallenge != null) {
              context.goNamed(
                'challengeDetails',
                pathParameters: {
                  'challengeId': newChallenge.id,
                  'challengeParticipationId': 'null'
                },
              );
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          if (profileState is ProfileAuthenticated &&
              challengeState is ChallengesLoaded) {
            final userLocale = profileState.profile.locale;

            final nameErrorMap = context.select(
              (ChallengeCreationFormBloc challengeCreationFormBloc) =>
                  Map.fromEntries(
                challengeCreationFormBloc.state.name.entries.map(
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
              (ChallengeCreationFormBloc challengeCreationFormBloc) =>
                  Map.fromEntries(
                challengeCreationFormBloc.state.description.entries.map(
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
              (ChallengeCreationFormBloc challengeCreationFormBloc) =>
                  challengeCreationFormBloc.state.icon.displayError,
            );
            final displayIconErrorMessage = displayIconError != null
                ? getTranslatedMessage(
                    context, ErrorMessage(displayIconError.messageKey))
                : null;

            final displayStartDateTimeErrorMessage = context.select(
              (ChallengeCreationFormBloc bloc) {
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
                  AppLocalizations.of(context)!.addNewChallenge,
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
                              BlocProvider.of<ChallengeCreationFormBloc>(
                                      context)
                                  .add(
                                ChallengeCreationFormNameChangedEvent(
                                    translations),
                              );
                            },
                            label: AppLocalizations.of(context)!.challengeName,
                            errors: nameErrorMap,
                            userLocale: userLocale,
                            multiline: false,
                          ),

                          const SizedBox(height: 16.0),

                          // Description Input
                          MultiLanguageInputField(
                            initialTranslations:
                                _descriptionControllerForChallenge,
                            onTranslationsChanged:
                                (Map<String, String> translations) {
                              _descriptionControllerForChallenge = translations;
                              BlocProvider.of<ChallengeCreationFormBloc>(
                                      context)
                                  .add(
                                ChallengeCreationFormDescriptionChangedEvent(
                                    translations),
                              );
                            },
                            label: AppLocalizations.of(context)!.description,
                            errors: descriptionErrorMap,
                            userLocale: userLocale,
                            multiline: true,
                          ),

                          const SizedBox(height: 16.0),

                          // Icon Selector with error display
                          Text(AppLocalizations.of(context)!.icon),
                          const SizedBox(height: 8),
                          CustomElevatedButtonFormField(
                            onPressed: () =>
                                _showEmojiPicker(context, userLocale),
                            iconData: null,
                            label: _icon ??
                                AppLocalizations.of(context)!.chooseAnIcon,
                            errorText: displayIconErrorMessage,
                            labelSize: _icon != null ? 20 : null,
                          ),

                          const SizedBox(height: 16.0),

                          // Precise Dates Section

                          // Start Date & Time Selector
                          Row(
                            children: [
                              Text(AppLocalizations.of(context)!.startDate),
                              const SizedBox(width: 8),
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

                          if (_isFixedDatesEnabled) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Day Selector
                                Expanded(
                                  child: CustomTextButton(
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
                                      BlocProvider.of<
                                                  ChallengeCreationFormBloc>(
                                              context)
                                          .add(
                                              ChallengeCreationFormStartDateChangedEvent(
                                                  _startDateTime));
                                    },
                                    labelText:
                                        AppLocalizations.of(context)!.date,
                                    text: DateFormat.yMMMd(userLocale)
                                        .format(_startDateTime),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Time Selector
                                Expanded(
                                  child: CustomTextButton(
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
                                                    ChallengeCreationFormBloc>(
                                                context)
                                            .add(
                                          ChallengeCreationFormStartDateChangedEvent(
                                              _startDateTime),
                                        );
                                      }
                                    },
                                    labelText:
                                        AppLocalizations.of(context)!.time,
                                    text:
                                        DateFormat.Hm().format(_startDateTime),
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

                          // Create Challenge Button
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _createChallenge(userLocale),
                                child: Text(AppLocalizations.of(context)!
                                    .createChallenge),
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
            return Scaffold(
              appBar: CustomAppBar(
                title: Text(
                  AppLocalizations.of(context)!.addNewChallenge,
                  style: context.typographies.headingSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
