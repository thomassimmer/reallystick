import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_daily_tracking_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_participation_usecase.dart';
import 'package:reallystick/features/habits/domain/usecases/create_habit_usecase.dart';
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
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final ProfileBloc profileBloc = GetIt.instance<ProfileBloc>();
  late StreamSubscription profileBlocSubscription;

  final GetHabitParticipationsUsecase getHabitParticipationsUsecase =
      GetIt.instance<GetHabitParticipationsUsecase>();
  final GetHabitCategoriesUseCase getHabitCategoriesUseCase =
      GetIt.instance<GetHabitCategoriesUseCase>();
  final GetHabitsUsecase getHabitsUsecase = GetIt.instance<GetHabitsUsecase>();
  final GetHabitsDailyTrackingUsecase getHabitsDailyTrackingUsecase =
      GetIt.instance<GetHabitsDailyTrackingUsecase>();
  final GetUnitsUsecase getUnitsUsecase = GetIt.instance<GetUnitsUsecase>();
  final GetHabitStatisticsUsecase getHabitStatisticsUsecase =
      GetIt.instance<GetHabitStatisticsUsecase>();
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
  final UpdateHabitParticipationUsecase updateHabitParticipationUsecase =
      GetIt.instance<UpdateHabitParticipationUsecase>();
  final DeleteHabitParticipationUsecase deleteHabitParticipationUsecase =
      GetIt.instance<DeleteHabitParticipationUsecase>();

  HabitBloc() : super(HabitsLoading()) {
    profileBlocSubscription = profileBloc.stream.listen((profileState) {
      if (profileState is ProfileAuthenticated &&
          profileState.shouldReloadData) {
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
    on<CreateHabitParticipationEvent>(createHabitParticipation);
    on<UpdateHabitParticipationEvent>(updateHabitParticipation);
    on<DeleteHabitParticipationEvent>(deleteHabitParticipation);
  }

  @override
  Future<void> close() {
    profileBlocSubscription.cancel();
    return super.close();
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
                    final resultOfGetHabitStatisticsUsecase =
                        await getHabitStatisticsUsecase.call();

                    await resultOfGetHabitStatisticsUsecase.fold(
                      (error) {
                        if (error is ShouldLogoutError) {
                          authBloc.add(AuthLogoutEvent(
                              message: ErrorMessage(error.messageKey)));
                        } else {
                          emit(HabitsFailed(
                              message: ErrorMessage(error.messageKey)));
                        }
                      },
                      (habitStatistics) async {
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
                                habitCategories: Map.fromEntries(habitCategories
                                    .map((habitCategory) => MapEntry(
                                        habitCategory.id, habitCategory))),
                                units: Map.fromEntries(units
                                    .map((unit) => MapEntry(unit.id, unit))),
                                habitStatistics: Map.fromEntries(habitStatistics
                                    .map((habitStatistic) => MapEntry(
                                        habitStatistic.habitId,
                                        habitStatistic))),
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
      },
    );
  }

  Future<void> createHabit(
      CreateHabitEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    final resultCreateHabitUsecase = await createHabitUsecase.call(
      categoryId: event.categoryId,
      name: event.name,
      description: event.description,
      icon: event.icon,
      unitIds: event.unitIds,
    );

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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habit) async {
        final resultCreateHabitParticipationUsecase =
            await createHabitParticipationUsecase.call(
          habitId: habit.id,
          color: AppColorExtension.getRandomColor().toShortString(),
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
                  habitStatistics: currentState.habitStatistics,
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
                habitStatistics: currentState.habitStatistics,
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
    final resultUpdateHabitUsecase = await updateHabitUsecase.call(
      habitId: event.habitId,
      categoryId: event.categoryId,
      name: event.name,
      description: event.description,
      icon: event.icon,
      reviewed: true,
      unitIds: event.unitIds,
    );

    resultUpdateHabitUsecase.fold(
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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habit) {
        currentState.habits[habit.id] = habit;
        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            habitStatistics: currentState.habitStatistics,
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
    final resultMergeHabitsUseCase = await mergeHabitsUsecase.call(
      habitToDeleteId: event.habitToDeleteId,
      habitToMergeOnId: event.habitToMergeOnId,
      categoryId: event.categoryId,
      name: event.name,
      description: event.description,
      icon: event.icon,
      reviewed: true,
      unitIds: event.unitIds,
    );

    resultMergeHabitsUseCase.fold(
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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habit) {
        for (var habitParticipation in currentState.habitParticipations) {
          if (habitParticipation.habitId == event.habitToDeleteId) {
            // Replace habitParticipation with old id only if there isn't already a habitParticipation with the new one
            // Because there can be only one habitParticipation for a couple (user, habit).
            if (currentState.habitParticipations
                .where((hp) => hp.habitId == event.habitToMergeOnId)
                .isEmpty) {
              habitParticipation.habitId = event.habitToMergeOnId;
            }
          }
        }

        final newHabitDailyTrackings =
            currentState.habitDailyTrackings.map((hdt) {
          if (hdt.habitId == event.habitToDeleteId) {
            return hdt.copyWith(habitId: event.habitToMergeOnId);
          }
          return hdt;
        }).toList();

        currentState.habits.remove(event.habitToDeleteId);
        currentState.habits[habit.id] = habit;

        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: newHabitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            habitStatistics: currentState.habitStatistics,
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

    final resultCreateHabitDailyTrackingUsecase =
        await createHabitDailyTrackingUsecase.call(
      datetime: event.datetime,
      habitId: event.habitId,
      quantityOfSet: event.quantityOfSet,
      quantityPerSet: event.quantityPerSet,
      unitId: event.unitId,
      weight: event.weight,
      weightUnitId: event.weightUnitId,
      challengeDailyTracking: event.challengeDailyTracking,
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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habitDailyTracking) {
        final newHabitDailyTrackings =
            List<HabitDailyTracking>.from(currentState.habitDailyTrackings)
              ..add(habitDailyTracking);

        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: newHabitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            habitStatistics: currentState.habitStatistics,
            message: SuccessMessage("habitDailyTrackingCreated"),
          ),
        );
      },
    );
  }

  Future<void> updateHabitDailyTracking(
      UpdateHabitDailyTrackingEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    final resultUpdateHabitDailyTrackingUsecase =
        await updateHabitDailyTrackingUsecase.call(
      habitDailyTrackingId: event.habitDailyTrackingId,
      datetime: event.datetime,
      quantityOfSet: event.quantityOfSet,
      quantityPerSet: event.quantityPerSet,
      unitId: event.unitId,
      weight: event.weight,
      weightUnitId: event.weightUnitId,
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
              habitStatistics: currentState.habitStatistics,
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
            habitStatistics: currentState.habitStatistics,
            message: SuccessMessage("habitDailyTrackingUpdated"),
          ),
        );
      },
    );
  }

  Future<void> deleteHabitDailyTracking(
      DeleteHabitDailyTrackingEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
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
              habitStatistics: currentState.habitStatistics,
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
            habitStatistics: currentState.habitStatistics,
            message: SuccessMessage("habitDailyTrackingDeleted"),
          ),
        );
      },
    );
  }

  Future<void> createHabitParticipation(
      CreateHabitParticipationEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    final resultCreateHabitParticipationUsecase =
        await createHabitParticipationUsecase.call(
      habitId: event.habitId,
      color: AppColorExtension.getRandomColor().toShortString(),
      toGain: true,
    );

    resultCreateHabitParticipationUsecase.fold(
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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habitParticipation) {
        currentState.habitParticipations.add(habitParticipation);
        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: currentState.habitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            habitStatistics: currentState.habitStatistics,
            message: SuccessMessage("habitParticipationCreated"),
          ),
        );
      },
    );
  }

  Future<void> updateHabitParticipation(
      UpdateHabitParticipationEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    final resultUpdateHabitParticipationUsecase =
        await updateHabitParticipationUsecase.call(
      habitParticipationId: event.habitParticipationId,
      color: event.color,
      toGain: true,
      notificationsReminderEnabled: event.notificationsReminderEnabled,
      reminderTime: event.reminderTime,
      reminderBody: event.reminderBody,
    );

    resultUpdateHabitParticipationUsecase.fold(
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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (habitParticipation) {
        final newHabitParticipations = currentState.habitParticipations
            .where((hdt) => hdt.id != habitParticipation.id)
            .toList();
        newHabitParticipations.add(habitParticipation);
        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: newHabitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            habitStatistics: currentState.habitStatistics,
            message: SuccessMessage("habitParticipationUpdated"),
          ),
        );
      },
    );
  }

  Future<void> deleteHabitParticipation(
      DeleteHabitParticipationEvent event, Emitter<HabitState> emit) async {
    final currentState = state as HabitsLoaded;
    final resultDeleteHabitParticipationUsecase =
        await deleteHabitParticipationUsecase.call(
      habitParticipationId: event.habitParticipationId,
    );

    resultDeleteHabitParticipationUsecase.fold(
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
              habitStatistics: currentState.habitStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        final newHabitParticipations = currentState.habitParticipations
            .where((hdt) => hdt.id != event.habitParticipationId)
            .toList();

        emit(
          HabitsLoaded(
            habitCategories: currentState.habitCategories,
            habitDailyTrackings: currentState.habitDailyTrackings,
            habitParticipations: newHabitParticipations,
            habits: currentState.habits,
            units: currentState.units,
            habitStatistics: currentState.habitStatistics,
            message: SuccessMessage("habitParticipationDeleted"),
          ),
        );
      },
    );
  }
}
