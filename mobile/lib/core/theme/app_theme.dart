import 'package:flutter/material.dart';

class AppTheme {
  // ThemeData with Material 3 and hardcoded hex values embedded
  static const _primaryColor = Color(0xFF1D9E75); // teal400
  static const _secondaryColor = Color(0xFF5DCAA5); // teal200
  static const _errorColor = Color(0xFFD85A30); // coral400
  static const _backgroundColor = Color(0xFFFAFAFA);
  static const _surfaceColor = Color(0xFFFFFFFF);
  static const _onPrimaryColor = Colors.white;
  static const _onSurfaceColor = Color(0xFF1A1A1A); // textPrimary
  static const _onSurfaceVariantColor = Color(
    0xFF333333,
  ); // High contrast textSecondary
  static const _outlineVariantColor = Color(0xFFD3D1C7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        onPrimary: _onPrimaryColor,
        secondary: _secondaryColor,
        error: _errorColor,
        surface: _surfaceColor,
        onSurface: _onSurfaceColor,
        onSurfaceVariant: _onSurfaceVariantColor,
        outlineVariant: _outlineVariantColor,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      // High contrast & large fonts for accessibility (elderly users)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: _onSurfaceColor,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: _onSurfaceColor,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: _onSurfaceColor,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _onSurfaceColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _onSurfaceColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onSurfaceColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _onSurfaceColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: _onSurfaceColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _onSurfaceVariantColor,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _onSurfaceVariantColor,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _onSurfaceColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor,
        foregroundColor: _onSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _onSurfaceColor,
        ),
        iconTheme: IconThemeData(color: _onSurfaceColor, size: 28),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          minimumSize: const Size(64, 56), // Minimum touch target size
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          minimumSize: const Size(64, 56),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _outlineVariantColor, width: 1),
        ),
      ),
    );
  }
}

class AppRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(20));
  static const full = BorderRadius.all(Radius.circular(999));
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
