import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color navyBlue = Color(0xFF1E293B);
  static const Color lightGrayBackground = Color(0xFFF8FAFC);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningRed = Color(0xFFEF4444);
  static const Color white = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
}
