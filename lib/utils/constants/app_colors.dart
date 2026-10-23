import 'package:flutter/material.dart';

class AppColors {
  // Brand & Theme Colors
  static const Color primaryColor = Color(0xFF3949AB);
  static const Color primaryLight = Color(0xFF5C6BC0);
  static const Color primaryLighter = Color(0xFFDEEEFD);
  static const Color scaffoldBackground = Color(0xFFF5F9FC);
  // Soft Light Blue & White Multi-Stop Background Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB0D7FE),
      Color(0xFFE8D8FD),
      Color(0xFFD3E1FD),
      Color(0xFFD7E5FD),
    ],
  );

  static const LinearGradient splashGradient = primaryGradient;

  // Reusable Background BoxDecoration used across entire app
  static const BoxDecoration appBackgroundDecoration = BoxDecoration(
    gradient: primaryGradient,
  );
}
