import 'dart:math';

import 'package:flutter/material.dart';

class AppThemeColors {
  final MaterialColor primarySwatch;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color backgroundDark;
  final Color disabled;
  final Color information;
  final Color success;
  final Color alert;
  final Color warning;
  final Color error;
  final Color text;
  final Color textOnPrimary;
  final Color border;
  final Color hint;

  const AppThemeColors({
    required this.primarySwatch,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.backgroundDark,
    required this.disabled,
    required this.information,
    required this.success,
    required this.alert,
    required this.warning,
    required this.error,
    required this.text,
    required this.textOnPrimary,
    required this.border,
    required this.hint,
  });

  AppThemeColors lerp(covariant dynamic other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      primarySwatch: primarySwatch,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      information: Color.lerp(information, other.information, t)!,
      success: Color.lerp(success, other.success, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      text: Color.lerp(text, other.text, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      border: Color.lerp(border, other.border, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
    );
  }

  AppThemeColors copyWith({
    MaterialColor? primarySwatch,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? backgroundDark,
    Color? disabled,
    Color? information,
    Color? success,
    Color? alert,
    Color? warning,
    Color? error,
    Color? text,
    Color? textOnPrimary,
    Color? border,
    Color? hint,
  }) {
    return AppThemeColors(
      primarySwatch: primarySwatch ?? this.primarySwatch,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      disabled: disabled ?? this.disabled,
      information: information ?? this.information,
      success: success ?? this.success,
      alert: alert ?? this.alert,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      text: text ?? this.text,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      border: border ?? this.border,
      hint: hint ?? this.hint,
    );
  }
}

abstract class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color beige = Color(0xFFA8A878);
  static const Color black = Color(0xFF303943);
  static const Color blue = Color(0xFF429BED);
  static const Color brown = Color(0xFFB1736C);
  static const Color darkBrown = Color(0xD0795548);
  static const Color grey = Color(0x64303943);
  static const Color indigo = Color(0xFF6C79DB);
  static const Color lightBlue = Color(0xFF7AC7FF);
  static const Color lightBrown = Color(0xFFCA8179);
  static const Color whiteGrey = Color(0xFFFDFDFD);
  static const Color lightCyan = Color(0xFF98D8D8);
  static const Color lightGreen = Color(0xFF78C850);
  static const Color lighterGrey = Color(0xFFF4F5F4);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color lightPink = Color(0xFFEE99AC);
  static const Color lightPurple = Color(0xFF9F5BBA);
  static const Color lightRed = Color(0xFFFB6C6C);
  static const Color lightTeal = Color(0xFF48D0B0);
  static const Color lightYellow = Color(0xFFFFCE4B);
  static const Color lilac = Color(0xFFA890F0);
  static const Color pink = Color(0xFFF85888);
  static const Color purple = Color(0xFF7C538C);
  static const Color red = Color(0xFFFA6555);
  static const Color teal = Color(0xFF4FC1A6);
  static const Color yellow = Color(0xFFF6C747);
  static const Color semiGrey = Color(0xFFbababa);
  static const Color violet = Color(0xD07038F8);
  static const Color orange = Color(0xFFFF9D5C);
}

Color getAppColorsFromString(String colorString) {
  switch (colorString.toLowerCase()) {
    case "white":
      return AppColors.white;
    case "beige":
      return AppColors.beige;
    case "black":
      return AppColors.black;
    case "blue":
      return AppColors.blue;
    case "brown":
      return AppColors.brown;
    case "darkbrown":
    case "dark_brown":
      return AppColors.darkBrown;
    case "grey":
      return AppColors.grey;
    case "indigo":
      return AppColors.indigo;
    case "lightblue":
    case "light_blue":
      return AppColors.lightBlue;
    case "lightbrown":
    case "light_brown":
      return AppColors.lightBrown;
    case "whitegrey":
    case "white_grey":
      return AppColors.whiteGrey;
    case "lightcyan":
    case "light_cyan":
      return AppColors.lightCyan;
    case "lightgreen":
    case "light_green":
    case "green":
      return AppColors.lightGreen;
    case "lightergrey":
    case "lighter_grey":
      return AppColors.lighterGrey;
    case "lightgrey":
    case "light_grey":
      return AppColors.lightGrey;
    case "lightpink":
    case "light_pink":
      return AppColors.lightPink;
    case "lightpurple":
    case "light_purple":
      return AppColors.lightPurple;
    case "lightred":
    case "light_red":
      return AppColors.lightRed;
    case "lightteal":
    case "light_teal":
      return AppColors.lightTeal;
    case "lightyellow":
    case "light_yellow":
      return AppColors.lightYellow;
    case "lilac":
      return AppColors.lilac;
    case "pink":
      return AppColors.pink;
    case "purple":
      return AppColors.purple;
    case "red":
      return AppColors.red;
    case "teal":
      return AppColors.teal;
    case "yellow":
      return AppColors.yellow;
    case "semigrey":
    case "semi_grey":
      return AppColors.semiGrey;
    case "violet":
      return AppColors.violet;
    case "orange":
      return AppColors.orange;
    default:
      return AppColors.black; // Fallback color
  }
}

// Function to get a random color from the available AppColors
String getRandomAppColor() {
  final List<String> availableColors = [
    "white",
    "beige",
    "black",
    "blue",
    "brown",
    "dark_brown",
    "grey",
    "indigo",
    "light_blue",
    "light_brown",
    "white_grey",
    "light_cyan",
    "light_green",
    "lighter_grey",
    "light_grey",
    "light_pink",
    "light_purple",
    "light_red",
    "light_teal",
    "light_yellow",
    "lilac",
    "pink",
    "purple",
    "red",
    "teal",
    "yellow",
    "semi_grey",
    "violet",
    "orange",
  ];

  final Random random = Random();
  final String randomColorName =
      availableColors[random.nextInt(availableColors.length)];
  return randomColorName;
}
