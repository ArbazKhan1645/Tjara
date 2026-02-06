import 'package:flutter/material.dart';

/// Elegant theme constants for Auction Admin module
/// Provides consistent colors, shadows, and styling across auction forms
class AuctionAdminTheme {
  AuctionAdminTheme._();

  // Primary Colors
  static const Color primary = Color(0xFFfda730);
  static const Color primaryLight = Color(0xFFFFF7ED);
  static const Color primaryDark = Color(0xFFE69520);

  // Accent Color - Teal (for auction)
  static const Color accent = Color(0xFF0D9488);
  static const Color accentLight = Color(0xFFCCFBF1);
  static const Color accentDark = Color(0xFF0F766E);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

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

  // Section Header Decoration
  static BoxDecoration get sectionHeaderDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [accent, accentDark],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: shadowColored(accent),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? suffix,
    bool isRequired = false,
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
      borderSide: const BorderSide(color: accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: error, width: 1.5),
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
    backgroundColor: accent,
    foregroundColor: textOnPrimary,
    elevation: 0,
    minimumSize: const Size(double.infinity, 52),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingLg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: surfaceSecondary,
    foregroundColor: textPrimary,
    elevation: 0,
    minimumSize: const Size(double.infinity, 52),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingLg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      side: const BorderSide(color: border),
    ),
  );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: textPrimary,
    side: const BorderSide(color: border),
    minimumSize: const Size(double.infinity, 52),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXl,
      vertical: spacingLg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );
}

/// Reusable Card Widget for form sections
class AuctionFormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isExpanded;

  const AuctionFormCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AuctionAdminTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
            decoration: AuctionAdminTheme.sectionHeaderDecoration,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: AuctionAdminTheme.spacingMd),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Field Label Widget with optional required indicator
class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? description;

  const FieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AuctionAdminTheme.headingSmall),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuctionAdminTheme.spacingSm,
                  vertical: AuctionAdminTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AuctionAdminTheme.errorLight,
                  borderRadius: BorderRadius.circular(
                    AuctionAdminTheme.radiusSm,
                  ),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AuctionAdminTheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: AuctionAdminTheme.spacingXs),
          Text(description!, style: AuctionAdminTheme.bodySmall),
        ],
        const SizedBox(height: AuctionAdminTheme.spacingSm),
      ],
    );
  }
}

/// Upload Zone Widget for images/files
class UploadZone extends StatelessWidget {
  final VoidCallback onTap;
  final String primaryText;
  final String secondaryText;
  final IconData icon;
  final bool hasContent;
  final Widget? contentWidget;

  const UploadZone({
    super.key,
    required this.onTap,
    this.primaryText = 'Upload a file',
    this.secondaryText = 'or drag and drop',
    this.icon = Icons.cloud_upload_outlined,
    this.hasContent = false,
    this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (hasContent && contentWidget != null) {
      return contentWidget!;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
          decoration: BoxDecoration(
            color: AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(
              color: AuctionAdminTheme.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
                decoration: const BoxDecoration(
                  color: AuctionAdminTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AuctionAdminTheme.primary,
                ),
              ),
              const SizedBox(height: AuctionAdminTheme.spacingMd),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AuctionAdminTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: primaryText,
                      style: const TextStyle(
                        color: AuctionAdminTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' $secondaryText',
                      style: const TextStyle(
                        color: AuctionAdminTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
