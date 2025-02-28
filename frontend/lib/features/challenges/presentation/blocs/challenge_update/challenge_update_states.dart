import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/challenge_datetime.dart';
import 'package:reallystick/core/validators/challenge_name.dart';
import 'package:reallystick/core/validators/description.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/password.dart';

final class ChallengeUpdateFormState extends Equatable {
  final Map<String, ChallengeNameValidator> name;
  final Map<String, DescriptionValidator> description;
  final IconValidator icon;
  final ChallengeDatetime startDate;
  final ChallengeDatetime endDate;
  final bool isValid;
  final String? errorMessage;

  const ChallengeUpdateFormState({
    this.name = const {},
    this.description = const {},
    this.icon = const IconValidator.pure(),
    this.startDate = const ChallengeDatetime.pure(),
    this.endDate = const ChallengeDatetime.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        name,
        icon,
        description,
        startDate,
        endDate,
        isValid,
        errorMessage,
      ];

  ChallengeUpdateFormState copyWith({
    Map<String, ChallengeNameValidator>? name,
    Map<String, DescriptionValidator>? description,
    IconValidator? icon,
    ChallengeDatetime? startDate,
    ChallengeDatetime? endDate,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return ChallengeUpdateFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
