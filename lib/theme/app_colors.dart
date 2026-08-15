import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF02569B);
  static const Color accent = Color(0xFF54C5F8);
  static const Color background = Color(0xFF0A0E1A);
  static const Color card = Color(0xFF0F1629);
  static const Color cardHover = Color(0xFF141C35);
  static const Color surface = Color(0xFF1A2340);
  static const Color border = Color(0xFF1E2D4A);
  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF7986A8);
  static const Color success = Color(0xFF4CAF50);
  static const Color androidGreen = Color(0xFF3DDC84);
  static const Color iosWhite = Color(0xFFE8EAF6);
  static const Color webBlue = Color(0xFF54C5F8);
  static const Color desktopGold = Color(0xFFFFB400);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0F1629), Color(0xFF141C35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
