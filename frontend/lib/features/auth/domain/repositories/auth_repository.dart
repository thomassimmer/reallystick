import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/domain/entities/two_factor_authentication_config.dart';
import 'package:reallystick/features/auth/domain/entities/user_data_before_otp_verified.dart';
import 'package:reallystick/features/auth/domain/entities/user_token.dart';

abstract class AuthRepository {
  Future<Either<DomainError, UserToken>> signup({
    required String username,
    required String password,
    required String locale,
    required String theme,
    required String publicKey,
    required String privateKeyEncrypted,
    required String saltUsedToDeriveKeyFromPassword,
  });

  Future<Either<DomainError, Either<UserToken, UserDataBeforeOtpVerified>>>
      login({
    required String username,
    required String password,
  });

  Future<Either<DomainError, TwoFactorAuthenticationConfig>>
      generateTwoFactorAuthenticationConfig();

  Future<Either<DomainError, bool>> verifyOneTimePassword({
    required String code,
  });

  Future<Either<DomainError, UserToken>> validateOneTimePassword({
    required String userId,
    required String code,
  });

  Future<Either<DomainError, bool>> disableTwoFactorAuthentication();

  Future<Either<DomainError, bool>>
      checkIfAccountHasTwoFactorAuthenticationEnabled({
    required String username,
  });

  Future<Either<DomainError, UserToken>>
      recoverAccountWithTwoFactorAuthenticationAndPassword({
    required String username,
    required String password,
    required String recoveryCode,
  });

  Future<Either<DomainError, UserToken>>
      recoverAccountWithTwoFactorAuthenticationAndOneTimePassword({
    required String username,
    required String recoveryCode,
    required String code,
  });

  Future<Either<DomainError, UserToken>>
      recoverAccountWithoutTwoFactorAuthenticationEnabled({
    required String username,
    required String recoveryCode,
  });

  Future<Either<DomainError, void>> logout();

  Future<Either<DomainError, void>> saveKeys({
    required String publicKey,
    required String privateKeyEncrypted,
    required String saltUsedToDeriveKeyFromPassword,
  });

  Future<Either<DomainError, void>> saveRecoveryCode({
    required String recoveryCode,
    required String privateKeyEncrypted,
    required String saltUsedToDeriveKeyFromRecoveryCode,
  });
}
