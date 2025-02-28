import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/discussion_widget.dart';

class DiscussionListScreen extends StatefulWidget {
  @override
  DiscussionListScreenState createState() => DiscussionListScreenState();
}

class DiscussionListScreenState extends State<DiscussionListScreen> {
  Future<void> _pullRefresh() async {
    BlocProvider.of<PrivateDiscussionBloc>(context).add(
      InitializePrivateDiscussionsEvent(),
    );
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final publicMessageState = context.watch<PrivateDiscussionBloc>().state;

    if (publicMessageState is PrivateDiscussionLoaded) {
      final discussions = publicMessageState.discussions.values.toList();

      discussions.sort((a, b) {
        if (a.hasBlocked || b.hasBlocked) {
          return -1;
        }

        if (a.lastMessage != null && b.lastMessage != null) {
          return b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt);
        }

        return b.createdAt.compareTo(a.createdAt);
      });

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            AppLocalizations.of(context)!.messages,
            textAlign: TextAlign.left,
          ),
          leading: Icon(
            Icons.message,
            size: 20,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (discussions.isNotEmpty) ...[
                  for (final (idx, discussion) in discussions.indexed) ...[
                    DiscussionWidget(
                      discussion: discussion,
                    ),
                    if (idx != discussions.length - 1) Divider(),
                  ],
                ] else ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    // decoration: BoxDecoration(
                    //   boxShadow: [
                    //     BoxShadow(
                    //         // color: widget.color.withOpacity(0.2),
                    //         // blurRadius: 10,
                    //         ),
                    //   ],
                    //   borderRadius: BorderRadius.circular(16),
                    // ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!
                                .noDiscussionsForHabitYet,
                            // style: TextStyle(color: context.colors.text),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
