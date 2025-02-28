import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/widgets/global_snack_bar.dart';
import 'package:reallystick/core/widgets/icon_with_warning.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class RootScreen extends StatelessWidget {
  final Widget child;

  const RootScreen({required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/habits')) {
      return 0;
    }
    if (location.startsWith('/challenges')) {
      return 1;
    }
    if (location.startsWith('/messages')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = checkIfLargeScreen(context);

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.goNamed('habits');
        case 1:
          context.goNamed('challenges');
        case 2:
          context.goNamed('messages');
        case 3:
          context.goNamed('profile');
      }
    }

    return MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(listener: (context, state) {
            GlobalSnackBar.show(context, state.message);

            if (state is AuthUnauthenticatedState) {
              context.goNamed('home');
            }
          }),
          BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
            GlobalSnackBar.show(context, state.message);
          }),
        ],
        child:
            BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
          final shouldBeWarning =
              state is ProfileAuthenticated && state.profile.passwordIsExpired;

          return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.goNamed('home');
                      },
                      child: Row(
                        children: [
                          Text('Really',
                              style: context.typographies.headingSmall
                                  .copyWith(color: context.colors.background)),
                          Text(
                            'Stick',
                            style: context.typographies.headingSmall
                                .copyWith(color: context.colors.hint),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: context.colors.primary,
                actions: [
                  if (state.profile != null)
                    TextButton(
                      onPressed: () {
                        context.goNamed('profile');
                      },
                      child: Text(
                        AppLocalizations.of(context)!
                            .hello(state.profile!.username),
                        style: context.typographies.body
                            .copyWith(color: context.colors.textOnPrimary),
                      ),
                    )
                ],
              ),
              body: Row(
                children: [
                  if (isLargeScreen) ...[
                    Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colors.primary,
                              context.colors.secondary
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: NavigationRail(
                          backgroundColor: Colors.transparent,
                          indicatorColor: context.colors.background,
                          useIndicator: true,
                          unselectedLabelTextStyle: TextStyle(
                            color: context.colors.textOnPrimary,
                          ),
                          selectedLabelTextStyle: TextStyle(
                            color: context.colors.textOnPrimary,
                          ),
                          selectedIconTheme:
                              IconThemeData(color: context.colors.primary),
                          unselectedIconTheme: IconThemeData(
                              color: context.colors.textOnPrimary),
                          selectedIndex: _calculateSelectedIndex(context),
                          onDestinationSelected: onItemTapped,
                          labelType: NavigationRailLabelType.all,
                          destinations: <NavigationRailDestination>[
                            NavigationRailDestination(
                              icon: Icon(Icons.check_circle_outline),
                              selectedIcon: Icon(
                                Icons.check_circle,
                              ),
                              label: Text(AppLocalizations.of(context)!.habits),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.flag_outlined),
                              selectedIcon: Icon(Icons.flag),
                              label: Text(
                                  AppLocalizations.of(context)!.challenges),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.message_outlined),
                              selectedIcon: Icon(Icons.message),
                              label:
                                  Text(AppLocalizations.of(context)!.messages),
                            ),
                            NavigationRailDestination(
                              icon: IconWithWarning(
                                  iconData: Icons.person_outline,
                                  shouldBeWarning: shouldBeWarning),
                              selectedIcon: IconWithWarning(
                                iconData: Icons.person,
                                shouldBeWarning: shouldBeWarning,
                              ),
                              label:
                                  Text(AppLocalizations.of(context)!.profile),
                            ),
                          ],
                        )),
                  ],
                  isLargeScreen
                      ? Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            child: child,
                          ),
                        )
                      : Expanded(
                          child: child,
                        ),
                ],
              ),
              bottomNavigationBar: isLargeScreen
                  ? null
                  : NavigationBarTheme(
                      data: NavigationBarThemeData(
                        iconTheme:
                            WidgetStateProperty.resolveWith<IconThemeData>(
                          (Set<WidgetState> states) =>
                              states.contains(WidgetState.selected)
                                  ? IconThemeData(color: context.colors.primary)
                                  : IconThemeData(
                                      color: context.colors.textOnPrimary),
                        ),
                        labelTextStyle:
                            WidgetStateProperty.resolveWith<TextStyle>(
                          (Set<WidgetState> states) =>
                              TextStyle(color: context.colors.textOnPrimary),
                        ),
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colors.primary,
                                context.colors.secondary
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: NavigationBar(
                            backgroundColor: Colors.transparent,
                            indicatorColor: context.colors.background,
                            selectedIndex: _calculateSelectedIndex(context),
                            onDestinationSelected: onItemTapped,
                            destinations: <NavigationDestination>[
                              NavigationDestination(
                                icon: Icon(Icons.check_circle_outline),
                                selectedIcon: Icon(Icons.check_circle),
                                label: AppLocalizations.of(context)!.habits,
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.flag_outlined),
                                selectedIcon: Icon(Icons.flag),
                                label: AppLocalizations.of(context)!.challenges,
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.message_outlined),
                                selectedIcon: Icon(Icons.message),
                                label: AppLocalizations.of(context)!.messages,
                              ),
                              NavigationDestination(
                                icon: IconWithWarning(
                                    iconData: Icons.person_outline,
                                    shouldBeWarning: shouldBeWarning),
                                selectedIcon: IconWithWarning(
                                  iconData: Icons.person,
                                  shouldBeWarning: shouldBeWarning,
                                ),
                                label: AppLocalizations.of(context)!.profile,
                              ),
                            ],
                          )),
                    ));
        }));
  }
}
