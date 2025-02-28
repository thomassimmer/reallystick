import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/domain/repositories/auth_repository.dart';

class SaveRecoveryCodeUsecase {
  final AuthRepository authRepository;

  SaveRecoveryCodeUsecase(this.authRepository);

  Future<Either<DomainError, void>> call({
    required String recoveryCode,
    required String privateKeyEncrypted,
    required String saltUsedToDeriveKeyFromRecoveryCode,
  }) async {
    final result = await authRepository.saveRecoveryCode(
      recoveryCode: recoveryCode,
      privateKeyEncrypted: privateKeyEncrypted,
      saltUsedToDeriveKeyFromRecoveryCode: saltUsedToDeriveKeyFromRecoveryCode,
    );

    return result;
  }
}
