import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_categories_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_participations_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habits_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habits_usecase.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final AuthBloc authBloc;
  late StreamSubscription authBlocSubscription;
  final GetHabitParticipationsUsecase getHabitParticipationsUsecase =
      GetIt.instance<GetHabitParticipationsUsecase>();
  final GetHabitCategoriesUseCase getHabitCategoriesUseCase =
      GetIt.instance<GetHabitCategoriesUseCase>();
  final GetHabitsUsecase getHabitsUsecase = GetIt.instance<GetHabitsUsecase>();
  final GetHabitsDailyTrackingUsecase getHabitsDailyTrackingUsecase =
      GetIt.instance<GetHabitsDailyTrackingUsecase>();

  HabitBloc({required this.authBloc}) : super(HabitsLoading()) {
    authBlocSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticatedState) {
        add(HabitInitializeEvent());
      }
    });

    on<HabitInitializeEvent>(_initialize);
  }

  Future<void> _initialize(
      HabitInitializeEvent event, Emitter<HabitState> emit) async {
    final resultGetHabitCategoriesUseCase =
        await getHabitCategoriesUseCase.call();

    await resultGetHabitCategoriesUseCase.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
      } else {
        emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
      }
    }, (habitCategories) async {
      final resultOfGetHabitsUsecase = await getHabitsUsecase.call();

      await resultOfGetHabitsUsecase.fold((error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
        }
      }, (habits) async {
        final resultOfGetHabitParticipationsUsecase =
            await getHabitParticipationsUsecase.call();

        await resultOfGetHabitParticipationsUsecase.fold((error) {
          if (error is ShouldLogoutError) {
            authBloc
                .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
          } else {
            emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
          }
        }, (habitParticipations) async {
          final resultOfGetHabitsDailyTrackingUsecase =
              await getHabitsDailyTrackingUsecase.call();

          resultOfGetHabitsDailyTrackingUsecase.fold((error) {
            if (error is ShouldLogoutError) {
              authBloc.add(
                  AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
            } else {
              emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
            }
          }, (habitDailyTrackings) {
            emit(HabitsLoaded(
              habitParticipations: habitParticipations,
              habits: Map.fromEntries(
                  habits.map((habit) => MapEntry(habit.id, habit))),
              habitDailyTrackings: habitDailyTrackings,
              habitCategories: Map.fromEntries(habitCategories.map(
                  (habitCategory) =>
                      MapEntry(habitCategory.id, habitCategory))),
            ));
          });
        });
      });
    });
  }
}
