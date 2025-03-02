import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/icon_with_warning.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final shouldBeWarning =
            state is ProfileAuthenticated && state.profile.passwordIsExpired;
        final userIsAdmin =
            state is ProfileAuthenticated && state.profile.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.profileSettings,
              style: context.typographies.heading,
            ),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            children: [
              _buildSection(context, AppLocalizations.of(context)!.activity, [
                _buildCardTile(
                    context,
                    AppLocalizations.of(context)!.likedMessages,
                    'liked-messages'),
                _buildCardTile(
                    context,
                    AppLocalizations.of(context)!.writtenMessages,
                    'written-messages'),
                _buildCardTile(
                    context,
                    AppLocalizations.of(context)!.reportedMessages,
                    'reported-messages'),
              ]),
              _buildSection(context, AppLocalizations.of(context)!.account, [
                _buildCardTile(context, AppLocalizations.of(context)!.language,
                    'language'),
                _buildCardTile(
                    context, AppLocalizations.of(context)!.theme, 'theme'),
                _buildCardTile(
                    context,
                    AppLocalizations.of(context)!.notifications,
                    'profile-notifications'),
                _buildCardTile(
                  context,
                  AppLocalizations.of(context)!.changePassword,
                  'password',
                  iconWithWarning: shouldBeWarning,
                ),
                _buildCardTile(
                    context,
                    AppLocalizations.of(context)!.changeRecoveryCode,
                    'update-recovery-code'),
                _buildCardTile(context, AppLocalizations.of(context)!.twoFA,
                    'two-factor-authentication'),
                _buildCardTile(
                    context,
                    AppLocalizations.of(context)!.profileInformation,
                    'profile-information'),
              ]),
              if (userIsAdmin)
                _buildSection(context, AppLocalizations.of(context)!.admin, [
                  _buildCardTile(context,
                      AppLocalizations.of(context)!.allHabits, 'allHabits'),
                  _buildCardTile(
                      context,
                      AppLocalizations.of(context)!.allReportedMessages,
                      'all-reported-messages'),
                  _buildCardTile(context,
                      AppLocalizations.of(context)!.statistics, 'statistics'),
                ]),
              _buildSection(context, AppLocalizations.of(context)!.other, [
                _buildCardTile(
                    context, AppLocalizations.of(context)!.devices, 'devices'),
                _buildCardTile(
                    context, AppLocalizations.of(context)!.about, 'about'),
              ]),
              _buildActionButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: context.typographies.body.copyWith(
              color: context.colors.hint,
              fontSize: 14,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildCardTile(
    BuildContext context,
    String title,
    String route, {
    bool iconWithWarning = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title),
        trailing: iconWithWarning
            ? IconWithWarning(
                iconData: Icons.chevron_right, shouldBeWarning: true)
            : Icon(Icons.chevron_right),
        onTap: () {
          context.goNamed(route);
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).add(AuthLogoutEvent());
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.logout),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            Text(AppLocalizations.of(context)!.confirmDelete),
                        content: Text(
                            AppLocalizations.of(context)!.confirmDeleteMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: TextStyle(color: context.colors.error),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    BlocProvider.of<ProfileBloc>(context)
                        .add(DeleteAccountEvent());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: context.colors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.deleteAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
