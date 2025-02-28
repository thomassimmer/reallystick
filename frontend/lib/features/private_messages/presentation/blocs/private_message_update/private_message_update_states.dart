import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/private_message_content.dart';

final class PrivateMessageUpdateFormState extends Equatable {
  final PrivateMessageContentValidator content;
  final bool isValid;
  final String? errorMessage;

  const PrivateMessageUpdateFormState({
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

  PrivateMessageUpdateFormState copyWith({
    PrivateMessageContentValidator? content,
    bool? isValid,
    String? errorMessage,
  }) {
    return PrivateMessageUpdateFormState(
      content: content ?? this.content,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
