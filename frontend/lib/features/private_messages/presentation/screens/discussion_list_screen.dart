import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
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
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;

    final discussions = privateDiscussionState.discussions.values.toList();

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
        title: Text(
          AppLocalizations.of(context)!.messages,
          style: context.typographies.heading,
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: discussions.isNotEmpty
              ? CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Stack(
                          children: [
                            DiscussionWidget(
                              discussion: discussions[index],
                            ),
                            if (index != 0) Divider(),
                          ],
                        );
                      }, childCount: discussions.length),
                    ),
                  ],
                )
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!
                              .noPrivateDiscussionsYet,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
