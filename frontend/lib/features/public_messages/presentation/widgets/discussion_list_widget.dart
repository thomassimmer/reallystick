import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/screens/add_thread_modal.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/thread_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class DiscussionListWidget extends StatefulWidget {
  final Color color;
  final String? habitId;
  final String? challengeId;
  final String? challengeParticipationId;
  final bool previewMode;

  const DiscussionListWidget({
    required this.color,
    required this.habitId,
    required this.challengeId,
    required this.challengeParticipationId,
    required this.previewMode,
  });

  @override
  DiscussionListState createState() => DiscussionListState();
}

class DiscussionListState extends State<DiscussionListWidget> {
  void _showAddThreadBottomSheet() {
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
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                AddThreadModal(
                  habitId: widget.habitId,
                  challengeId: widget.challengeId,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicMessageState = widget.previewMode
        ? getPublicMessagesLoadedForPreview(context)
        : context.watch<PublicMessageBloc>().state;

    if (publicMessageState is PublicMessagesLoaded) {
      final threads = publicMessageState.threads
          .where(
            (thread) =>
                thread.habitId == widget.habitId &&
                thread.challengeId == widget.challengeId,
          )
          .toList();

      threads.sort((a, b) {
        if (b.likeCount != a.likeCount) {
          return b.likeCount - a.likeCount;
        }

        return b.createdAt.compareTo(a.createdAt);
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum,
                size: 20,
                color: widget.color,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.discussions,
                style: TextStyle(
                  fontSize: 20,
                  color: widget.color,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: _showAddThreadBottomSheet,
                child: Icon(
                  Icons.add_outlined,
                  size: 25,
                  color: widget.color.withValues(alpha: 0.8),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          for (final thread in threads) ...[
            ThreadWidget(
              thread: thread,
              color: widget.color,
              habitId: widget.habitId,
              challengeId: widget.challengeId,
              challengeParticipationId: widget.challengeParticipationId,
              previewMode: widget.previewMode,
            ),
            SizedBox(height: 10),
          ],
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _showAddThreadBottomSheet,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    threads.isEmpty
                        ? AppLocalizations.of(context)!.noDiscussionsForHabitYet
                        : AppLocalizations.of(context)!.addNewDiscussion,
                    style: TextStyle(color: context.colors.text),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      );
    }
  }
}
