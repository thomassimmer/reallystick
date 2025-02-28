import 'package:reallystick/features/profile/data/models/country.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class LoadCountriesUseCase {
  final ProfileRepository profileRepository;

  LoadCountriesUseCase(this.profileRepository);

  Future<List<Country>> call() async {
    return await profileRepository.loadCountries();
  }
}
