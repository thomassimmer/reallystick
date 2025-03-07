import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/presentation/widgets/icon_with_warning.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_events.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_states.dart';
import 'package:reallystick/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:reallystick/features/notifications/presentation/widgets/notification_button_widget.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/private_message_icon.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';

class RootScreen extends StatefulWidget {
  final Widget child;

  const RootScreen({required this.child});

  @override
  RootScreenState createState() => RootScreenState();
}

class RootScreenState extends State<RootScreen> {
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
      BlocProvider.of<NotificationBloc>(context).add(
        ChangeNotificationScreenVisibilityEvent(show: false),
      );

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
          GlobalSnackBar.show(context: context, message: state.message);

          if (state is AuthUnauthenticatedState) {
            context.goNamed('home');
          }
        }),
        BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
          GlobalSnackBar.show(context: context, message: state.message);
        }),
        BlocListener<HabitBloc, HabitState>(listener: (context, state) {
          GlobalSnackBar.show(context: context, message: state.message);
        }),
        BlocListener<PublicMessageBloc, PublicMessageState>(
            listener: (context, state) {
          GlobalSnackBar.show(context: context, message: state.message);
        }),
        BlocListener<PrivateDiscussionBloc, PrivateDiscussionState>(
            listener: (context, state) {
          GlobalSnackBar.show(context: context, message: state.message);
        }),
        BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
          GlobalSnackBar.show(
              context: context, message: state.message, hideCurrent: true);
        })
      ],
      child: Builder(
        builder: (context) {
          final profileState = context.watch<ProfileBloc>().state;
          final shouldBeWarning = profileState is ProfileAuthenticated &&
              profileState.profile.passwordIsExpired;
          final notificationState = context.watch<NotificationBloc>().state;

          return Scaffold(
            backgroundColor: context.colors.primary,
            appBar: AppBar(
              titleSpacing: 0,
              title: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      context.goNamed('home');
                    },
                    child: Row(
                      children: [
                        AppLogo(size: 50),
                        SizedBox(width: 10),
                        Text(
                          'Really',
                          style: context.typographies.headingSmall.copyWith(
                            color: context.colors.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Stick',
                          style: context.typographies.headingSmall.copyWith(
                            color: context.colors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: context.colors.primary,
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                    ),
                    child: NotificationButtonWidget(),
                  ),
                ),
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
                        height: 1.5,
                      ),
                      selectedLabelTextStyle: TextStyle(
                        color: context.colors.textOnPrimary,
                        height: 1.5,
                      ),
                      selectedIconTheme:
                          IconThemeData(color: context.colors.primary),
                      unselectedIconTheme:
                          IconThemeData(color: context.colors.textOnPrimary),
                      selectedIndex: _calculateSelectedIndex(context),
                      onDestinationSelected: onItemTapped,
                      labelType: NavigationRailLabelType.all,
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: Icon(Icons.check_circle_outline),
                          selectedIcon: Icon(
                            Icons.check_circle,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.habits,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.flag_outlined),
                          selectedIcon: Icon(Icons.flag),
                          label: Text(
                            AppLocalizations.of(context)!.challenges,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: PrivateMessageIcon(
                            iconData: Icons.message_outlined,
                          ),
                          selectedIcon: PrivateMessageIcon(
                            iconData: Icons.message,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.messages,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: IconWithWarning(
                              iconData: Icons.person_outline,
                              shouldBeWarning: shouldBeWarning),
                          selectedIcon: IconWithWarning(
                            iconData: Icons.person,
                            shouldBeWarning: shouldBeWarning,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.profile,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                isLargeScreen
                    ? Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.zero,
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.zero,
                            ),
                            color: context.colors.background,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: notificationState.notificationScreenIsVisible
                              ? NotificationsScreen()
                              : widget.child,
                        ),
                      )
                    : Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colors.background,
                          ),
                          child: notificationState.notificationScreenIsVisible
                              ? NotificationsScreen()
                              : widget.child,
                        ),
                      ),
              ],
            ),
            bottomNavigationBar: isLargeScreen
                ? null
                : NavigationBarTheme(
                    data: NavigationBarThemeData(
                      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
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
                      color: context.colors.background,
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
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              spreadRadius: 0,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
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
                                icon: PrivateMessageIcon(
                                  iconData: Icons.message_outlined,
                                ),
                                selectedIcon: PrivateMessageIcon(
                                  iconData: Icons.message,
                                ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
