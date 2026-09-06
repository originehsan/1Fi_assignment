import 'package:flutter/material.dart';

/// Single source of truth for every color used in the application.
///
/// Per rules.md Section 3, no raw `Color(0x...)` literal or `Colors.*`
/// constant is permitted anywhere outside this file (the one documented
/// exception being `Colors.transparent`, which carries no brand meaning).
///
/// These values are best-effort approximations reviewed against
/// screenshots of the real 1Fi app, not exact pixel-sampled values — see
/// architecture.md Section 11 for the full placeholder-palette caveat.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C3CE9);
  static const Color primaryDisabled = Color(0xFFD9CBF5);
  static const Color background = Color(0xFFF7F5FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color lavenderTint = Color(0xFFF3EEFC);
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
