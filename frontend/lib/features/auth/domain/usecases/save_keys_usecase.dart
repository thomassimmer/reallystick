import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/storage/private_message_key_storage.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';

class SaveKeysUsecase {
  final AuthRepository authRepository;

  SaveKeysUsecase(this.authRepository);

  Future<Either<DomainError, void>> call({
    required String publicKey,
    required String privateKey,
    required String privateKeyEncrypted,
    required String saltUsedToDeriveKeyFromPassword,
  }) async {
    final result = await authRepository.saveKeys(
      publicKey: publicKey,
      privateKeyEncrypted: privateKeyEncrypted,
      saltUsedToDeriveKeyFromPassword: saltUsedToDeriveKeyFromPassword,
    );

    await result.fold(
      (_) async {},
      (_) async {
        await PrivateMessageKeyStorage().saveKeys(
          publicKey,
          privateKey,
        );
      },
    );

    return result;
  }
}
