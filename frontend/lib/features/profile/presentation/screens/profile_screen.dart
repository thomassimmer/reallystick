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
            title: Text(AppLocalizations.of(context)!.profileSettings),
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.language),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('language');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.theme),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('theme');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.likedMessages),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('liked-messages');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.writtenMessages),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('written-messages');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.reportedMessages),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('reported-messages');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.allReportedMessages),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('all-reported-messages');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.twoFA),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('two-factor-authentication');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.changePassword),
                trailing: IconWithWarning(
                    iconData: Icons.chevron_right,
                    shouldBeWarning: shouldBeWarning),
                onTap: () {
                  context.goNamed('password');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.profileInformation),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('profile-information');
                },
              ),
              if (userIsAdmin)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.allHabits),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    context.goNamed('allHabits');
                  },
                ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.devices),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('devices');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.about),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.goNamed('about');
                },
              ),
              const SizedBox(height: 32),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context).add(AuthLogoutEvent());
                    },
                    style: context.styles.buttonMedium,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 4,
                      ),
                      child: Text(AppLocalizations.of(context)!.logout),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                AppLocalizations.of(context)!.confirmDelete),
                            content: Text(AppLocalizations.of(context)!
                                .confirmDeleteMessage),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: context.typographies.body,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.confirm,
                                  style: context.typographies.body
                                      .copyWith(color: context.colors.error),
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
                    style: context.styles.buttonMedium.copyWith(
                      backgroundColor:
                          WidgetStatePropertyAll(context.colors.error),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 4,
                      ),
                      child: Text(AppLocalizations.of(context)!.deleteAccount),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
