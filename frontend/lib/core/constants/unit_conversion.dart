import 'package:reallystick/features/habits/domain/entities/unit.dart';

double normalizeUnit(double value, String unitId, Map<String, Unit> units) {
  final unit = units[unitId];
  if (unit == null) return value; // Default: no conversion

  final shortName = unit.shortName['en']; // Using English for simplicity
  switch (shortName) {
    case 's':
      return value; // Seconds, no conversion
    case 'min':
      return value * 60; // Minutes to seconds
    case 'h':
      return value * 3600; // Hours to seconds
    case 'km':
      return value * 1000;
    case 'kg':
      return value * 1000;
    default:
      return value; // Fallback for unsupported units
  }
}
