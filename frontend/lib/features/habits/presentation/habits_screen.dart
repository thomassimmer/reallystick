import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/habits/presentation/questionnaire_modal.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class HabitsScreen extends StatefulWidget {
  @override
  HabitsScreenState createState() => HabitsScreenState();
}

class HabitsScreenState extends State<HabitsScreen> {
  bool _isModalShown = false;

  void _showQuestionnaireBottomSheet(ProfileAuthenticated state) {
    setState(() {
      _isModalShown = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          minChildSize: 1.0,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return QuestionnaireModal(
              scrollController: scrollController,
              profile: state.profile,
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        final newProfile = state.profile;
        newProfile.hasSeenQuestions = true;
        BlocProvider.of<ProfileBloc>(context).add(ProfileUpdateEvent(
            newProfile: newProfile, displayNotification: false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAuthenticated &&
            !state.profile.hasSeenQuestions &&
            !_isModalShown) {
          _showQuestionnaireBottomSheet(state);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            final username = state.profile.username;
            return Center(
              child: Text(AppLocalizations.of(context)!.hello(username)),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
