import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';

class DisableTwoFactorAuthenticationUseCase {
  final AuthRepository authRepository;

  DisableTwoFactorAuthenticationUseCase(this.authRepository);

  /// Disable OTP authentication for the user.
  Future<Either<DomainError, bool>> call() async {
    return await authRepository.disableTwoFactorAuthentication();
  }
}
