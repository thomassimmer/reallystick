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
