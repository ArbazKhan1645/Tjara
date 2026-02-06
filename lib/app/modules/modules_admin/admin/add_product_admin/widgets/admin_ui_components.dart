import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Admin Module Theme Constants
class AdminTheme {
  // Primary Colors - Teal Theme
  static const Color primaryColor = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primarySurface = Color(0xFFCCFBF1);

  // Secondary Colors
  static const Color accentColor = Color(0xFF0891B2);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  // Neutral Colors
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Pre-computed opacity colors
  static const Color shadowColor = Color(0x0A000000); // black with 0.04 opacity
  static const Color primaryShadow = Color(0x260D9488); // primary with 0.15 opacity
  static const Color primaryBorderLight = Color(0x4D0D9488); // primary with 0.3 opacity
  static const Color primaryTrackLight = Color(0x8014B8A6); // primaryLight with 0.5 opacity

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: shadowColor,
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    const BoxShadow(
      color: primaryShadow,
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Border Radius
  static BorderRadius get borderRadiusSm => BorderRadius.circular(8);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(12);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(16);

  // Input Decoration
  static InputDecoration inputDecoration({
    String? hint,
    String? label,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: textSecondary, size: 20)
          : null,
      suffix: suffix,
      filled: true,
      fillColor: bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: borderRadiusSm,
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusSm,
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusSm,
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusSm,
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
    );
  }
}

/// Elegant Loading Overlay Widget
class AdminLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AdminLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: const Color(0x66000000), // black with 0.4 opacity
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AdminTheme.borderRadiusLg,
                    boxShadow: AdminTheme.elevatedShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AdminTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            color: AdminTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Full Screen Loading Widget
class AdminFullScreenLoader extends StatelessWidget {
  final String? message;

  const AdminFullScreenLoader({super.key, this.message});

  static void show({String? message}) {
    Get.dialog(
      AdminFullScreenLoader(message: message),
      barrierDismissible: false,
      barrierColor: const Color(0x80000000), // black with 0.5 opacity
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AdminTheme.borderRadiusLg,
              boxShadow: AdminTheme.elevatedShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Loading Indicator
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AdminTheme.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AdminTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message ?? 'Please wait...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This may take a moment',
                  style: TextStyle(
                    color: AdminTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Elegant Snackbar/Toast Widget
class AdminSnackbar {
  static void success(String title, String message) {
    _show(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AdminTheme.successColor,
      shadowColor: const Color(0x3310B981), // success with 0.2 opacity
      bgTintColor: const Color(0x1A10B981), // success with 0.1 opacity
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AdminTheme.errorColor,
      shadowColor: const Color(0x33EF4444),
      bgTintColor: const Color(0x1AEF4444),
    );
  }

  static void warning(String title, String message) {
    _show(
      title: title,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AdminTheme.warningColor,
      shadowColor: const Color(0x33F59E0B),
      bgTintColor: const Color(0x1AF59E0B),
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AdminTheme.accentColor,
      shadowColor: const Color(0x330891B2),
      bgTintColor: const Color(0x1A0891B2),
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color shadowColor,
    required Color bgTintColor,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.rawSnackbar(
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      borderRadius: 12,
      backgroundColor: Colors.transparent,
      snackStyle: SnackStyle.FLOATING,
      messageText: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgTintColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: backgroundColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Get.closeCurrentSnackbar(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: AdminTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clean Card Widget
class AdminCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? headerColor;

  const AdminCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.padding,
    this.margin,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = headerColor ?? AdminTheme.primaryColor;
    final gradientEndColor = Color.fromRGBO(
      (baseColor.r * 255.0).round().clamp(0, 255),
      (baseColor.g * 255.0).round().clamp(0, 255),
      (baseColor.b * 255.0).round().clamp(0, 255),
      0.85,
    );

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AdminTheme.cardColor,
        borderRadius: AdminTheme.borderRadiusMd,
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [baseColor, gradientEndColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isRequired;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AdminTheme.errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AdminTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}

/// Clean Text Field Widget
class AdminTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AdminTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        color: AdminTheme.textPrimary,
        fontSize: 14,
      ),
      decoration: AdminTheme.inputDecoration(
        hint: hint,
        label: label,
        prefixIcon: prefixIcon,
        suffix: suffix,
      ),
    );
  }
}

/// Primary Button Widget
class AdminPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AdminPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AdminTheme.primaryShadow,
          shape: RoundedRectangleBorder(
            borderRadius: AdminTheme.borderRadiusSm,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Secondary/Outline Button Widget
class AdminSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const AdminSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminTheme.textPrimary,
          side: const BorderSide(color: AdminTheme.borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AdminTheme.borderRadiusSm,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle Switch Widget
class AdminToggleSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;

  const AdminToggleSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: value ? AdminTheme.primarySurface : AdminTheme.bgColor,
        borderRadius: AdminTheme.borderRadiusSm,
        border: Border.all(
          color: value ? AdminTheme.primaryBorderLight : AdminTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: value ? AdminTheme.primaryDark : AdminTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AdminTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AdminTheme.primaryColor,
              activeTrackColor: AdminTheme.primaryTrackLight,
              inactiveThumbColor: AdminTheme.textMuted,
              inactiveTrackColor: AdminTheme.borderColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selection Chip Widget
class AdminSelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AdminSelectionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primaryColor : Colors.transparent,
          borderRadius: AdminTheme.borderRadiusSm,
          border: Border.all(
            color: isSelected ? AdminTheme.primaryColor : AdminTheme.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AdminTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Empty State Widget
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AdminTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AdminTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AdminTheme.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer Loading Effect
class AdminShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AdminShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<AdminShimmer> createState() => _AdminShimmerState();
}

class _AdminShimmerState extends State<AdminShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dotted Border Container for Upload
class AdminDottedUploadContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;

  const AdminDottedUploadContainer({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.icon = Icons.cloud_upload_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: AdminTheme.borderRadiusMd,
          border: Border.all(
            color: AdminTheme.borderColor,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AdminTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AdminTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      color: AdminTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' $subtitle',
                    style: const TextStyle(
                      color: AdminTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
