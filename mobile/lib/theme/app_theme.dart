import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0B1326);
  static const surfaceDim = Color(0xFF0B1326);
  static const surfaceContainer = Color(0xFF171F33);
  static const surfaceContainerLow = Color(0xFF131B2E);
  static const surfaceContainerHigh = Color(0xFF222A3D);
  static const surfaceContainerHighest = Color(0xFF2D3449);
  static const surfaceBright = Color(0xFF31394D);

  // Lime green (primary accent)
  static const primaryFixed = Color(0xFF9FFB00);
  static const primaryFixedDim = Color(0xFF8BDC00);
  static const primaryContainer = Color(0xFF9FFB00);
  static const onPrimaryFixed = Color(0xFF102000);
  static const primary = Color(0xFFFFFFFF);

  // Purple (secondary)
  static const secondary = Color(0xFFD8B9FF);
  static const secondaryContainer = Color(0xFF6E06D0);

  static const onSurface = Color(0xFFDAE2FD);
  static const onSurfaceVariant = Color(0xFFC0CAAD);
  static const outlineVariant = Color(0xFF414A34);
  static const outline = Color(0xFF8A947A);

  static const error = Color(0xFFFFB4AB);
}

// Glow shadow helpers
List<BoxShadow> glowLime({double opacity = 0.2, double blur = 20}) => [
      BoxShadow(
        color: const Color(0xFF9FFB00).withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];

List<BoxShadow> glowPurple({double opacity = 0.2, double blur = 10}) => [
      BoxShadow(
        color: const Color(0xFF6E06D0).withValues(alpha: opacity),
        blurRadius: blur,
      ),
      BoxShadow(
        color: const Color(0xFF6E06D0).withValues(alpha: 0.1),
        blurRadius: 5,
        spreadRadius: -2,
      ),
    ];

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceContainer,
        primary: AppColors.primaryFixed,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.anybody(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.32,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.anybody(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        titleMedium: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.hankenGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        labelLarge: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDim,
        elevation: 0,
        titleTextStyle: GoogleFonts.anybody(
          color: AppColors.primaryFixed,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          fontStyle: FontStyle.italic,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
