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

  /// Darker purple used as the start of the Shop hero banner's gradient
  /// (fades into [primary]). Medium confidence — a screenshot-review
  /// estimate, not pixel-sampled; see architecture.md Section 11.
  static const Color heroBannerGradientStart = Color(0xFF2D1470);

  /// Text/icon color for content painted directly on top of a
  /// [primary]-colored surface (e.g. the hero banner). Aliases
  /// `Colors.white` so call sites outside this file never reference
  /// `Colors.*` directly, per rules.md Section 3.
  static const Color onPrimary = Colors.white;
}

/// Spacing values extracted per rules.md Section 3 ("Typography, spacing,
/// and radius"): each constant here was already repeated identically, for
/// the same purpose, in 2+ places before being named — not created
/// speculatively. Values that only appear once, or that appear more than
/// once for genuinely different layout purposes, are deliberately left as
/// literals at their call sites (see the Documentation Sync report for the
/// full list of what was considered and not extracted).
class AppSpacing {
  AppSpacing._();

  /// Interior padding for a bordered/card-shaped list tile. Used by
  /// [EmiPlanTile] and [ProductListItem], and by their matching skeleton
  /// placeholders — a skeleton must stay pixel-identical to the real
  /// content it stands in for, or it visibly reflows once data arrives.
  static const double tilePadding = 12;

  /// Outer scroll-content padding for the product list. Used by
  /// `ProductList` and `ProductListSkeleton`, which is documented to
  /// mirror `ProductList`'s configuration exactly for the same
  /// no-reflow-on-load reason as [tilePadding].
  static const double listContentPadding = 16;

  /// Padding around the bottom-pinned primary action button inside the
  /// product detail sheet. Used identically by both of its internal
  /// views — the product view's Proceed button and the order-summary
  /// view's Confirm button.
  static const double sheetActionPadding = 16;
}

/// Corner-radius values extracted per rules.md Section 3, on the same
/// repeated-for-the-same-purpose basis as [AppSpacing] — see that class's
/// doc comment.
class AppRadius {
  AppRadius._();

  /// Rounded corners for a product thumbnail/image. Used by
  /// [ProductListItem]'s thumbnail, the product detail sheet's hero
  /// image, and `ProductListItemSkeleton`'s placeholder for that same
  /// thumbnail — kept as one value so the three can't visually drift
  /// apart from each other.
  static const double thumbnail = 12;

  /// The standard card corner radius. Defined once here and referenced
  /// both by [AppTheme.light]'s `cardTheme` (which every `Card` in the
  /// app inherits) and by [ProductListItem]'s `InkWell`, which clips its
  /// ripple to the same shape as the `Card` it sits inside — previously
  /// two independent `16` literals that had to be kept in sync by hand.
  static const double card = 16;

  /// Rounding for the short selected-indicator bar shown above/below a
  /// selected tab. Used identically by the Shop page's segmented-control
  /// underline and the bottom nav's selected-tab indicator — already
  /// self-documented in `app_shell.dart` as "the same pattern" before
  /// this constant existed.
  static const double indicatorBar = 2;
}

/// Named text styles extracted per rules.md Section 3, on the same
/// repeated-for-the-same-purpose basis as [AppSpacing] — see that class's
/// doc comment.
class AppTextStyles {
  AppTextStyles._();

  /// Small secondary/caption text. Used for an EMI plan tile's detail
  /// line (e.g. "12% p.a. • Total ₹9809") and the product detail sheet's
  /// "You'll pay ₹X/mo for N months" amount label above the Proceed
  /// button.
  static const TextStyle caption = TextStyle(fontSize: 12, color: AppColors.textSecondary);

  /// A small emphasized title. Used for `PlaceholderTab`'s empty-state
  /// title and [ProductListItem]'s product name — independently arrived
  /// at as the same value (`FontWeight.bold` and `FontWeight.w700` are
  /// the same constant) for what is, in both cases, the most prominent
  /// text in a small content block.
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// A section-label heading within the product detail sheet (e.g.
  /// "Select an option", "EMI plans").
  static const TextStyle sectionLabel = TextStyle(fontWeight: FontWeight.w600);
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
          borderRadius: BorderRadius.circular(AppRadius.card),
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
