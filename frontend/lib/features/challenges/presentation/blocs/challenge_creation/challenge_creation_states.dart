import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/challenge_datetime.dart';
import 'package:reallystick/core/validators/challenge_description.dart';
import 'package:reallystick/core/validators/challenge_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/password.dart';

final class ChallengeCreationFormState extends Equatable {
  final Map<String, ChallengeNameValidator> name;
  final Map<String, ChallengeDescriptionValidator> description;
  final IconValidator icon;
  final ChallengeDatetime startDate;
  final bool isValid;
  final String? errorMessage;

  const ChallengeCreationFormState({
    this.name = const {},
    this.description = const {},
    this.icon = const IconValidator.pure(),
    this.startDate = const ChallengeDatetime.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        name,
        icon,
        description,
        startDate,
        isValid,
        errorMessage,
      ];

  ChallengeCreationFormState copyWith({
    Map<String, ChallengeNameValidator>? name,
    Map<String, ChallengeDescriptionValidator>? description,
    IconValidator? icon,
    ChallengeDatetime? startDate,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return ChallengeCreationFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      startDate: startDate ?? this.startDate,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
