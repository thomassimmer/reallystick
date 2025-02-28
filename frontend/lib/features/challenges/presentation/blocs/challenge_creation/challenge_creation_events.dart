import 'package:equatable/equatable.dart';

sealed class ChallengeCreationFormEvent extends Equatable {
  const ChallengeCreationFormEvent();

  @override
  List<Object?> get props => [];
}

class ChallengeCreationFormNameChangedEvent extends ChallengeCreationFormEvent {
  final Map<String, String> name;

  const ChallengeCreationFormNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class ChallengeCreationFormDescriptionChangedEvent
    extends ChallengeCreationFormEvent {
  final Map<String, String> description;

  const ChallengeCreationFormDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class ChallengeCreationFormIconChangedEvent extends ChallengeCreationFormEvent {
  final String icon;

  const ChallengeCreationFormIconChangedEvent(this.icon);

  @override
  List<Object?> get props => [icon];
}

class ChallengeCreationFormStartDateChangedEvent
    extends ChallengeCreationFormEvent {
  final DateTime? startDate;

  const ChallengeCreationFormStartDateChangedEvent(this.startDate);

  @override
  List<Object?> get props => [startDate];
}

class ChallengeCreationFormEndDateChangedEvent
    extends ChallengeCreationFormEvent {
  final DateTime? endDate;

  const ChallengeCreationFormEndDateChangedEvent(this.endDate);

  @override
  List<Object?> get props => [endDate];
}
