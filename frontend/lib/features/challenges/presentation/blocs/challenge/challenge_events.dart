import 'package:equatable/equatable.dart';

abstract class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => [];
}

class ChallengeInitializeEvent extends ChallengeEvent {}

class CreateChallengeEvent extends ChallengeEvent {
  final Map<String, String> name;
  final Map<String, String> description;
  final int icon;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateChallengeEvent({
    required this.name,
    required this.description,
    required this.icon,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        icon,
        startDate,
        endDate,
      ];
}

class UpdateChallengeEvent extends ChallengeEvent {
  final String challengeId;
  final Map<String, String> name;
  final Map<String, String> description;
  final int icon;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateChallengeEvent({
    required this.challengeId,
    required this.name,
    required this.description,
    required this.icon,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        challengeId,
        name,
        description,
        icon,
        startDate,
        endDate,
      ];
}

class CreateChallengeDailyTrackingEvent extends ChallengeEvent {
  final String challengeId;
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const CreateChallengeDailyTrackingEvent({
    required this.challengeId,
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  @override
  List<Object?> get props => [
        challengeId,
        habitId,
        datetime,
        quantityOfSet,
        quantityPerSet,
        unitId,
        weight,
        weightUnitId,
      ];
}

class UpdateChallengeDailyTrackingEvent extends ChallengeEvent {
  final String challengeDailyTrackingId;
  final String challengeId;
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const UpdateChallengeDailyTrackingEvent({
    required this.challengeDailyTrackingId,
    required this.challengeId,
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  @override
  List<Object?> get props => [
        challengeDailyTrackingId,
        challengeId,
        datetime,
        quantityOfSet,
        quantityPerSet,
        unitId,
        weight,
        weightUnitId,
      ];
}

class DeleteChallengeDailyTrackingEvent extends ChallengeEvent {
  final String challengeDailyTrackingId;
  final String challengeId;

  const DeleteChallengeDailyTrackingEvent({
    required this.challengeDailyTrackingId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [
        challengeDailyTrackingId,
        challengeId,
      ];
}

class CreateChallengeParticipationEvent extends ChallengeEvent {
  final String challengeId;
  final DateTime startDate;

  const CreateChallengeParticipationEvent(
      {required this.challengeId, required this.startDate});

  @override
  List<Object?> get props => [
        challengeId,
        startDate,
      ];
}

class DeleteChallengeParticipationEvent extends ChallengeEvent {
  final String challengeParticipationId;

  const DeleteChallengeParticipationEvent({
    required this.challengeParticipationId,
  });

  @override
  List<Object?> get props => [
        challengeParticipationId,
      ];
}

class UpdateChallengeParticipationEvent extends ChallengeEvent {
  final String challengeParticipationId;
  final String color;
  final DateTime startDate;

  const UpdateChallengeParticipationEvent({
    required this.challengeParticipationId,
    required this.color,
    required this.startDate,
  });

  @override
  List<Object?> get props => [
        challengeParticipationId,
        color,
        startDate,
      ];
}

class GetChallengeEvent extends ChallengeEvent {
  final String challengeId;

  const GetChallengeEvent({
    required this.challengeId,
  });

  @override
  List<Object?> get props => [challengeId];
}

class GetChallengeDailyTrackingsEvent extends ChallengeEvent {
  final String challengeId;

  const GetChallengeDailyTrackingsEvent({
    required this.challengeId,
  });

  @override
  List<Object?> get props => [challengeId];
}
