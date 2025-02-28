import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/public_message_content.dart';

final class PublicMessageReportCreationFormState extends Equatable {
  final PublicMessageContentValidator reason;
  final bool isValid;
  final String? errorMessage;

  const PublicMessageReportCreationFormState({
    this.reason = const PublicMessageContentValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        reason,
        isValid,
        errorMessage,
      ];

  PublicMessageReportCreationFormState copyWith({
    PublicMessageContentValidator? reason,
    bool? isValid,
    String? errorMessage,
  }) {
    return PublicMessageReportCreationFormState(
      reason: reason ?? this.reason,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
