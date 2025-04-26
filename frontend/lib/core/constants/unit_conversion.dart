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
      return value * 1000; // Kilometers to meters
    case 'kg':
      return value * 1000; // Kilograms to grams
    case 'mi': // Miles to meters
      return value * 1609.34; // 1 mile = 1609.34 meters
    case 'lb': // Pounds to grams
      return value * 453.592; // 1 pound = 453.592 grams
    case 'oz': // Ounces to grams
      return value * 28.3495; // 1 ounce = 28.3495 grams
    case 'ft': // Feet to meters
      return value * 0.3048; // 1 foot = 0.3048 meters
    case 'in': // Inches to meters
      return value * 0.0254; // 1 inch = 0.0254 meters
    case 'gal':
      return value * 3.78541; // 1 gal = 3.78541 liters
    case 'cm':
      return value * 0.01; // 1 cm = 0.01 meter
    default:
      return value; // Fallback for unsupported units
  }
}

String formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    // It's a whole number
    return quantity.toInt().toString();
  } else {
    // It's a decimal
    return quantity.toString();
  }
}
