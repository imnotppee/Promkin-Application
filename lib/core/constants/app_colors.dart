import 'package:flutter/material.dart';

/// App color palette matching PROM KIN Design System
class AppColors {
  // Brand Primary & Accents (PROM KIN Matcha Palette)
  static const Color primary = Color(0xFF416448); // PROM KIN Deep Matcha Green
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFE9F0E7); // Matcha Pale
  static const Color onPrimaryContainer = Color(0xFF1B3220);

  static const Color secondary = Color(0xFFD7E98A); // Lime Accent
  static const Color onSecondary = Color(0xFF252B23);
  static const Color secondaryContainer = Color(0xFFEEF5CD);
  static const Color onSecondaryContainer = Color(0xFF1B2208);

  static const Color tertiary = Color(0xFFF5A56C); // Warm Orange Accent
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFFFF1E7); // Pale Orange
  static const Color onTertiaryContainer = Color(0xFF381500);

  // Backgrounds & Neutral Surfaces
  static const Color paper = Color(0xFFF8F7F2); // Warm Cream Paper
  static const Color ink = Color(0xFF252B23); // Deep Charcoal Ink
  static const Color muted = Color(0xFF898D81); // Muted Sage Grey
  static const Color line = Color(0xFFECECE4); // Border Line Grey
  static const Color yellow = Color(0xFFF4D776); // Soft Yellow

  static const Color backgroundLight = Color(0xFFF8F7F2);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundDark = Color(0xFF1A1F18);
  static const Color surfaceDark = Color(0xFF242A22);

  // Meal Card Background Types
  static const Color breakfastBg = Color(0xFFF3E8D8);
  static const Color lunchBg = Color(0xFFE6EFE0);
  static const Color dinnerBg = Color(0xFFF8E8DD);

  // Nutrition Macros Colors
  static const Color calories = Color(0xFFD9A65F);
  static const Color protein = Color(0xFF9BB184);
  static const Color carbs = Color(0xFFE6AD7D);
  static const Color fat = Color(0xFFD7C16F);

  // Status Colors
  static const Color success = Color(0xFF416448);
  static const Color warning = Color(0xFFE99A6B);
  static const Color error = Color(0xFFD32F2F);
}
