import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/profile/domain/entities/device.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class GetDevicesUsecase {
  final ProfileRepository profileRepository;

  GetDevicesUsecase(this.profileRepository);

  Future<Either<DomainError, List<Device>>> call() async {
    return await profileRepository.getDevices();
  }
}
