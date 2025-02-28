import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/usecases/create_challenge_daily_tracking_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/create_challenge_participation_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/create_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/delete_challenge_daily_tracking_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/delete_challenge_participation_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/delete_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_daily_trackings_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_participations_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_statistics_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenge_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenges_daily_trackings_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/get_challenges_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/update_challenge_daily_tracking_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/update_challenge_participation_usecase.dart';
import 'package:reallystick/features/challenges/domain/usecases/update_challenge_usecase.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';

class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  final AuthBloc authBloc;
  late StreamSubscription authBlocSubscription;
  final GetChallengeParticipationsUsecase getChallengeParticipationsUsecase =
      GetIt.instance<GetChallengeParticipationsUsecase>();
  final GetChallengesUsecase getChallengesUsecase =
      GetIt.instance<GetChallengesUsecase>();
  final GetChallengeDailyTrackingsUsecase getChallengeDailyTrackingsUsecase =
      GetIt.instance<GetChallengeDailyTrackingsUsecase>();
  final GetChallengeStatisticsUsecase getChallengeStatisticsUsecase =
      GetIt.instance<GetChallengeStatisticsUsecase>();
  final CreateChallengeUsecase createChallengeUsecase =
      GetIt.instance<CreateChallengeUsecase>();
  final CreateChallengeParticipationUsecase
      createChallengeParticipationUsecase =
      GetIt.instance<CreateChallengeParticipationUsecase>();
  final CreateChallengeDailyTrackingUsecase
      createChallengeDailyTrackingUsecase =
      GetIt.instance<CreateChallengeDailyTrackingUsecase>();
  final UpdateChallengeUsecase updateChallengeUsecase =
      GetIt.instance<UpdateChallengeUsecase>();
  final UpdateChallengeDailyTrackingUsecase
      updateChallengeDailyTrackingUsecase =
      GetIt.instance<UpdateChallengeDailyTrackingUsecase>();
  final DeleteChallengeDailyTrackingUsecase
      deleteChallengeDailyTrackingUsecase =
      GetIt.instance<DeleteChallengeDailyTrackingUsecase>();
  final UpdateChallengeParticipationUsecase
      updateChallengeParticipationUsecase =
      GetIt.instance<UpdateChallengeParticipationUsecase>();
  final DeleteChallengeParticipationUsecase
      deleteChallengeParticipationUsecase =
      GetIt.instance<DeleteChallengeParticipationUsecase>();
  final DeleteChallengeUsecase deleteChallengeUsecase =
      GetIt.instance<DeleteChallengeUsecase>();
  final GetChallengeUsecase getChallengeUsecase =
      GetIt.instance<GetChallengeUsecase>();
  final GetChallengesDailyTrackingsUsecase getChallengesDailyTrackingsUsecase =
      GetIt.instance<GetChallengesDailyTrackingsUsecase>();

  ChallengeBloc({required this.authBloc}) : super(ChallengesLoading()) {
    authBlocSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticatedState) {
        add(ChallengeInitializeEvent());
      }
    });

    on<ChallengeInitializeEvent>(_initialize);
    on<CreateChallengeEvent>(createChallenge);
    on<UpdateChallengeEvent>(updateChallenge);
    on<CreateChallengeDailyTrackingEvent>(createChallengeDailyTracking);
    on<UpdateChallengeDailyTrackingEvent>(updateChallengeDailyTracking);
    on<DeleteChallengeDailyTrackingEvent>(deleteChallengeDailyTracking);
    on<CreateChallengeParticipationEvent>(createChallengeParticipation);
    on<UpdateChallengeParticipationEvent>(updateChallengeParticipation);
    on<DeleteChallengeParticipationEvent>(deleteChallengeParticipation);
    on<DeleteChallengeEvent>(deleteChallenge);
    on<GetChallengeEvent>(_getChallenge);
    on<GetChallengeDailyTrackingsEvent>(_getChallengeDailyTrackings);
  }

  Future<void> _initialize(
      ChallengeInitializeEvent event, Emitter<ChallengeState> emit) async {
    final resultOfGetChallengesUsecase = await getChallengesUsecase.call();

    await resultOfGetChallengesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(ChallengesFailed(message: ErrorMessage(error.messageKey)));
        }
      },
      (challenges) async {
        final resultOfGetChallengeParticipationsUsecase =
            await getChallengeParticipationsUsecase.call();

        await resultOfGetChallengeParticipationsUsecase.fold(
          (error) {
            if (error is ShouldLogoutError) {
              authBloc.add(
                  AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
            } else {
              emit(ChallengesFailed(message: ErrorMessage(error.messageKey)));
            }
          },
          (challengeParticipations) async {
            final resultOfGetChallengeStatisticsUsecase =
                await getChallengeStatisticsUsecase.call();

            await resultOfGetChallengeStatisticsUsecase.fold(
              (error) {
                if (error is ShouldLogoutError) {
                  authBloc.add(
                      AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
                } else {
                  emit(ChallengesFailed(
                      message: ErrorMessage(error.messageKey)));
                }
              },
              (challengeStatistics) async {
                final resultOfGetChallengesDailyTrackingsUsecase =
                    await getChallengesDailyTrackingsUsecase.call(
                        challengeIds: challenges.map((c) => c.id).toList());

                resultOfGetChallengesDailyTrackingsUsecase.fold(
                  (error) {
                    if (error is ShouldLogoutError) {
                      authBloc.add(AuthLogoutEvent(
                          message: ErrorMessage(error.messageKey)));
                    } else {
                      emit(ChallengesFailed(
                          message: ErrorMessage(error.messageKey)));
                    }
                  },
                  (challengesDailyTrackings) {
                    Map<String, List<ChallengeDailyTracking>>
                        mapOfDailyTrackings = Map.fromEntries(
                      challenges.map(
                        (challenge) => MapEntry(challenge.id, []),
                      ),
                    );
                    for (final challengeDailyTracking
                        in challengesDailyTrackings) {
                      mapOfDailyTrackings[challengeDailyTracking.challengeId]!
                          .add(challengeDailyTracking);
                    }

                    emit(
                      ChallengesLoaded(
                        challengeParticipations: challengeParticipations,
                        challenges: Map.fromEntries(challenges.map(
                            (challenge) => MapEntry(challenge.id, challenge))),
                        challengeDailyTrackings: mapOfDailyTrackings,
                        challengeStatistics: Map.fromEntries(challengeStatistics
                            .map((challengeStatistic) => MapEntry(
                                challengeStatistic.challengeId,
                                challengeStatistic))),
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

  Future<void> createChallenge(
      CreateChallengeEvent event, Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultCreateChallengeUsecase = await createChallengeUsecase.call(
      name: event.name,
      description: event.description,
      icon: "material::${event.icon.toString()}",
      startDate: event.startDate,
    );

    await resultCreateChallengeUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challenge) async {
        final resultCreateChallengeParticipationUsecase =
            await createChallengeParticipationUsecase.call(
          challengeId: challenge.id,
          color: AppColorExtension.getRandomColor().toShortString(),
          startDate: DateTime.now(),
        );

        resultCreateChallengeParticipationUsecase.fold(
          (error) {
            if (error is ShouldLogoutError) {
              authBloc.add(
                  AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
            } else {
              emit(
                ChallengesLoaded(
                  challengeDailyTrackings: currentState.challengeDailyTrackings,
                  challengeParticipations: currentState.challengeParticipations,
                  challenges: currentState.challenges,
                  challengeStatistics: currentState.challengeStatistics,
                  message: ErrorMessage(error.messageKey),
                ),
              );
            }
          },
          (challengeParticipation) {
            currentState.challenges[challenge.id] = challenge;
            currentState.challengeParticipations.add(challengeParticipation);
            emit(
              ChallengesLoaded(
                challengeDailyTrackings: currentState.challengeDailyTrackings,
                challengeParticipations: currentState.challengeParticipations,
                challenges: currentState.challenges,
                challengeStatistics: currentState.challengeStatistics,
                message: SuccessMessage("challengeCreated"),
                newlyCreatedChallenge: challenge,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateChallenge(
      UpdateChallengeEvent event, Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultUpdateChallengeUsecase = await updateChallengeUsecase.call(
      challengeId: event.challengeId,
      name: event.name,
      description: event.description,
      icon: "material::${event.icon.toString()}",
      startDate: event.startDate,
    );

    resultUpdateChallengeUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challenge) {
        currentState.challenges[challenge.id] = challenge;
        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeUpdated"),
            newlyUpdatedChallenge: challenge,
          ),
        );
      },
    );
  }

  Future<void> createChallengeDailyTracking(
      CreateChallengeDailyTrackingEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultCreateChallengeDailyTrackingUsecase =
        await createChallengeDailyTrackingUsecase.call(
      habitId: event.habitId,
      dayOfProgram: event.dayOfProgram,
      challengeId: event.challengeId,
      quantityOfSet: event.quantityOfSet,
      quantityPerSet: event.quantityPerSet,
      unitId: event.unitId,
      weight: event.weight,
      weightUnitId: event.weightUnitId,
      repeat: event.repeat,
    );

    resultCreateChallengeDailyTrackingUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challengeDailyTrackings) {
        currentState.challengeDailyTrackings[event.challengeId]!
            .addAll(challengeDailyTrackings);
        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeDailyTrackingCreated"),
          ),
        );
      },
    );
  }

  Future<void> updateChallengeDailyTracking(
      UpdateChallengeDailyTrackingEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultUpdateChallengeDailyTrackingUsecase =
        await updateChallengeDailyTrackingUsecase.call(
      challengeDailyTrackingId: event.challengeDailyTrackingId,
      habitId: event.habitId,
      dayOfProgram: event.dayOfProgram,
      quantityOfSet: event.quantityOfSet,
      quantityPerSet: event.quantityPerSet,
      unitId: event.unitId,
      weight: event.weight,
      weightUnitId: event.weightUnitId,
    );

    resultUpdateChallengeDailyTrackingUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challengeDailyTracking) {
        final newChallengeDailyTrackingsForThisChallenge = currentState
            .challengeDailyTrackings[event.challengeId]!
            .where((hdt) => hdt.id != challengeDailyTracking.id)
            .toList();
        newChallengeDailyTrackingsForThisChallenge.add(challengeDailyTracking);
        final newChallengeDailyTrackings = currentState.challengeDailyTrackings;
        newChallengeDailyTrackings[event.challengeId] =
            newChallengeDailyTrackingsForThisChallenge;

        emit(
          ChallengesLoaded(
            challengeDailyTrackings: newChallengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeDailyTrackingUpdated"),
          ),
        );
      },
    );
  }

  Future<void> deleteChallengeDailyTracking(
      DeleteChallengeDailyTrackingEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultDeleteChallengeDailyTrackingUsecase =
        await deleteChallengeDailyTrackingUsecase.call(
      challengeDailyTrackingId: event.challengeDailyTrackingId,
    );

    resultDeleteChallengeDailyTrackingUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        final newChallengeDailyTrackingsForThisChallenge = currentState
            .challengeDailyTrackings[event.challengeId]!
            .where((hdt) => hdt.id != event.challengeDailyTrackingId)
            .toList();

        final newChallengeDailyTrackings = currentState.challengeDailyTrackings;
        newChallengeDailyTrackings[event.challengeId] =
            newChallengeDailyTrackingsForThisChallenge;

        emit(
          ChallengesLoaded(
            challengeDailyTrackings: newChallengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeDailyTrackingDeleted"),
          ),
        );
      },
    );
  }

  Future<void> createChallengeParticipation(
      CreateChallengeParticipationEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultCreateChallengeParticipationUsecase =
        await createChallengeParticipationUsecase.call(
      challengeId: event.challengeId,
      color: AppColorExtension.getRandomColor().toShortString(),
      startDate: event.startDate,
    );

    resultCreateChallengeParticipationUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challengeParticipation) {
        currentState.challengeParticipations.add(challengeParticipation);
        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeParticipationCreated"),
          ),
        );
      },
    );
  }

  Future<void> updateChallengeParticipation(
      UpdateChallengeParticipationEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultUpdateChallengeParticipationUsecase =
        await updateChallengeParticipationUsecase.call(
      challengeParticipationId: event.challengeParticipationId,
      color: event.color,
      startDate: event.startDate,
    );

    resultUpdateChallengeParticipationUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challengeParticipation) {
        final newChallengeParticipations = currentState.challengeParticipations
            .where((hdt) => hdt.id != challengeParticipation.id)
            .toList();
        newChallengeParticipations.add(challengeParticipation);
        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: newChallengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeParticipationUpdated"),
          ),
        );
      },
    );
  }

  Future<void> deleteChallengeParticipation(
      DeleteChallengeParticipationEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultDeleteChallengeParticipationUsecase =
        await deleteChallengeParticipationUsecase.call(
      challengeParticipationId: event.challengeParticipationId,
    );

    resultDeleteChallengeParticipationUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        final newChallengeParticipations = currentState.challengeParticipations
            .where((hdt) => hdt.id != event.challengeParticipationId)
            .toList();

        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: newChallengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
            message: SuccessMessage("challengeParticipationDeleted"),
          ),
        );
      },
    );
  }

  Future<void> deleteChallenge(
      DeleteChallengeEvent event, Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultDeleteChallengeUsecase = await deleteChallengeUsecase.call(
      challengeId: event.challengeId,
    );

    await resultDeleteChallengeUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) async {
        final newChallenges = currentState.challenges;
        newChallenges.remove(event.challengeId);

        if (event.challengeParticipationId != null) {
          final resultDeleteChallengeParticipationUsecase =
              await deleteChallengeParticipationUsecase.call(
            challengeParticipationId: event.challengeParticipationId!,
          );

          resultDeleteChallengeParticipationUsecase.fold(
            (error) {
              if (error is ShouldLogoutError) {
                authBloc.add(
                    AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
              } else {
                emit(
                  ChallengesLoaded(
                    challengeDailyTrackings:
                        currentState.challengeDailyTrackings,
                    challengeParticipations:
                        currentState.challengeParticipations,
                    challenges: newChallenges,
                    challengeStatistics: currentState.challengeStatistics,
                    message: ErrorMessage(error.messageKey),
                  ),
                );
              }
            },
            (_) {
              final newChallengeParticipations = currentState
                  .challengeParticipations
                  .where((hdt) => hdt.id != event.challengeParticipationId!)
                  .toList();

              emit(
                ChallengesLoaded(
                  challengeDailyTrackings: currentState.challengeDailyTrackings,
                  challengeParticipations: newChallengeParticipations,
                  challenges: newChallenges,
                  challengeStatistics: currentState.challengeStatistics,
                  message: SuccessMessage("challengeDeleted"),
                ),
              );
            },
          );
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: newChallenges,
              challengeStatistics: currentState.challengeStatistics,
              message: SuccessMessage("challengeDeleted"),
            ),
          );
        }
      },
    );
  }

  Future<void> _getChallenge(
      GetChallengeEvent event, Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultGetChallengeUsecase = await getChallengeUsecase.call(
      challengeId: event.challengeId,
    );

    await resultGetChallengeUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else if (error is ChallengeNotFoundDomainError) {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              notFoundChallenge: event.challengeId,
            ),
          );
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challenge) async {
        currentState.challenges[challenge.id] = challenge;
        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
          ),
        );
      },
    );
  }

  Future<void> _getChallengeDailyTrackings(
      GetChallengeDailyTrackingsEvent event,
      Emitter<ChallengeState> emit) async {
    final currentState = state as ChallengesLoaded;
    emit(ChallengesLoading());

    final resultGetChallengeDailyTrackingsUsecase =
        await getChallengeDailyTrackingsUsecase.call(
      challengeId: event.challengeId,
    );

    await resultGetChallengeDailyTrackingsUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc
              .add(AuthLogoutEvent(message: ErrorMessage(error.messageKey)));
        } else {
          emit(
            ChallengesLoaded(
              challengeDailyTrackings: currentState.challengeDailyTrackings,
              challengeParticipations: currentState.challengeParticipations,
              challenges: currentState.challenges,
              challengeStatistics: currentState.challengeStatistics,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (challengeDailyTrackings) async {
        currentState.challengeDailyTrackings[event.challengeId] =
            challengeDailyTrackings;
        emit(
          ChallengesLoaded(
            challengeDailyTrackings: currentState.challengeDailyTrackings,
            challengeParticipations: currentState.challengeParticipations,
            challenges: currentState.challenges,
            challengeStatistics: currentState.challengeStatistics,
          ),
        );
      },
    );
  }
}
