import 'package:reallystick/features/profile/data/models/country_name.dart';
import 'package:reallystick/features/profile/data/models/flags.dart';

class Country {
  final Flags flags;
  final CountryName name;
  final String region;

  Country({
    required this.flags,
    required this.name,
    required this.region,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      flags: Flags.fromJson(json['flags']),
      name: CountryName.fromJson(json['name']),
      region: json['region'] as String,
    );
  }
}
