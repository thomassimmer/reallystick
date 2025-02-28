import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_participation_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_usecase.dart';
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
  final CreateHabitUsecase createHabitUsecase =
      GetIt.instance<CreateHabitUsecase>();
  final CreateHabitParticipationUsecase createHabitParticipationUsecase =
      GetIt.instance<CreateHabitParticipationUsecase>();

  HabitBloc({required this.authBloc}) : super(HabitsLoading()) {
    authBlocSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticatedState) {
        add(HabitInitializeEvent());
      }
    });

    on<HabitInitializeEvent>(_initialize);
    on<CreateHabitEvent>(createHabit);
  }

  Future<void> _initialize(
      HabitInitializeEvent event, Emitter<HabitState> emit) async {
    final resultGetHabitCategoriesUseCase =
        await getHabitCategoriesUseCase.call();

    await resultGetHabitCategoriesUseCase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
        }
      },
      (habitCategories) async {
        final resultOfGetHabitsUsecase = await getHabitsUsecase.call();

        await resultOfGetHabitsUsecase.fold(
          (error) {
            if (error is ShouldLogoutError) {
              authBloc.add(
                  AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
            } else {
              emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
            }
          },
          (habits) async {
            final resultOfGetHabitParticipationsUsecase =
                await getHabitParticipationsUsecase.call();

            await resultOfGetHabitParticipationsUsecase.fold(
              (error) {
                if (error is ShouldLogoutError) {
                  authBloc.add(
                      AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
                } else {
                  emit(HabitsFailed(message: ErrorMessage(error.messageKey)));
                }
              },
              (habitParticipations) async {
                final resultOfGetHabitsDailyTrackingUsecase =
                    await getHabitsDailyTrackingUsecase.call();

                resultOfGetHabitsDailyTrackingUsecase.fold(
                  (error) {
                    if (error is ShouldLogoutError) {
                      authBloc.add(AuthLogoutEvent(
                          message: ErrorMessage(error.messageKey)));
                    } else {
                      emit(HabitsFailed(
                          message: ErrorMessage(error.messageKey)));
                    }
                  },
                  (habitDailyTrackings) {
                    emit(
                      HabitsLoaded(
                        habitParticipations: habitParticipations,
                        habits: Map.fromEntries(
                            habits.map((habit) => MapEntry(habit.id, habit))),
                        habitDailyTrackings: habitDailyTrackings,
                        habitCategories: Map.fromEntries(habitCategories.map(
                            (habitCategory) =>
                                MapEntry(habitCategory.id, habitCategory))),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> createHabit(
      CreateHabitEvent event, Emitter<HabitState> emit) async {
    final resultCreateHabitUsecase = await createHabitUsecase.call(
      categoryId: event.categoryId,
      shortName: Map.from({event.locale: event.shortName}),
      longName: Map.from({event.locale: event.longName}),
      description: Map.from({event.locale: event.description}),
      icon: "material::${event.icon.toString()}",
    );

    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    await resultCreateHabitUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            HabitsLoaded(
              habitCategories: currentState.habitCategories,
              habitDailyTrackings: currentState.habitDailyTrackings,
              habitParticipations: currentState.habitParticipations,
              habits: currentState.habits,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habit) async {
        final resultCreateHabitParticipationUsecase =
            await createHabitParticipationUsecase.call(
          habitId: habit.id,
          color: getRandomAppColor(),
          toGain: true,
        );

        resultCreateHabitParticipationUsecase.fold(
          (error) {
            if (error is ShouldLogoutError) {
              authBloc.add(
                  AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
            } else {
              emit(
                HabitsLoaded(
                  habitCategories: currentState.habitCategories,
                  habitDailyTrackings: currentState.habitDailyTrackings,
                  habitParticipations: currentState.habitParticipations,
                  habits: currentState.habits,
                  message: ErrorMessage(error.messageKey),
                ),
              );
            }
          },
          (habitParticipation) {
            currentState.habits[habit.id] = habit;
            currentState.habitParticipations.add(habitParticipation);
            emit(
              HabitsLoaded(
                habitCategories: currentState.habitCategories,
                habitDailyTrackings: currentState.habitDailyTrackings,
                habitParticipations: currentState.habitParticipations,
                habits: currentState.habits,
                message: SuccessMessage("habitCreated"),
                newlyCreatedHabit: habit,
              ),
            );
          },
        );
      },
    );
  }
}
