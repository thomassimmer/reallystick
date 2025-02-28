import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/profile/data/models/country.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class LoadCountriesUseCase {
  final ProfileRepository profileRepository;

  LoadCountriesUseCase(this.profileRepository);

  Future<Either<DomainError, List<Country>>> call() async {
    return await profileRepository.loadCountries();
  }
}
