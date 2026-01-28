import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF0D4F9D);
  static const Color secondary = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF000000);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF757575);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Task Status Colors
  static const Color statusCompleted = Color(0xFF388E3C);
  static const Color statusInProgress = Color(0xFF1976D2);
  static const Color statusNext = Color(0xFFF57C00);
  static const Color statusBlocking = Color(0xFFD32F2F);

  // Work Type Colors
  static const Color workTypeField = Color(0xFF1976D2);
  static const Color workTypeWFH = Color(0xFF7B1FA2);
  static const Color workTypeTour = Color(0xFFEF6C00);
}

/// App-wide spacing constants
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// App-wide border radius constants
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;

  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get extraLargeRadius => BorderRadius.circular(xl);
}
