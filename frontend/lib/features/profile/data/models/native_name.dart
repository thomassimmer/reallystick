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
