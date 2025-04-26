import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class NotificationSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildNotificationSelectionView(context, state);
          } else if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
                child: Text(AppLocalizations.of(context)!.failedToLoadProfile));
          }
        },
      ),
    );
  }

  Widget _buildNotificationSelectionView(
      BuildContext context, ProfileAuthenticated state) {
    final profile = state.profile;

    final bool notificationsEnabled = profile.notificationsEnabled;

    final List<Map<String, dynamic>> notificationSettings = [
      {
        'label': 'Private Messages',
        'value': profile.notificationsForPrivateMessagesEnabled,
        'onChanged': (bool value) {
          _updateProfile(
              context, profile..notificationsForPrivateMessagesEnabled = value);
        },
      },
      {
        'label': 'Public Message Likes',
        'value': profile.notificationsForPublicMessageLikedEnabled,
        'onChanged': (bool value) {
          _updateProfile(context,
              profile..notificationsForPublicMessageLikedEnabled = value);
        },
      },
      {
        'label': 'Public Message Replies',
        'value': profile.notificationsForPublicMessageRepliesEnabled,
        'onChanged': (bool value) {
          _updateProfile(context,
              profile..notificationsForPublicMessageRepliesEnabled = value);
        },
      },
      {
        'label': 'User Joined Your Challenge',
        'value': profile.notificationsUserJoinedYourChallengeEnabled,
        'onChanged': (bool value) {
          _updateProfile(context,
              profile..notificationsUserJoinedYourChallengeEnabled = value);
        },
      },
      {
        'label': 'User Duplicated Your Challenge',
        'value': profile.notificationsUserDuplicatedYourChallengeEnabled,
        'onChanged': (bool value) {
          _updateProfile(context,
              profile..notificationsUserDuplicatedYourChallengeEnabled = value);
        },
      },
    ];

    return FullWidthListView(
      children: [
        SwitchListTile(
          title: Text('Enable Notifications'),
          value: notificationsEnabled,
          onChanged: (bool value) {
            _updateProfile(context, profile..notificationsEnabled = value);
          },
        ),
        ...notificationSettings.map((setting) {
          return Opacity(
            opacity: notificationsEnabled ? 1.0 : 0.4,
            child: SwitchListTile(
              title: Text(setting['label']),
              value: setting['value'],
              onChanged: notificationsEnabled
                  ? (bool value) => setting['onChanged'](value)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  void _updateProfile(BuildContext context, Profile updatedProfile) {
    BlocProvider.of<ProfileBloc>(context)
        .add(ProfileUpdateEvent(newProfile: updatedProfile));
  }
}
