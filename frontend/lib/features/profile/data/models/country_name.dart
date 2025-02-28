import 'package:reallystick/features/profile/data/models/native_name.dart';

class CountryName {
  final String common;
  final String official;
  final Map<String, NativeName> nativeName;

  CountryName({
    required this.common,
    required this.official,
    required this.nativeName,
  });

  factory CountryName.fromJson(Map<String, dynamic> json) {
    final nativeNamesMap =
        (json['nativeName'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, NativeName.fromJson(value)),
    );

    return CountryName(
      common: json['common'] as String,
      official: json['official'] as String,
      nativeName: nativeNamesMap,
    );
  }
}
