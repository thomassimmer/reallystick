import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/message_widget.dart';

class UserReportedMessagesScreen extends StatefulWidget {
  const UserReportedMessagesScreen({
    Key? key,
  }) : super(key: key);

  @override
  UserReportedMessagesScreenState createState() =>
      UserReportedMessagesScreenState();
}

class UserReportedMessagesScreenState
    extends State<UserReportedMessagesScreen> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final profileState = context.watch<ProfileBloc>().state;

    if (profileState is ProfileAuthenticated) {
      BlocProvider.of<PublicMessageBloc>(context).add(
        PublicMessageInitializeEvent(
          habitId: null,
          challengeId: null,
          isAdmin: profileState.profile.isAdmin,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reportedMessages),
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
      return SingleChildScrollView(
        child: Column(
          children: state.userReportedMessages.map(
            (message) {
              final report = state.userReports
                  .where((r) => r.messageId == message.id)
                  .firstOrNull;

              if (report == null) {
                return SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                        withReplies: false,
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
              );
            },
          ).toList(),
        ),
      );
    } else {
      return Center(
        child: Text(AppLocalizations.of(context)!.noReportedMessages),
      );
    }
  }
}
