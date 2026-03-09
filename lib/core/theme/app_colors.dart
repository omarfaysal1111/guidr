import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF0A3D22);
  // Using 0x14 for ~0.08 alpha (8% opacity) on the primary color
  static const Color primaryLight = Color(0x1434D399); 
  static const Color primaryGhost = Color(0x1434D399); 

  // Success Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Error Colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Background & Surface Colors
  static const Color surface = Color(0xFFF1F5F9);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color card = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient workoutGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF2BC48A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nutritionGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}