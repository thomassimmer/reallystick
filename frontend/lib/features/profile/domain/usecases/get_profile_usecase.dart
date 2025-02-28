import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository profileRepository;

  GetProfileUsecase(this.profileRepository);

  Future<Either<DomainError, Profile>> call() async {
    return await profileRepository.getProfileInformation();
  }
}
