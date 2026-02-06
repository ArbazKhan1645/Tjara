import 'package:flutter/material.dart';

/// Super Elegant theme for Withdrawal Admin module
/// Premium design with smooth gradients and glass effects
class WithdrawalTheme {
  WithdrawalTheme._();

  // Primary Gradient Colors - Purple to Indigo
  static const Color primary = Colors.teal;
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primaryDark = Colors.teal;

  // Secondary - Emerald
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFD1FAE5);
  static const Color secondaryDark = Color(0xFF059669);

  // Accent - Rose
  static const Color accent = Color(0xFFF43F5E);
  static const Color accentLight = Color(0xFFFFE4E6);

  // Status Colors
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingLight = Color(0xFFFEF3C7);
  static const Color approved = Color(0xFF10B981);
  static const Color approvedLight = Color(0xFFD1FAE5);
  static const Color rejected = Color(0xFFEF4444);
  static const Color rejectedLight = Color(0xFFFEE2E2);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color surfaceTertiary = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Colors.teal, Colors.teal, Colors.teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> shadowColored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radius2Xl = 32.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 12.0;
  static const double spacing2Xl = 32.0;
  static const double spacing3Xl = 48.0;

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: border.withValues(alpha: 0.5)),
    boxShadow: shadowSm,
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusXl),
    boxShadow: shadowMd,
  );

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(radiusXl),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    boxShadow: shadowLg,
  );

  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(radiusXl),
    border: Border.all(color: border.withValues(alpha: 0.3)),
    boxShadow: shadowMd,
  );

  // Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -1,
    height: 1.2,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    letterSpacing: 0.3,
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingLg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: approved,
    foregroundColor: textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLg,
      vertical: spacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: rejected,
    foregroundColor: textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLg,
      vertical: spacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: textPrimary,
    side: const BorderSide(color: border),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingLg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? prefix,
    Widget? suffix,
  }) => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    hintStyle: bodyMedium.copyWith(color: textTertiary),
    labelStyle: labelMedium,
    prefix: prefix,
    prefixIcon:
        prefixIcon != null
            ? Icon(prefixIcon, color: textTertiary, size: 20)
            : null,
    suffix: suffix,
    filled: true,
    fillColor: surfaceSecondary,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingLg,
      vertical: spacingLg,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: BorderSide(color: border.withValues(alpha: 0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: rejected),
    ),
  );

  // Status Helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'approved':
        return approved;
      case 'rejected':
        return rejected;
      default:
        return textTertiary;
    }
  }

  static Color getStatusLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingLight;
      case 'approved':
        return approvedLight;
      case 'rejected':
        return rejectedLight;
      default:
        return surfaceSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
