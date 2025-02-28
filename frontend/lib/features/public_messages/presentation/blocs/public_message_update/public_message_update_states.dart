import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/public_message_content.dart';

final class PublicMessageUpdateFormState extends Equatable {
  final PublicMessageContentValidator content;
  final bool isValid;
  final String? errorMessage;

  const PublicMessageUpdateFormState({
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

  PublicMessageUpdateFormState copyWith({
    PublicMessageContentValidator? content,
    bool? isValid,
    String? errorMessage,
  }) {
    return PublicMessageUpdateFormState(
      content: content ?? this.content,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
