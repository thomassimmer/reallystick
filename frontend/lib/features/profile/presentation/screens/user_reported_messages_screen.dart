import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/message_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class UserReportedMessagesScreen extends StatefulWidget {
  const UserReportedMessagesScreen({
    super.key,
  });

  @override
  UserReportedMessagesScreenState createState() =>
      UserReportedMessagesScreenState();
}

class UserReportedMessagesScreenState
    extends State<UserReportedMessagesScreen> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<PublicMessageBloc>(context).add(
      PublicMessageInitializeEvent(
        habitId: null,
        challengeId: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.reportedMessages,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<PublicMessageBloc, PublicMessageState>(
        builder: (context, state) {
          if (state is PublicMessagesLoaded) {
            return _buildReportedMessagesView(context, state);
          } else if (state is PublicMessagesLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Text(AppLocalizations.of(context)!.failedToLoadProfile),
            );
          }
        },
      ),
    );
  }

  Widget _buildReportedMessagesView(
      BuildContext context, PublicMessagesLoaded state) {
    if (state.userReportedMessages.isNotEmpty) {
      return FullWidthListView(
        children: state.userReportedMessages.map(
          (message) {
            final report = state.userReports
                .where((r) => r.messageId == message.id)
                .firstOrNull;

            if (report == null) {
              return SizedBox.shrink();
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => {
                      if (message.repliesTo == null)
                        {
                          if (message.challengeId != null)
                            {
                              context.pushNamed(
                                'challengeThread',
                                pathParameters: {
                                  'challengeId': message.challengeId!,
                                  'challengeParticipationId': 'null',
                                  'threadId': message.threadId,
                                },
                              )
                            }
                          else if (message.habitId != null)
                            {
                              context.pushNamed(
                                'habitThread',
                                pathParameters: {
                                  'habitId': message.habitId!,
                                  'threadId': message.threadId,
                                },
                              )
                            }
                        }
                      else
                        {
                          if (message.challengeId != null)
                            {
                              context.pushNamed(
                                'challengeThreadReply',
                                pathParameters: {
                                  'challengeId': message.challengeId!,
                                  'challengeParticipationId': 'null',
                                  'messageId': message.id,
                                  'threadId': message.threadId,
                                },
                              )
                            }
                          else if (message.habitId != null)
                            {
                              context.pushNamed(
                                'habitThreadReply',
                                pathParameters: {
                                  'habitId': message.habitId!,
                                  'messageId': message.id,
                                  'threadId': message.threadId,
                                },
                              )
                            }
                        }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MessageWidget(
                          threadId: message.threadId,
                          messageId: message.id,
                          color: AppColorExtension.fromString("").color,
                          habitId: message.habitId,
                          challengeId: message.challengeId,
                          challengeParticipationId: null,
                          withReplies: false,
                          previewMode: false,
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: CustomTextField(
                            enabled: false,
                            initialValue: report.reason,
                            label: AppLocalizations.of(context)!.reason,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
            );
          },
        ).toList(),
      );
    } else {
      return Center(
        child: Text(AppLocalizations.of(context)!.noReportedMessages),
      );
    }
  }
}
