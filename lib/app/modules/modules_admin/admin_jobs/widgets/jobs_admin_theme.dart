import 'package:flutter/material.dart';

/// Elegant theme constants for Jobs Admin module
/// Provides consistent colors, shadows, and styling across job management
class JobsAdminTheme {
  JobsAdminTheme._();

  // Primary Colors - Teal
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color primaryDark = Color(0xFF0F766E);

  // Accent Color - Indigo
  static const Color accent = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFFE0E7FF);
  static const Color accentDark = Color(0xFF3730A3);

  // Secondary - Amber
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFEF3C7);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Work Type Colors
  static const Color onSite = Color(0xFF3B82F6);
  static const Color remote = Color(0xFF10B981);
  static const Color hybrid = Color(0xFFF59E0B);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowColored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Border Radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2Xl = 32.0;

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: border),
    boxShadow: shadowSm,
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowMd,
  );

  // Section Header Decoration - Teal Gradient
  static BoxDecoration get sectionHeaderDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [primary, primaryDark],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: shadowColored(primary),
  );

  // Table Header Decoration
  static BoxDecoration get tableHeaderDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [primary, primaryDark],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: shadowColored(primary),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? suffix,
  }) => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
    labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: textTertiary, size: 20)
        : null,
    suffix: suffix,
    filled: true,
    fillColor: surfaceSecondary,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingLg,
      vertical: spacingMd,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: primary, width: 1.5),
    ),
  );

  // Text Styles
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
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.3,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textOnPrimary,
    elevation: 0,
    minimumSize: const Size(double.infinity, 48),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: textOnPrimary,
    elevation: 0,
    minimumSize: const Size(double.infinity, 48),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: textPrimary,
    side: const BorderSide(color: border),
    minimumSize: const Size(double.infinity, 48),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  // Work Type Color Helper
  static Color getWorkTypeColor(String workType) {
    switch (workType.toLowerCase()) {
      case 'on-site':
      case 'onsite':
        return onSite;
      case 'remote':
        return remote;
      case 'hybrid':
        return hybrid;
      default:
        return textTertiary;
    }
  }

  // Status Color Helper
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return success;
      case 'inactive':
      case 'closed':
        return error;
      case 'pending':
        return warning;
      default:
        return textTertiary;
    }
  }
}
