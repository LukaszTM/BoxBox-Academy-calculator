import 'package:flutter/material.dart';

/// Kolory marki BoxBox Academy (na podstawie logo i makiet GUI).
class BB {
  static const bg = Color(0xFF080D13);
  static const card = Color(0xFF0F1720);
  static const cardAlt = Color(0xFF131D28);
  static const border = Color(0xFF1C2937);
  static const red = Color(0xFFFF3D4A);
  static const redDark = Color(0xFFE10600);
  static const cyan = Color(0xFF00E5FF);
  static const green = Color(0xFF2FD18B);
  static const amber = Color(0xFFFFB020);
  static const text = Color(0xFFF2F5F8);
  static const textDim = Color(0xFF8C9AAB);
  static const track = Color(0xFF1E2B39);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: BB.bg,
    colorScheme: const ColorScheme.dark(
      primary: BB.red,
      secondary: BB.cyan,
      surface: BB.card,
    ),
    textTheme: base.textTheme.apply(bodyColor: BB.text, displayColor: BB.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: BB.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: BB.red,
      inactiveTrackColor: BB.track,
      thumbColor: Colors.white,
      overlayColor: BB.red.withValues(alpha: 0.15),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: BB.cardAlt,
      contentTextStyle: TextStyle(color: BB.text),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: BB.card),
  );
}
