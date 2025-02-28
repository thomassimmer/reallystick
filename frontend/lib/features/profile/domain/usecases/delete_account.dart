import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class DeleteAccountUsecase {
  final ProfileRepository profileRepository;

  DeleteAccountUsecase(this.profileRepository);

  Future<Either<DomainError, void>> call() async {
    return await profileRepository.deleteAccount();
  }
}
