import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Spider-Man official Marvel palette
  static const Color primary = Color(0xFFC41230);      // Spider-Man crimson red
  static const Color accent = Color(0xFF236192);        // Spider-Man blue
  static const Color spiderRed = Color(0xFFE5231C);    // Bright suit red
  static const Color spiderRedDark = Color(0xFF8B0000); // Dark web red
  static const Color spiderBlue = Color(0xFF003274);   // Deep navy blue
  static const Color spiderBlueMid = Color(0xFF1B3A6B); // Mid blue
  static const Color webBlack = Color(0xFF1A1A1A);     // Near black (web lines)

  static const Color background = Color(0xFF0C0808);   // Near black, slight red
  static const Color card = Color(0xFF140909);
  static const Color cardHover = Color(0xFF1E0D0D);
  static const Color surface = Color(0xFF1E1010);
  static const Color border = Color(0xFF2E1212);
  static const Color textPrimary = Color(0xFFF2EAEA);  // Warm white
  static const Color textSecondary = Color(0xFF917878); // Muted rose-gray
  static const Color success = Color(0xFF4CAF50);
  static const Color webSilver = Color(0xFFC8D4E0);   // Web thread color

  // Kept for cross-platform skill icons
  static const Color androidGreen = Color(0xFF3DDC84);
  static const Color iosWhite = Color(0xFFF2EAEA);
  static const Color webBlue = Color(0xFF236192);
  static const Color desktopGold = Color(0xFFFFB400);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, spiderRed],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primary, spiderRed],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF140909), Color(0xFF1E0D0D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spiderGradient = LinearGradient(
    colors: [spiderBlue, primary, spiderRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
