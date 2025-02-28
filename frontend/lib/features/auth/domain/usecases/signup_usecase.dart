import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/storage/private_message_key_storage.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:reallystick/features/auth/domain/entities/user_token.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  Future<Either<DomainError, UserToken>> call({
    required String username,
    required String password,
    required String locale,
    required String theme,
    required String publicKey,
    required String privateKey,
    required String privateKeyEncrypted,
    required String saltUsedToDeriveKeyFromPassword,
  }) async {
    final result = await authRepository.signup(
      username: username,
      password: password,
      locale: locale,
      theme: theme,
      publicKey: publicKey,
      privateKeyEncrypted: privateKeyEncrypted,
      saltUsedToDeriveKeyFromPassword: saltUsedToDeriveKeyFromPassword,
    );

    await result.fold((_) async {}, (userToken) async {
      // Store tokens securely after successful login
      await TokenStorage().saveTokens(
        userToken.accessToken,
        userToken.refreshToken,
      );

      await PrivateMessageKeyStorage().saveKeys(
        publicKey,
        privateKey,
      );
    });

    return result;
  }
}
