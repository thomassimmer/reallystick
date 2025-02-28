import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/screens/error_screen.dart';
import 'package:reallystick/core/presentation/screens/root_screen.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/auth/presentation/screens/login_screen.dart';
import 'package:reallystick/features/auth/presentation/screens/recover_account_screen.dart';
import 'package:reallystick/features/auth/presentation/screens/recovery_codes_screen.dart';
import 'package:reallystick/features/auth/presentation/screens/signup_screen.dart';
import 'package:reallystick/features/auth/presentation/screens/unauthenticated_home_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/create_challenge_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/search_challenges_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/update_challenge_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/all_habits_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/create_habit_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/habit_detail_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/habits_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/review_habit_screen.dart';
import 'package:reallystick/features/habits/presentation/screens/search_habits_screen.dart';
import 'package:reallystick/features/messages/presentation/messages_screen.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/profile/presentation/screens/about_screen.dart';
import 'package:reallystick/features/profile/presentation/screens/language_selection_screen.dart';
import 'package:reallystick/features/profile/presentation/screens/password_screen.dart';
import 'package:reallystick/features/profile/presentation/screens/profile_information_screen.dart';
import 'package:reallystick/features/profile/presentation/screens/profile_screen.dart';
import 'package:reallystick/features/profile/presentation/screens/theme_selection_screen.dart';
import 'package:reallystick/features/profile/presentation/screens/two_factor_authentication_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  routes: [
    // ShellRoute for authenticated users
    ShellRoute(
      builder: (context, state, child) {
        return RootScreen(child: child); // Main screen for authenticated users
      },
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;

        if (authState is AuthUnauthenticatedState) {
          return '/welcome'; // Redirect unauthenticated users to welcome
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) =>
              HabitsScreen(), // Authenticated user's home
        ),
        GoRoute(
          path: '/habits',
          name: 'habits',
          builder: (context, state) => HabitsScreen(),
          routes: [
            GoRoute(
              path: 'search',
              name: 'habitSearch',
              builder: (context, state) => SearchHabitsScreen(),
            ),
            GoRoute(
              path: 'create',
              name: 'createHabit',
              builder: (context, state) => CreateHabitScreen(),
            ),
            GoRoute(
              path: 'all',
              name: 'allHabits',
              builder: (context, state) => AllHabitsScreen(),
              redirect: (context, state) {
                final profileState = context.read<ProfileBloc>().state;

                if (profileState is ProfileAuthenticated &&
                    !profileState.profile.isAdmin) {
                  return '/habits'; // Redirect non admin users to main page of habits
                }

                return null;
              },
            ),
            GoRoute(
              path: 'review/:habitId',
              name: 'reviewHabit',
              builder: (context, state) {
                final habitId = state.pathParameters['habitId']!;

                return ReviewHabitScreen(habitId: habitId);
              },
              redirect: (context, state) {
                final profileState = context.read<ProfileBloc>().state;

                if (profileState is ProfileAuthenticated &&
                    !profileState.profile.isAdmin) {
                  return '/habits'; // Redirect non admin users to main page of habits
                }

                return null;
              },
            ),
            GoRoute(
              path: ':habitId',
              name: 'habitDetails',
              builder: (context, state) {
                final habitId = state.pathParameters['habitId']!;

                return HabitDetailsScreen(
                  habitId: habitId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/challenges',
          name: 'challenges',
          builder: (context, state) => ChallengesScreen(),
          routes: [
            GoRoute(
              path: 'search',
              name: 'challengeSearch',
              builder: (context, state) => SearchChallengesScreen(),
            ),
            GoRoute(
              path: 'create',
              name: 'createChallenge',
              builder: (context, state) => CreateChallengeScreen(),
            ),
            GoRoute(
              path: 'update/:challengeId',
              name: 'updateChallenge',
              builder: (context, state) {
                final challengeId = state.pathParameters['challengeId']!;

                return UpdateChallengeScreen(challengeId: challengeId);
              },
            ),
            GoRoute(
              path: ':challengeId',
              name: 'challengeDetails',
              builder: (context, state) {
                final challengeId = state.pathParameters['challengeId']!;

                return ChallengeDetailsScreen(
                  challengeId: challengeId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/messages',
          name: 'messages',
          builder: (context, state) => MessagesScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => ProfileScreen(),
          routes: [
            GoRoute(
              path: 'language',
              name: 'language',
              builder: (context, state) => LocaleSelectionScreen(),
            ),
            GoRoute(
              path: 'theme',
              name: 'theme',
              builder: (context, state) => ThemeSelectionScreen(),
            ),
            GoRoute(
              path: 'two-factor-authentication',
              name: 'two-factor-authentication',
              builder: (context, state) => TwoFactorAuthenticationScreen(),
            ),
            GoRoute(
              path: 'password',
              name: 'password',
              builder: (context, state) => PasswordScreen(),
            ),
            GoRoute(
              path: 'about',
              name: 'about',
              builder: (context, state) => AboutScreen(),
            ),
            GoRoute(
              path: 'profile-information',
              name: 'profile-information',
              builder: (context, state) => ProfileInformationScreen(),
            ),
          ],
        ),
      ],
    ),

    // Welcome route for unauthenticated users
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) =>
          UnauthenticatedHomeScreen(), // Welcome screen for unauthenticated users
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticatedState) {
          return '/'; // Redirect authenticated users to home
        }
        return null;
      },
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticatedState) {
          return '/'; // Redirect authenticated users to home
        }
        return null;
      },
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => SignupScreen(),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticatedState) {
          return '/'; // Redirect authenticated users to home
        }
        return null;
      },
    ),
    GoRoute(
      path: '/recovery-codes',
      name: 'recovery-codes',
      builder: (context, state) => RecoveryCodesScreen(),
    ),
    GoRoute(
      path: '/recover-account',
      name: 'recover-account',
      builder: (context, state) => RecoverAccountScreen(),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticatedState) {
          return '/'; // Redirect authenticated users to home
        }
        return null;
      },
    ),
  ],
);
