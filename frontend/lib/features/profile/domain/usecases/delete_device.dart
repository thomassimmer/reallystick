import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class DeleteDeviceUseCase {
  final ProfileRepository profileRepository;

  DeleteDeviceUseCase(this.profileRepository);

  Future<Either<DomainError, void>> call(String deviceId) async {
    return await profileRepository.deleteDevice(deviceId);
  }
}
