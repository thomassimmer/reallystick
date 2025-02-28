import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:reallystick/features/auth/domain/entities/user_token.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';

class RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase {
  final AuthRepository authRepository;

  RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase(
      this.authRepository);

  Future<Either<DomainError, UserToken>> call(
      {required String username, required String recoveryCode}) async {
    final result = await authRepository
        .recoverAccountWithoutTwoFactorAuthenticationEnabled(
      username: username,
      recoveryCode: recoveryCode,
    );

    await result.fold((_) async {}, (userToken) async {
      // Store tokens securely after successful login
      await TokenStorage().saveTokens(
        userToken.accessToken,
        userToken.refreshToken,
      );
    });

    return result;
  }
}
