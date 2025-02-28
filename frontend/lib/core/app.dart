import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/router.dart';
import 'package:reallystick/core/ui/themes/dark.dart';
import 'package:reallystick/core/ui/themes/light.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth_login/auth_login_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/set_password/set_password_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/update_password/update_password_bloc.dart';
import 'package:universal_io/io.dart';

class ReallyStickApp extends StatelessWidget {
  const ReallyStickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: _createBlocProviders(),
        child:
            BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
          Locale locale =
              Locale(Platform.localeName); // device locale by default

          final Brightness brightness =
              MediaQuery.of(context).platformBrightness;
          ThemeData themeData = brightness == Brightness.dark
              ? DarkAppTheme().themeData
              : LightAppTheme().themeData;

          if (state.profile != null) {
            locale = Locale(state.profile!.locale);
            themeData = state.profile!.theme == 'dark'
                ? DarkAppTheme().themeData
                : LightAppTheme().themeData;
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            locale: locale,
            theme: themeData,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        }));
  }

  List<BlocProvider> _createBlocProviders() {
    final authBloc = AuthBloc();
    final authSignupFormBloc = AuthSignupFormBloc();
    final profileBloc = ProfileBloc(authBloc: authBloc);
    final profileSetPasswordFormBloc = ProfileSetPasswordFormBloc();
    final profileUpdatePasswordFormBloc = ProfileUpdatePasswordFormBloc();
    final habitBloc = HabitBloc(authBloc: authBloc);
    final habitCreationFormBloc = HabitCreationFormBloc();
    final habitReviewFormBloc = HabitReviewFormBloc();
    final habitMergeFormBloc = HabitMergeFormBloc();
    final habitDailyTrackingCreationFormBloc =
        HabitDailyTrackingCreationFormBloc();
    final habitDailyTrackingUpdateFormBloc = HabitDailyTrackingUpdateFormBloc();

    authBloc.add(AuthInitializeEvent());

    return [
      BlocProvider<AuthSignupFormBloc>(
        create: (context) => authSignupFormBloc,
      ),
      BlocProvider<AuthBloc>(
        create: (context) => authBloc,
      ),
      BlocProvider<ProfileBloc>(
        create: (context) => profileBloc,
      ),
      BlocProvider<ProfileSetPasswordFormBloc>(
        create: (context) => profileSetPasswordFormBloc,
      ),
      BlocProvider<ProfileUpdatePasswordFormBloc>(
        create: (context) => profileUpdatePasswordFormBloc,
      ),
      BlocProvider<HabitBloc>(
        create: (context) => habitBloc,
      ),
      BlocProvider<HabitCreationFormBloc>(
        create: (context) => habitCreationFormBloc,
      ),
      BlocProvider<HabitReviewFormBloc>(
        create: (context) => habitReviewFormBloc,
      ),
      BlocProvider<HabitMergeFormBloc>(
        create: (context) => habitMergeFormBloc,
      ),
      BlocProvider<HabitDailyTrackingCreationFormBloc>(
        create: (context) => habitDailyTrackingCreationFormBloc,
      ),
      BlocProvider<HabitDailyTrackingUpdateFormBloc>(
        create: (context) => habitDailyTrackingUpdateFormBloc,
      ),
    ];
  }
}
