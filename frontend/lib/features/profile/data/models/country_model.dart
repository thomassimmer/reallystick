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

class Flags {
  final String png;
  final String svg;
  final String? alt;

  Flags({
    required this.png,
    required this.svg,
    this.alt,
  });

  factory Flags.fromJson(Map<String, dynamic> json) {
    return Flags(
      png: json['png'] as String,
      svg: json['svg'] as String,
      alt: json['alt'] as String?,
    );
  }
}

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

class NativeName {
  final String common;
  final String official;

  NativeName({
    required this.common,
    required this.official,
  });

  factory NativeName.fromJson(Map<String, dynamic> json) {
    return NativeName(
      common: json['common'] as String,
      official: json['official'] as String,
    );
  }
}
