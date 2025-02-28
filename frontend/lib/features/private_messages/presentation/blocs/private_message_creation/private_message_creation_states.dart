import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/private_message_content.dart';

final class PrivateMessageCreationFormState extends Equatable {
  final PrivateMessageContentValidator content;
  final bool isValid;
  final String? errorMessage;

  const PrivateMessageCreationFormState({
    this.content = const PrivateMessageContentValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        content,
        isValid,
        errorMessage,
      ];

  PrivateMessageCreationFormState copyWith({
    PrivateMessageContentValidator? content,
    bool? isValid,
    String? errorMessage,
  }) {
    return PrivateMessageCreationFormState(
      content: content ?? this.content,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
