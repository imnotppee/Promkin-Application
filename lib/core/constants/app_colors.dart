import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary Brand Colors (Food/Promkin Warm & Fresh Palette)
  static const Color primary = Color(
    0xFFFF6B35,
  ); // Energetic Warm Orange (food appetite)
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFFFDBCF);
  static const Color onPrimaryContainer = Color(0xFF380C00);

  static const Color secondary = Color(
    0xFF2E7D32,
  ); // Fresh Healthy Green (vegetables/health)
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFB8F5B4);
  static const Color onSecondaryContainer = Color(0xFF002204);

  static const Color tertiary = Color(0xFF00796B); // Teal Accent
  static const Color onTertiary = Colors.white;

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFFBFBFB);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Nutrition Macros Colors
  static const Color calories = Color(0xFFFF7043);
  static const Color protein = Color(0xFF42A5F5);
  static const Color carbs = Color(0xFFFFA726);
  static const Color fat = Color(0xFFAB47BC);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
}
