import 'package:flutter/material.dart';

/// Single source of truth for every color used in the application.
///
/// Per rules.md Section 3, no raw `Color(0x...)` literal or `Colors.*`
/// constant is permitted anywhere outside this file (the one documented
/// exception being `Colors.transparent`, which carries no brand meaning).
///
/// These values are best-estimate visual approximations from reviewed
/// screenshots, not pixel-sampled or extracted from source assets.
/// Confidence level is noted per-token in the audit this class was built
/// from (see rules.md / architecture.md change log) — see
/// architecture.md Section 11 for the full placeholder-palette caveat.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6832E3);
  static const Color primaryDisabled = Color(0xFFC2A0F5);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1D1D21);
  static const Color textSecondary = Color(0xFF75757A);
  static const Color success = Color(0xFF1FA463);
  static const Color warning = Color(0xFFE9971D);
  static const Color error = Color(0xFFDC2626);
  static const Color divider = Color(0xFFEBEBEB);
  static const Color lavenderTint = Color(0xFFF5F0FF);
}

/// App-wide `ThemeData`, built entirely from [AppColors] tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        side: const BorderSide(color: AppColors.divider),
      ),
    );
  }
}
