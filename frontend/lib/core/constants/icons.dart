import 'package:flutter/material.dart';

IconData getIconData({
  required String iconDataString,
}) {
  final codePoint = int.tryParse(iconDataString);

  if (codePoint != null) {
    return IconData(codePoint);
  }

  return Icons.not_accessible;
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
