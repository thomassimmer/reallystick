import 'package:flutter/material.dart';

IconData getIconData({
  required String iconDataString,
}) {
  switch (iconDataString) {
    case 'health_and_safety':
      return Icons.health_and_safety;
    case 'language':
      return Icons.language;
    case 'self_improvement':
      return Icons.self_improvement;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'paid':
      return Icons.paid;
    case 'smoke_free':
      return Icons.smoke_free;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'monitor_weight':
      return Icons.monitor_weight;
    case 'savings':
      return Icons.savings;
    default:
      return Icons.not_accessible;
  }
}

Widget getIconWidget({
  required String iconString,
  required double size,
  required Color color,
}) {
  if (iconString.startsWith('material::')) {
    return Icon(
      getIconData(iconDataString: iconString.substring(10)),
      size: size,
      color: color,
    );
  }

  if (iconString.startsWith('web::')) {
    return Image.network(iconString.substring(5), width: size);
  }

  return Icon(
    getIconData(iconDataString: ""),
    size: size,
    color: color,
  );
}
