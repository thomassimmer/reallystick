import 'package:reallystick/features/habits/domain/entities/unit.dart';

int normalizeUnit(int value, String unitId, Map<String, Unit> units) {
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
      return value * 1000; // Kilometers to meters
    case 'kg':
      return value * 1000; // Kilograms to grams
    case 'mi': // Miles to meters
      return (value * 1609.34).round(); // 1 mile = 1609.34 meters
    case 'lb': // Pounds to grams
      return (value * 453.592).round(); // 1 pound = 453.592 grams
    case 'oz': // Ounces to grams
      return (value * 28.3495).round(); // 1 ounce = 28.3495 grams
    case 'ft': // Feet to meters
      return (value * 0.3048).round(); // 1 foot = 0.3048 meters
    case 'in': // Inches to meters
      return (value * 0.0254).round(); // 1 inch = 0.0254 meters
    default:
      return value; // Fallback for unsupported units
  }
}
