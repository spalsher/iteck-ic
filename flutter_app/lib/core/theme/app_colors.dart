import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color darkCyan = Color(0xFF00ACC1);
  static const Color lightCyan = Color(0xFFB2EBF2);
  
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF424242);
  static const Color black = Color(0xFF000000);
  
  // Glassmorphic Colors
  static const Color glassBackground = Color(0x1AFFFFFF); // 10% opacity white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% opacity white
  static const Color glassShadow = Color(0x0D000000); // 5% opacity black
  
  // Gradient Colors
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryCyan,
      darkCyan,
    ],
  );
  
  static final LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      white.withOpacity(0.2),
      white.withOpacity(0.1),
    ],
  );
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
