import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/profile/domain/entities/statistics.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class GetStatisticsUsecase {
  final ProfileRepository profileRepository;

  GetStatisticsUsecase(this.profileRepository);

  Future<Either<DomainError, Statistics>> call() async {
    return await profileRepository.getStatistics();
  }
}
