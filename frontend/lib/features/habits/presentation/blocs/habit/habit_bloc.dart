import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_participation_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/delete_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_categories_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habit_participations_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habits_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_habits_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/get_units_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/merge_habits_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/update_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/update_habit_usecase.dart';
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
  final GetUnitsUsecase getUnitsUsecase = GetIt.instance<GetUnitsUsecase>();
  final CreateHabitUsecase createHabitUsecase =
      GetIt.instance<CreateHabitUsecase>();
  final CreateHabitParticipationUsecase createHabitParticipationUsecase =
      GetIt.instance<CreateHabitParticipationUsecase>();
  final CreateHabitDailyTrackingUsecase createHabitDailyTrackingUsecase =
      GetIt.instance<CreateHabitDailyTrackingUsecase>();
  final MergeHabitsUsecase mergeHabitsUsecase =
      GetIt.instance<MergeHabitsUsecase>();
  final UpdateHabitUsecase updateHabitUsecase =
      GetIt.instance<UpdateHabitUsecase>();
  final UpdateHabitDailyTrackingUsecase updateHabitDailyTrackingUsecase =
      GetIt.instance<UpdateHabitDailyTrackingUsecase>();
  final DeleteHabitDailyTrackingUsecase deleteHabitDailyTrackingUsecase =
      GetIt.instance<DeleteHabitDailyTrackingUsecase>();

  HabitBloc({required this.authBloc}) : super(HabitsLoading()) {
    authBlocSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticatedState) {
        add(HabitInitializeEvent());
      }
    });

    on<HabitInitializeEvent>(_initialize);
    on<CreateHabitEvent>(createHabit);
    on<UpdateHabitEvent>(updateHabit);
    on<MergeHabitsEvent>(mergeHabits);
    on<CreateHabitDailyTrackingEvent>(createHabitDailyTracking);
    on<UpdateHabitDailyTrackingEvent>(updateHabitDailyTracking);
    on<DeleteHabitDailyTrackingEvent>(deleteHabitDailyTracking);
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

                await resultOfGetHabitsDailyTrackingUsecase.fold(
                  (error) {
                    if (error is ShouldLogoutError) {
                      authBloc.add(AuthLogoutEvent(
                          message: ErrorMessage(error.messageKey)));
                    } else {
                      emit(HabitsFailed(
                          message: ErrorMessage(error.messageKey)));
                    }
                  },
                  (habitDailyTrackings) async {
                    final resultOfGetUnitsUsecase =
                        await getUnitsUsecase.call();

                    resultOfGetUnitsUsecase.fold(
                      (error) {
                        if (error is ShouldLogoutError) {
                          authBloc.add(AuthLogoutEvent(
                              message: ErrorMessage(error.messageKey)));
                        } else {
                          emit(HabitsFailed(
                              message: ErrorMessage(error.messageKey)));
                        }
                      },
                      (units) {
                        emit(
                          HabitsLoaded(
                            habitParticipations: habitParticipations,
                            habits: Map.fromEntries(habits
                                .map((habit) => MapEntry(habit.id, habit))),
                            habitDailyTrackings: habitDailyTrackings,
                            habitCategories: Map.fromEntries(
                                habitCategories.map((habitCategory) =>
                                    MapEntry(habitCategory.id, habitCategory))),
                            units: Map.fromEntries(
                                units.map((unit) => MapEntry(unit.id, unit))),
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
      },
    );
  }

  Future<void> createHabit(
      CreateHabitEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    final resultCreateHabitUsecase = await createHabitUsecase.call(
        categoryId: event.categoryId,
        shortName: Map.from({event.locale: event.shortName}),
        longName: Map.from({event.locale: event.longName}),
        description: Map.from({event.locale: event.description}),
        icon: "material::${event.icon.toString()}",
        unitIds: event.unitIds);

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
              units: currentState.units,
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
                  units: currentState.units,
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
                units: currentState.units,
                message: SuccessMessage("habitCreated"),
                newlyCreatedHabit: habit,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateHabit(
      UpdateHabitEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    final resultUpdateHabitUsecase = await updateHabitUsecase.call(
      habitId: event.habitId,
      categoryId: event.categoryId,
      shortName: event.shortName,
      longName: event.longName,
      description: event.description,
      icon: "material::${event.icon.toString()}",
      reviewed: true,
      unitIds: event.unitIds,
    );

    await resultUpdateHabitUsecase.fold(
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
              units: currentState.units,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habit) async {
        currentState.habits[habit.id] = habit;
        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            message: SuccessMessage("habitUpdated"),
            newlyUpdatedHabit: habit,
          ),
        );
      },
    );
  }

  Future<void> mergeHabits(
      MergeHabitsEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    final resultMergeHabitsUseCase = await mergeHabitsUsecase.call(
      habitToDeleteId: event.habitToDeleteId,
      habitToMergeOnId: event.habitToMergeOnId,
      categoryId: event.categoryId,
      shortName: event.shortName,
      longName: event.longName,
      description: event.description,
      icon: "material::${event.icon.toString()}",
      reviewed: true,
      unitIds: event.unitIds,
    );

    await resultMergeHabitsUseCase.fold(
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
              units: currentState.units,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habit) async {
        for (var habitParticipation in currentState.habitParticipations) {
          if (habitParticipation.habitId == event.habitToDeleteId) {
            habitParticipation.habitId = event.habitToMergeOnId;
          }
        }
        for (var habitDailyTracking in currentState.habitDailyTrackings) {
          if (habitDailyTracking.habitId == event.habitToDeleteId) {
            habitDailyTracking.habitId = event.habitToMergeOnId;
          }
        }
        currentState.habits.remove(event.habitToDeleteId);
        currentState.habits[habit.id] = habit;

        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            message: SuccessMessage("habitUpdated"),
            newlyUpdatedHabit: habit,
          ),
        );
      },
    );
  }

  Future<void> createHabitDailyTracking(
      CreateHabitDailyTrackingEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    final resultCreateHabitDailyTrackingUsecase =
        await createHabitDailyTrackingUsecase.call(
      datetime: event.datetime,
      habitId: event.habitId,
      quantityOfSet: event.quantityOfSet,
      quantityPerSet: event.quantityPerSet,
      unitId: event.unitId,
    );

    resultCreateHabitDailyTrackingUsecase.fold(
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
              units: currentState.units,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habitDailyTracking) {
        currentState.habitDailyTrackings.add(habitDailyTracking);
        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            message: SuccessMessage("habitDailyTrackingCreated"),
          ),
        );
      },
    );
  }

  Future<void> updateHabitDailyTracking(
      UpdateHabitDailyTrackingEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    final resultUpdateHabitDailyTrackingUsecase =
        await updateHabitDailyTrackingUsecase.call(
      habitDailyTrackingId: event.habitDailyTrackingId,
      datetime: event.datetime,
      quantityOfSet: event.quantityOfSet,
      quantityPerSet: event.quantityPerSet,
      unitId: event.unitId,
    );

    resultUpdateHabitDailyTrackingUsecase.fold(
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
              units: currentState.units,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habitDailyTracking) {
        final newHabitDailyTrackings = currentState.habitDailyTrackings
            .where((hdt) => hdt.id != habitDailyTracking.id)
            .toList();
        newHabitDailyTrackings.add(habitDailyTracking);
        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: newHabitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            message: SuccessMessage("habitDailyTrackingUpdated"),
          ),
        );
      },
    );
  }

  Future<void> deleteHabitDailyTracking(
      DeleteHabitDailyTrackingEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    emit(HabitsLoading());

    final resultDeleteHabitDailyTrackingUsecase =
        await deleteHabitDailyTrackingUsecase.call(
      habitDailyTrackingId: event.habitDailyTrackingId,
    );

    resultDeleteHabitDailyTrackingUsecase.fold(
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
              units: currentState.units,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        final newHabitDailyTrackings = currentState.habitDailyTrackings
            .where((hdt) => hdt.id != event.habitDailyTrackingId)
            .toList();

        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: newHabitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            message: SuccessMessage("habitDailyTrackingDeleted"),
          ),
        );
      },
    );
  }
}
