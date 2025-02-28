import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/network/auth_interceptor.dart';
import 'package:reallystick/core/network/expired_token_retry_policy.dart';
import 'package:reallystick/core/router.dart';
import 'package:reallystick/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:reallystick/features/auth/data/services/auth_service.dart';
import 'package:reallystick/features/auth/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';
import 'package:reallystick/features/auth/domain/usecases/check_if_account_has_two_factor_authentication_enabled_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/decrypt_key_using_derivated_key_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/derive_key_from_password_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/disable_two_factor_authentication_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/encrypt_key_using_derivated_key_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/generate_rsa_keys_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/generate_two_factor_authentication_config_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/login_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/logout_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_without_two_factor_authentication_enabled_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/save_keys_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/save_recovery_code_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/signup_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/validate_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/verify_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth_login/auth_login_bloc.dart';
import 'package:reallystick/features/challenges/data/repositories/challenge_daily_tracking_repository_impl.dart';
import 'package:reallystick/features/challenges/data/repositories/challenge_participation_repository_impl.dart';
import 'package:reallystick/features/challenges/data/repositories/challenge_repository_impl.dart';
import 'package:reallystick/features/challenges/data/repositories/challenge_statistic_repository_impl.dart';
import 'package:reallystick/features/challenges/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_daily_tracking_repository.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_participation_repository.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_statistic_repository.dart';
import 'package:reallystick/features/challenges/domain/usecases/create_challenge_daily_tracking_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/create_challenge_participation_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/create_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/delete_challenge_daily_tracking_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/delete_challenge_participation_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/delete_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/duplicate_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_daily_trackings_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_participations_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_statistics_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenges_daily_trackings_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenges_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/update_challenge_daily_tracking_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/update_challenge_participation_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/update_challenge_usecase.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_creation/challenge_creation_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_creation/challenge_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_update/challenge_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_update/challenge_update_bloc.dart';
import 'package:reallystick/features/habits/data/repositories/habit_category_repository_impl.dart';
import 'package:reallystick/features/habits/data/repositories/habit_daily_tracking_repository_impl.dart';
import 'package:reallystick/features/habits/data/repositories/habit_participation_repository_impl.dart';
import 'package:reallystick/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:reallystick/features/habits/data/repositories/habit_statistic_repository_impl.dart';
import 'package:reallystick/features/habits/data/repositories/unit_repository_impl.dart';
import 'package:reallystick/features/habits/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_category_repository.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_participation_repository.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_statistic_repository.dart';
import 'package:reallystick/features/habits/domain/repositories/unit_repository.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_participation_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_unit_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/delete_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/delete_habit_participation_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_categories_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_participations_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_statistics_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habits_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habits_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_units_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/merge_habits_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/update_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/update_habit_participation_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/update_unit_usecase.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_bloc.dart';
import 'package:reallystick/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:reallystick/features/notifications/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/notifications/domain/repositories/notification_repository.dart';
import 'package:reallystick/features/notifications/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/mark_notification_as_seen_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/save_fcm_token_usecase.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/private_messages/data/repositories/private_discussion_participation_repository_impl.dart';
import 'package:reallystick/features/private_messages/data/repositories/private_discussion_repository_impl.dart';
import 'package:reallystick/features/private_messages/data/repositories/private_message_repository_impl.dart';
import 'package:reallystick/features/private_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_participation_repository.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_repository.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_message_repository.dart';
import 'package:reallystick/features/private_messages/domain/usecases/create_private_discussion_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/create_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_symmetric_key_with_rsa_private_key_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/delete_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/encrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/encrypt_symmetric_key_with_rsa_public_key_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/get_private_discussions.dart';
import 'package:reallystick/features/private_messages/domain/usecases/get_private_messages_of_discussion_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/mark_private_message_as_seen_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/update_private_discussion_participation_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/update_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_update/private_message_update_bloc.dart';
import 'package:reallystick/features/notifications/presentation/helpers/websocket_service.dart';
import 'package:reallystick/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:reallystick/features/profile/data/sources/local_data_sources.dart';
import 'package:reallystick/features/profile/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';
import 'package:reallystick/features/profile/domain/usecases/delete_account.dart';
import 'package:reallystick/features/profile/domain/usecases/delete_device.dart';
import 'package:reallystick/features/profile/domain/usecases/get_devices.dart';
import 'package:reallystick/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:reallystick/features/profile/domain/usecases/load_countries.dart';
import 'package:reallystick/features/profile/domain/usecases/post_profile_usecase.dart';
import 'package:reallystick/features/profile/domain/usecases/set_password_use_case.dart';
import 'package:reallystick/features/profile/domain/usecases/update_password_use_case.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/set_password/set_password_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/update_password/update_password_bloc.dart';
import 'package:reallystick/features/public_messages/data/repositories/public_message_like_repository_impl.dart';
import 'package:reallystick/features/public_messages/data/repositories/public_message_report_repository_impl.dart';
import 'package:reallystick/features/public_messages/data/repositories/public_message_repository_impl.dart';
import 'package:reallystick/features/public_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_like_repository.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_report_repository.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';
import 'package:reallystick/features/public_messages/domain/usecases/create_public_message_like_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/create_public_message_report_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/create_public_message_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/delete_public_message_like_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/delete_public_message_report_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/delete_public_message_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_liked_messages_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_parents_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_reports_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_public_messages_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_replies_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_user_message_reports_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_written_messages_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/update_public_message_usecase.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_report_creation/public_message_report_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_update/public_message_update_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_bloc.dart';
import 'package:reallystick/features/users/data/repositories/user_public_data_repository_impl.dart';
import 'package:reallystick/features/users/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/users/domain/repositories/user_public_data_repository.dart';
import 'package:reallystick/features/users/domain/usecases/get_users_public_data_usecase.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final baseUrl = '${dotenv.env['API_BASE_URL']}/api';
  final tokenStorage = TokenStorage();
  final authService = AuthService(baseUrl: baseUrl, tokenStorage: tokenStorage);

  final apiClient = InterceptedClient.build(
    interceptors: [
      AuthInterceptor(baseUrl: baseUrl, tokenStorage: tokenStorage)
    ],
    requestTimeout: Duration(seconds: 15),
    retryPolicy: ExpiredTokenRetryPolicy(authService: authService),
  );

  // Router
  sl.registerSingleton<AppRouter>(AppRouter());

  // Remote Data Sources
  sl.registerSingleton<AuthRemoteDataSource>(
      AuthRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<ProfileRemoteDataSource>(
      ProfileRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<ProfileLocalDataSource>(ProfileLocalDataSource());
  sl.registerSingleton<HabitRemoteDataSource>(
      HabitRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<ChallengeRemoteDataSource>(
      ChallengeRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<PublicMessageRemoteDataSource>(
      PublicMessageRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<UserPublicDataRemoteDataSource>(
      UserPublicDataRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<PrivateMessageRemoteDataSource>(
      PrivateMessageRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<NotificationRemoteDataSource>(
      NotificationRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));

  // Repositories
  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(sl<AuthRemoteDataSource>()));
  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
      localDataSource: sl<ProfileLocalDataSource>()));
  sl.registerSingleton<HabitRepository>(
      HabitRepositoryImpl(remoteDataSource: sl<HabitRemoteDataSource>()));
  sl.registerSingleton<HabitParticipationRepository>(
      HabitParticipationRepositoryImpl(
          remoteDataSource: sl<HabitRemoteDataSource>()));
  sl.registerSingleton<HabitCategoryRepository>(HabitCategoryRepositoryImpl(
      remoteDataSource: sl<HabitRemoteDataSource>()));
  sl.registerSingleton<HabitDailyTrackingRepository>(
      HabitDailyTrackingRepositoryImpl(
          remoteDataSource: sl<HabitRemoteDataSource>()));
  sl.registerSingleton<UnitRepository>(
      UnitRepositoryImpl(remoteDataSource: sl<HabitRemoteDataSource>()));
  sl.registerSingleton<HabitStatisticRepository>(HabitStatisticRepositoryImpl(
      remoteDataSource: sl<HabitRemoteDataSource>()));
  sl.registerSingleton<ChallengeRepository>(ChallengeRepositoryImpl(
      remoteDataSource: sl<ChallengeRemoteDataSource>()));
  sl.registerSingleton<ChallengeParticipationRepository>(
      ChallengeParticipationRepositoryImpl(
          remoteDataSource: sl<ChallengeRemoteDataSource>()));
  sl.registerSingleton<ChallengeDailyTrackingRepository>(
      ChallengeDailyTrackingRepositoryImpl(
          remoteDataSource: sl<ChallengeRemoteDataSource>()));
  sl.registerSingleton<ChallengeStatisticRepository>(
      ChallengeStatisticRepositoryImpl(
          remoteDataSource: sl<ChallengeRemoteDataSource>()));
  sl.registerSingleton<PublicMessageLikeRepository>(
      PublicMessageLikeRepositoryImpl(
          remoteDataSource: sl<PublicMessageRemoteDataSource>()));
  sl.registerSingleton<PublicMessageRepository>(PublicMessageRepositoryImpl(
      remoteDataSource: sl<PublicMessageRemoteDataSource>()));
  sl.registerSingleton<PublicMessageReportRepository>(
      PublicMessageReportRepositoryImpl(
          remoteDataSource: sl<PublicMessageRemoteDataSource>()));
  sl.registerSingleton<UserPublicDataRepository>(UserPublicDataRepositoryImpl(
      remoteDataSource: sl<UserPublicDataRemoteDataSource>()));
  sl.registerSingleton<PrivateDiscussionRepository>(
      PrivateDiscussionRepositoryImpl(
          remoteDataSource: sl<PrivateMessageRemoteDataSource>()));
  sl.registerSingleton<PrivateDiscussionParticipationRepository>(
      PrivateDiscussionParticipationRepositoryImpl(
          remoteDataSource: sl<PrivateMessageRemoteDataSource>()));
  sl.registerSingleton<PrivateMessageRepository>(PrivateMessageRepositoryImpl(
      remoteDataSource: sl<PrivateMessageRemoteDataSource>()));
  sl.registerSingleton<NotificationRepository>(NotificationRepositoryImpl(
      remoteDataSource: sl<NotificationRemoteDataSource>()));

  // Use cases
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl<AuthRepository>()));
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase(sl<AuthRepository>()));
  sl.registerSingleton<SignupUseCase>(SignupUseCase(sl<AuthRepository>()));
  sl.registerSingleton<VerifyOneTimePasswordUseCase>(
      VerifyOneTimePasswordUseCase(sl<AuthRepository>()));
  sl.registerSingleton<ValidateOneTimePasswordUseCase>(
      ValidateOneTimePasswordUseCase(sl<AuthRepository>()));
  sl.registerSingleton<GenerateTwoFactorAuthenticationConfigUseCase>(
      GenerateTwoFactorAuthenticationConfigUseCase(sl<AuthRepository>()));
  sl.registerSingleton<DisableTwoFactorAuthenticationUseCase>(
      DisableTwoFactorAuthenticationUseCase(sl<AuthRepository>()));
  sl.registerSingleton<CheckIfAccountHasTwoFactorAuthenticationEnabledUseCase>(
      CheckIfAccountHasTwoFactorAuthenticationEnabledUseCase(
          sl<AuthRepository>()));
  sl.registerSingleton<
          RecoverAccountWithTwoFactorAuthenticationAndPasswordUseCase>(
      RecoverAccountWithTwoFactorAuthenticationAndPasswordUseCase(
          sl<AuthRepository>()));
  sl.registerSingleton<
          RecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase>(
      RecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase(
          sl<AuthRepository>()));
  sl.registerSingleton<
          RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase>(
      RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase(
          sl<AuthRepository>()));
  sl.registerSingleton<SaveKeysUsecase>(SaveKeysUsecase(sl<AuthRepository>()));
  sl.registerSingleton<SaveRecoveryCodeUsecase>(
      SaveRecoveryCodeUsecase(sl<AuthRepository>()));
  sl.registerSingleton<DecryptKeyUsingDerivatedKeyUsecase>(
      DecryptKeyUsingDerivatedKeyUsecase());
  sl.registerSingleton<DecryptMessageUsingAesUsecase>(
      DecryptMessageUsingAesUsecase());
  sl.registerSingleton<DeriveKeyFromPasswordUsecase>(
      DeriveKeyFromPasswordUsecase());
  sl.registerSingleton<EncryptKeyUsingDerivatedKeyUsecase>(
      EncryptKeyUsingDerivatedKeyUsecase());
  sl.registerSingleton<EncryptMessageUsingAesUsecase>(
      EncryptMessageUsingAesUsecase());
  sl.registerSingleton<GenerateRSAKeysUsecase>(GenerateRSAKeysUsecase());
  sl.registerSingleton<EncryptSymmetricKeyWithRsaPublicKeyUsecase>(
      EncryptSymmetricKeyWithRsaPublicKeyUsecase());
  sl.registerSingleton<DecryptSymmetricKeyWithRsaPrivateKeyUsecase>(
      DecryptSymmetricKeyWithRsaPrivateKeyUsecase());
  sl.registerSingleton<GetProfileUsecase>(
      GetProfileUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<PostProfileUsecase>(
      PostProfileUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<SetPasswordUseCase>(
      SetPasswordUseCase(sl<ProfileRepository>()));
  sl.registerSingleton<UpdatePasswordUseCase>(
      UpdatePasswordUseCase(sl<ProfileRepository>()));
  sl.registerSingleton<LoadCountriesUseCase>(
      LoadCountriesUseCase(sl<ProfileRepository>()));
  sl.registerSingleton<DeleteAccountUsecase>(
      DeleteAccountUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<GetHabitsUsecase>(
      GetHabitsUsecase(sl<HabitRepository>()));
  sl.registerSingleton<GetHabitCategoriesUseCase>(
      GetHabitCategoriesUseCase(sl<HabitCategoryRepository>()));
  sl.registerSingleton<GetHabitParticipationsUsecase>(
      GetHabitParticipationsUsecase(sl<HabitParticipationRepository>()));
  sl.registerSingleton<GetHabitsDailyTrackingUsecase>(
      GetHabitsDailyTrackingUsecase(sl<HabitDailyTrackingRepository>()));
  sl.registerSingleton<GetUnitsUsecase>(GetUnitsUsecase(sl<UnitRepository>()));
  sl.registerSingleton<GetHabitStatisticsUsecase>(
      GetHabitStatisticsUsecase(sl<HabitStatisticRepository>()));
  sl.registerSingleton<CreateHabitUsecase>(
      CreateHabitUsecase(sl<HabitRepository>()));
  sl.registerSingleton<CreateHabitParticipationUsecase>(
      CreateHabitParticipationUsecase(sl<HabitParticipationRepository>()));
  sl.registerSingleton<CreateUnitUsecase>(
      CreateUnitUsecase(sl<UnitRepository>()));
  sl.registerSingleton<CreateHabitDailyTrackingUsecase>(
      CreateHabitDailyTrackingUsecase(sl<HabitDailyTrackingRepository>()));
  sl.registerSingleton<MergeHabitsUsecase>(
      MergeHabitsUsecase(sl<HabitRepository>()));
  sl.registerSingleton<UpdateHabitUsecase>(
      UpdateHabitUsecase(sl<HabitRepository>()));
  sl.registerSingleton<UpdateUnitUsecase>(
      UpdateUnitUsecase(sl<UnitRepository>()));
  sl.registerSingleton<UpdateHabitDailyTrackingUsecase>(
      UpdateHabitDailyTrackingUsecase(sl<HabitDailyTrackingRepository>()));
  sl.registerSingleton<DeleteHabitDailyTrackingUsecase>(
      DeleteHabitDailyTrackingUsecase(sl<HabitDailyTrackingRepository>()));
  sl.registerSingleton<UpdateHabitParticipationUsecase>(
      UpdateHabitParticipationUsecase(sl<HabitParticipationRepository>()));
  sl.registerSingleton<DeleteHabitParticipationUsecase>(
      DeleteHabitParticipationUsecase(sl<HabitParticipationRepository>()));
  sl.registerSingleton<GetChallengesUsecase>(
      GetChallengesUsecase(sl<ChallengeRepository>()));
  sl.registerSingleton<GetChallengeUsecase>(
      GetChallengeUsecase(sl<ChallengeRepository>()));
  sl.registerSingleton<DuplicateChallengeUsecase>(
      DuplicateChallengeUsecase(sl<ChallengeRepository>()));
  sl.registerSingleton<GetChallengeParticipationsUsecase>(
      GetChallengeParticipationsUsecase(
          sl<ChallengeParticipationRepository>()));
  sl.registerSingleton<GetChallengeDailyTrackingsUsecase>(
      GetChallengeDailyTrackingsUsecase(
          sl<ChallengeDailyTrackingRepository>()));
  sl.registerSingleton<GetChallengeStatisticsUsecase>(
      GetChallengeStatisticsUsecase(sl<ChallengeStatisticRepository>()));
  sl.registerSingleton<CreateChallengeUsecase>(
      CreateChallengeUsecase(sl<ChallengeRepository>()));
  sl.registerSingleton<CreateChallengeParticipationUsecase>(
      CreateChallengeParticipationUsecase(
          sl<ChallengeParticipationRepository>()));
  sl.registerSingleton<CreateChallengeDailyTrackingUsecase>(
      CreateChallengeDailyTrackingUsecase(
          sl<ChallengeDailyTrackingRepository>()));
  sl.registerSingleton<UpdateChallengeUsecase>(
      UpdateChallengeUsecase(sl<ChallengeRepository>()));
  sl.registerSingleton<UpdateChallengeDailyTrackingUsecase>(
      UpdateChallengeDailyTrackingUsecase(
          sl<ChallengeDailyTrackingRepository>()));
  sl.registerSingleton<DeleteChallengeDailyTrackingUsecase>(
      DeleteChallengeDailyTrackingUsecase(
          sl<ChallengeDailyTrackingRepository>()));
  sl.registerSingleton<UpdateChallengeParticipationUsecase>(
      UpdateChallengeParticipationUsecase(
          sl<ChallengeParticipationRepository>()));
  sl.registerSingleton<DeleteChallengeParticipationUsecase>(
      DeleteChallengeParticipationUsecase(
          sl<ChallengeParticipationRepository>()));
  sl.registerSingleton<GetChallengesDailyTrackingsUsecase>(
      GetChallengesDailyTrackingsUsecase(
          sl<ChallengeDailyTrackingRepository>()));
  sl.registerSingleton<DeleteChallengeUsecase>(
      DeleteChallengeUsecase(sl<ChallengeRepository>()));
  sl.registerSingleton<GetDevicesUsecase>(
      GetDevicesUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<DeleteDeviceUseCase>(
      DeleteDeviceUseCase(sl<ProfileRepository>()));
  sl.registerSingleton<CreatePublicMessageLikeUsecase>(
      CreatePublicMessageLikeUsecase(sl<PublicMessageLikeRepository>()));
  sl.registerSingleton<CreatePublicMessageReportUsecase>(
      CreatePublicMessageReportUsecase(sl<PublicMessageReportRepository>()));
  sl.registerSingleton<CreatePublicMessageUsecase>(
      CreatePublicMessageUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<DeletePublicMessageLikeUsecase>(
      DeletePublicMessageLikeUsecase(sl<PublicMessageLikeRepository>()));
  sl.registerSingleton<DeletePublicMessageReportUsecase>(
      DeletePublicMessageReportUsecase(sl<PublicMessageReportRepository>()));
  sl.registerSingleton<DeletePublicMessageUsecase>(
      DeletePublicMessageUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<GetLikedMessagesUsecase>(
      GetLikedMessagesUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<GetMessageParentsUsecase>(
      GetMessageParentsUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<GetMessageReportsUsecase>(
      GetMessageReportsUsecase(sl<PublicMessageReportRepository>()));
  sl.registerSingleton<GetPublicMessagesUsecase>(
      GetPublicMessagesUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<GetRepliesUsecase>(
      GetRepliesUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<GetUserMessageReportsUsecase>(
      GetUserMessageReportsUsecase(sl<PublicMessageReportRepository>()));
  sl.registerSingleton<GetWrittenMessagesUsecase>(
      GetWrittenMessagesUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<UpdatePublicMessageUsecase>(
      UpdatePublicMessageUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<GetUsersPublicDataUsecase>(
      GetUsersPublicDataUsecase(sl<UserPublicDataRepository>()));
  sl.registerSingleton<GetMessageUsecase>(
      GetMessageUsecase(sl<PublicMessageRepository>()));
  sl.registerSingleton<CreatePrivateDiscussionUsecase>(
      CreatePrivateDiscussionUsecase(sl<PrivateDiscussionRepository>()));
  sl.registerSingleton<GetPrivateDiscussionsUsecase>(
      GetPrivateDiscussionsUsecase(sl<PrivateDiscussionRepository>()));
  sl.registerSingleton<CreatePrivateMessageUsecase>(
      CreatePrivateMessageUsecase(sl<PrivateMessageRepository>()));
  sl.registerSingleton<DeletePrivateMessageUsecase>(
      DeletePrivateMessageUsecase(sl<PrivateMessageRepository>()));
  sl.registerSingleton<GetPrivateMessagesOfDiscussionUsecase>(
      GetPrivateMessagesOfDiscussionUsecase(sl<PrivateMessageRepository>()));
  sl.registerSingleton<MarkPrivateMessageAsSeenUsecase>(
      MarkPrivateMessageAsSeenUsecase(sl<PrivateMessageRepository>()));
  sl.registerSingleton<UpdatePrivateMessageUsecase>(
      UpdatePrivateMessageUsecase(sl<PrivateMessageRepository>()));
  sl.registerSingleton<UpdatePrivateDiscussionParticipationUsecase>(
      UpdatePrivateDiscussionParticipationUsecase(
          sl<PrivateDiscussionParticipationRepository>()));
  sl.registerSingleton<GetNotificationsUsecase>(
      GetNotificationsUsecase(sl<NotificationRepository>()));
  sl.registerSingleton<MarkNotificationAsSeenUsecase>(
      MarkNotificationAsSeenUsecase(sl<NotificationRepository>()));
  sl.registerSingleton<DeleteNotificationUsecase>(
      DeleteNotificationUsecase(sl<NotificationRepository>()));
  sl.registerSingleton<DeleteAllNotificationsUsecase>(
      DeleteAllNotificationsUsecase(sl<NotificationRepository>()));
  sl.registerSingleton<SaveFcmTokenUsecase>(
      SaveFcmTokenUsecase(sl<NotificationRepository>()));

  // WebSocketService
  sl.registerSingleton<WebSocketService>(WebSocketService());

  // Blocs
  sl.registerSingleton<AuthBloc>(AuthBloc()..add(AuthInitializeEvent()));
  sl.registerSingleton<AuthSignupFormBloc>(AuthSignupFormBloc());
  sl.registerSingleton<ProfileBloc>(ProfileBloc());
  sl.registerSingleton<ProfileSetPasswordFormBloc>(
      ProfileSetPasswordFormBloc());
  sl.registerSingleton<ProfileUpdatePasswordFormBloc>(
      ProfileUpdatePasswordFormBloc());
  sl.registerSingleton<HabitBloc>(HabitBloc());
  sl.registerSingleton<HabitCreationFormBloc>(HabitCreationFormBloc());
  sl.registerSingleton<HabitReviewFormBloc>(HabitReviewFormBloc());
  sl.registerSingleton<HabitMergeFormBloc>(HabitMergeFormBloc());
  sl.registerSingleton<HabitDailyTrackingCreationFormBloc>(
      HabitDailyTrackingCreationFormBloc());
  sl.registerSingleton<HabitDailyTrackingUpdateFormBloc>(
      HabitDailyTrackingUpdateFormBloc());
  sl.registerSingleton<ChallengeBloc>(ChallengeBloc());
  sl.registerSingleton<ChallengeCreationFormBloc>(ChallengeCreationFormBloc());
  sl.registerSingleton<ChallengeUpdateFormBloc>(ChallengeUpdateFormBloc());
  sl.registerSingleton<ChallengeDailyTrackingCreationFormBloc>(
      ChallengeDailyTrackingCreationFormBloc());
  sl.registerSingleton<ChallengeDailyTrackingUpdateFormBloc>(
      ChallengeDailyTrackingUpdateFormBloc());
  sl.registerSingleton<UserBloc>(UserBloc());
  sl.registerSingleton<PublicMessageCreationFormBloc>(
      PublicMessageCreationFormBloc());
  sl.registerSingleton<PublicMessageUpdateFormBloc>(
      PublicMessageUpdateFormBloc());
  sl.registerSingleton<PublicMessageReportCreationFormBloc>(
      PublicMessageReportCreationFormBloc());
  sl.registerSingleton<ThreadBloc>(ThreadBloc());
  sl.registerSingleton<ReplyBloc>(ReplyBloc());
  sl.registerSingleton<PublicMessageBloc>(PublicMessageBloc());
  sl.registerSingleton<PrivateMessageBloc>(PrivateMessageBloc());
  sl.registerSingleton<NotificationBloc>(NotificationBloc());
  sl.registerSingleton<PrivateDiscussionBloc>(PrivateDiscussionBloc());
  sl.registerSingleton<PrivateMessageCreationFormBloc>(
      PrivateMessageCreationFormBloc());
  sl.registerSingleton<PrivateMessageUpdateFormBloc>(
      PrivateMessageUpdateFormBloc());
}
