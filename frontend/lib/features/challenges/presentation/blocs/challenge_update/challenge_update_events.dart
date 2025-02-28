import 'package:equatable/equatable.dart';

sealed class ChallengeUpdateFormEvent extends Equatable {
  const ChallengeUpdateFormEvent();

  @override
  List<Object?> get props => [];
}

class ChallengeUpdateFormNameChangedEvent extends ChallengeUpdateFormEvent {
  final Map<String, String> name;

  const ChallengeUpdateFormNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class ChallengeUpdateFormDescriptionChangedEvent
    extends ChallengeUpdateFormEvent {
  final Map<String, String> description;

  const ChallengeUpdateFormDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class ChallengeUpdateFormIconChangedEvent extends ChallengeUpdateFormEvent {
  final String icon;

  const ChallengeUpdateFormIconChangedEvent(this.icon);

  @override
  List<Object?> get props => [icon];
}

class ChallengeUpdateFormStartDateChangedEvent
    extends ChallengeUpdateFormEvent {
  final DateTime? startDate;

  const ChallengeUpdateFormStartDateChangedEvent(this.startDate);

  @override
  List<Object?> get props => [startDate];
}

class ChallengeUpdateFormEndDateChangedEvent extends ChallengeUpdateFormEvent {
  final DateTime? endDate;

  const ChallengeUpdateFormEndDateChangedEvent(this.endDate);

  @override
  List<Object?> get props => [endDate];
}
