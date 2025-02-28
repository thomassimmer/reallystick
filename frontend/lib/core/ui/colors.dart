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

enum AppColor {
  white(Color(0xFFFFFFFF)),
  beige(Color(0xFFA8A878)),
  black(Color(0xFF303943)),
  blue(Color(0xFF429BED)),
  brown(Color(0xFFB1736C)),
  darkBrown(Color(0xD0795548)),
  grey(Color(0x64303943)),
  indigo(Color(0xFF6C79DB)),
  lightBlue(Color(0xFF7AC7FF)),
  lightBrown(Color(0xFFCA8179)),
  whiteGrey(Color(0xFFFDFDFD)),
  lightCyan(Color(0xFF98D8D8)),
  lightGreen(Color(0xFF78C850)),
  lighterGrey(Color(0xFFF4F5F4)),
  lightGrey(Color(0xFFF5F5F5)),
  lightPink(Color(0xFFEE99AC)),
  lightPurple(Color(0xFF9F5BBA)),
  lightRed(Color(0xFFFB6C6C)),
  lightTeal(Color(0xFF48D0B0)),
  lightYellow(Color(0xFFFFCE4B)),
  lilac(Color(0xFFA890F0)),
  pink(Color(0xFFF85888)),
  purple(Color(0xFF7C538C)),
  red(Color(0xFFFA6555)),
  teal(Color(0xFF4FC1A6)),
  yellow(Color(0xFFF6C747)),
  semiGrey(Color(0xFFbababa)),
  violet(Color(0xD07038F8)),
  orange(Color(0xFFFF9D5C));

  final Color color;

  const AppColor(this.color);
}

extension AppColorExtension on AppColor {
  String toShortString() {
    return toString().split('.').last;
  }

  static AppColor fromString(String colorName) {
    try {
      return AppColor.values.firstWhere(
        (appColor) =>
            appColor.toShortString().toLowerCase() == colorName.toLowerCase(),
        orElse: () => throw ArgumentError("No AppColor matches '$colorName'"),
      );
    } catch (e) {
      return AppColor.blue;
    }
  }

  static AppColor getRandomColor() {
    final random = Random();
    return AppColor.values[random.nextInt(AppColor.values.length)];
  }
}
