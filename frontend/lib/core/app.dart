import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/router.dart';
import 'package:reallystick/core/ui/themes/dark.dart';
import 'package:reallystick/core/ui/themes/light.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth_login/auth_login_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_creation/challenge_creation_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_creation/challenge_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_update/challenge_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_update/challenge_update_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_bloc.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_update/private_message_update_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/set_password/set_password_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/update_password/update_password_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_report_creation/public_message_report_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_update/public_message_update_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:universal_io/io.dart';

class ReallyStickApp extends StatefulWidget {
  ReallyStickApp({Key? key}) : super(key: key);

  @override
  State<ReallyStickApp> createState() => ReallyStickAppState();
}

class ReallyStickAppState extends State<ReallyStickApp> {
  late List<BlocProvider> providers;

  @override
  void initState() {
    super.initState();
    providers = _createBlocProviders();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: providers,
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
            routerConfig: GetIt.instance<AppRouter>().router,
            locale: locale,
            theme: themeData,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        }));
  }

  List<BlocProvider> _createBlocProviders() {
    return [
      BlocProvider<AuthSignupFormBloc>.value(
        value: GetIt.instance<AuthSignupFormBloc>(),
      ),
      BlocProvider<AuthBloc>.value(
        value: GetIt.instance<AuthBloc>(),
      ),
      BlocProvider<NotificationBloc>.value(
        value: GetIt.instance<NotificationBloc>(),
      ),
      BlocProvider<ProfileBloc>.value(
        value: GetIt.instance<ProfileBloc>(),
      ),
      BlocProvider<ProfileSetPasswordFormBloc>.value(
        value: GetIt.instance<ProfileSetPasswordFormBloc>(),
      ),
      BlocProvider<ProfileUpdatePasswordFormBloc>.value(
        value: GetIt.instance<ProfileUpdatePasswordFormBloc>(),
      ),
      BlocProvider<HabitBloc>.value(
        value: GetIt.instance<HabitBloc>(),
      ),
      BlocProvider<HabitCreationFormBloc>.value(
        value: GetIt.instance<HabitCreationFormBloc>(),
      ),
      BlocProvider<HabitReviewFormBloc>.value(
        value: GetIt.instance<HabitReviewFormBloc>(),
      ),
      BlocProvider<HabitMergeFormBloc>.value(
        value: GetIt.instance<HabitMergeFormBloc>(),
      ),
      BlocProvider<HabitDailyTrackingCreationFormBloc>.value(
        value: GetIt.instance<HabitDailyTrackingCreationFormBloc>(),
      ),
      BlocProvider<HabitDailyTrackingUpdateFormBloc>.value(
        value: GetIt.instance<HabitDailyTrackingUpdateFormBloc>(),
      ),
      BlocProvider<ChallengeBloc>.value(
        value: GetIt.instance<ChallengeBloc>(),
      ),
      BlocProvider<ChallengeCreationFormBloc>.value(
        value: GetIt.instance<ChallengeCreationFormBloc>(),
      ),
      BlocProvider<ChallengeUpdateFormBloc>.value(
        value: GetIt.instance<ChallengeUpdateFormBloc>(),
      ),
      BlocProvider<ChallengeDailyTrackingCreationFormBloc>.value(
        value: GetIt.instance<ChallengeDailyTrackingCreationFormBloc>(),
      ),
      BlocProvider<ChallengeDailyTrackingUpdateFormBloc>.value(
        value: GetIt.instance<ChallengeDailyTrackingUpdateFormBloc>(),
      ),
      BlocProvider<UserBloc>.value(
        value: GetIt.instance<UserBloc>(),
      ),
      BlocProvider<PublicMessageBloc>.value(
        value: GetIt.instance<PublicMessageBloc>(),
      ),
      BlocProvider<PublicMessageCreationFormBloc>.value(
        value: GetIt.instance<PublicMessageCreationFormBloc>(),
      ),
      BlocProvider<PublicMessageUpdateFormBloc>.value(
        value: GetIt.instance<PublicMessageUpdateFormBloc>(),
      ),
      BlocProvider<PublicMessageReportCreationFormBloc>.value(
        value: GetIt.instance<PublicMessageReportCreationFormBloc>(),
      ),
      BlocProvider<ThreadBloc>.value(
        value: GetIt.instance<ThreadBloc>(),
      ),
      BlocProvider<ReplyBloc>.value(
        value: GetIt.instance<ReplyBloc>(),
      ),
      BlocProvider<PrivateMessageBloc>.value(
        value: GetIt.instance<PrivateMessageBloc>(),
      ),
      BlocProvider<PrivateDiscussionBloc>.value(
        value: GetIt.instance<PrivateDiscussionBloc>(),
      ),
      BlocProvider<PrivateMessageCreationFormBloc>.value(
        value: GetIt.instance<PrivateMessageCreationFormBloc>(),
      ),
      BlocProvider<PrivateMessageUpdateFormBloc>.value(
        value: GetIt.instance<PrivateMessageUpdateFormBloc>(),
      ),
    ];
  }
}
