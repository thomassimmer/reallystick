import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/discussion_widget.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/new_discussion_with_user_widget.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class DiscussionListScreen extends StatefulWidget {
  @override
  DiscussionListScreenState createState() => DiscussionListScreenState();
}

class DiscussionListScreenState extends State<DiscussionListScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pullRefresh() async {
    BlocProvider.of<PrivateDiscussionBloc>(context).add(
      InitializePrivateDiscussionsEvent(),
    );
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;
    final userState = context.watch<UserBloc>().state;

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
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  BlocProvider.of<UserBloc>(context).add(
                    GetUserPublicDataEvent(
                      userIds: null,
                      username: searchQuery,
                    ),
                  );
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.searchUser,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
              ),
              if (searchQuery != '') ...[
                if (userState is UsersLoaded) ...[
                  if (userState.user != null) ...[
                    NewDiscussionWithUserWidget(
                      user: userState.user!,
                    )
                  ] else if (searchQuery != '') ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.userNotFoundError,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ]
                ] else if (userState is UsersLoading) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ] else ...[
                discussions.isNotEmpty
                    ? Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
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
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!
                                .noPrivateDiscussionsYet,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
