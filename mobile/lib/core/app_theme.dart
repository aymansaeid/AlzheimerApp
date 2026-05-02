import 'package:flutter/material.dart';

class AppColors {
  // Primary Teal Palette
  static const teal50 = Color(0xFFE1F5EE);
  static const teal100 = Color(0xFF9FE1CB);
  static const teal200 = Color(0xFF5DCAA5);
  static const teal400 = Color(0xFF1D9E75);
  static const teal600 = Color(0xFF0F6E56);
  static const teal800 = Color(0xFF085041);

  // Coral / Alert
  static const coral50 = Color(0xFFFAECE7);
  static const coral100 = Color(0xFFF5C4B3);
  static const coral400 = Color(0xFFD85A30);
  static const coral600 = Color(0xFF993C1D);

  // Amber / Warning
  static const amber50 = Color(0xFFFAEEDA);
  static const amber100 = Color(0xFFFAC775);
  static const amber400 = Color(0xFFBA7517);

  // Blue / Info
  static const blue50 = Color(0xFFE6F1FB);
  static const blue100 = Color(0xFFB5D4F4);
  static const blue400 = Color(0xFF378ADD);

  // Gray
  static const gray50 = Color(0xFFF1EFE8);
  static const gray100 = Color(0xFFD3D1C7);
  static const gray200 = Color(0xFFB4B2A9);
  static const gray400 = Color(0xFF888780);
  static const gray600 = Color(0xFF5F5E5A);

  // Neutral
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textTertiary = Color(0xFF9E9E9E);
  static const border = Color(0xFFEAEAEA);
}

class AppTextStyles {
  static const displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const headingSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.6,
  );

  static const caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal400,
        primary: AppColors.teal400,
        secondary: AppColors.teal200,
        surface: AppColors.surface,
        error: AppColors.coral400,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.headingMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal400,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal400,
          side: const BorderSide(color: AppColors.teal200, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

// Reusable radius constants
class AppRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(20));
  static const full = BorderRadius.all(Radius.circular(999));
}

// Reusable spacing
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
