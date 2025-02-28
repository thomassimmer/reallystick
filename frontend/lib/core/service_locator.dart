import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/network/auth_interceptor.dart';
import 'package:reallystick/core/network/expired_token_retry_policy.dart';
import 'package:reallystick/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:reallystick/features/auth/data/services/auth_service.dart';
import 'package:reallystick/features/auth/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';
import 'package:reallystick/features/auth/domain/usecases/check_if_account_has_two_factor_authentication_enabled_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/disable_two_factor_authentication_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/generate_two_factor_authentication_config_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/login_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_without_two_factor_authentication_enabled_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/signup_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/validate_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/verify_one_time_password_use_case.dart';
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
import 'package:reallystick/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:reallystick/features/profile/data/sources/local_data_sources.dart';
import 'package:reallystick/features/profile/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';
import 'package:reallystick/features/profile/domain/usecases/delete_account.dart';
import 'package:reallystick/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:reallystick/features/profile/domain/usecases/load_countries.dart';
import 'package:reallystick/features/profile/domain/usecases/post_profile_usecase.dart';
import 'package:reallystick/features/profile/domain/usecases/set_password_use_case.dart';
import 'package:reallystick/features/profile/domain/usecases/update_password_use_case.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
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

  // Remote Data Sources
  sl.registerSingleton<AuthRemoteDataSource>(
      AuthRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<ProfileRemoteDataSource>(
      ProfileRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));
  sl.registerSingleton<ProfileLocalDataSource>(ProfileLocalDataSource());
  sl.registerSingleton<HabitRemoteDataSource>(
      HabitRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl));

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

  // Use cases
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl<AuthRepository>()));
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
}
