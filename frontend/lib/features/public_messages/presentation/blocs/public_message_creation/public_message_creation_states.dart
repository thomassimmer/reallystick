import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/public_message_content.dart';

final class PublicMessageCreationFormState extends Equatable {
  final PublicMessageContentValidator content;
  final bool isValid;
  final String? errorMessage;

  const PublicMessageCreationFormState({
    this.content = const PublicMessageContentValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        content,
        isValid,
        errorMessage,
      ];

  PublicMessageCreationFormState copyWith({
    PublicMessageContentValidator? content,
    bool? isValid,
    String? errorMessage,
  }) {
    return PublicMessageCreationFormState(
      content: content ?? this.content,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
