// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/authentication/screens/contact_us.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/tjara_surveys/view/survey_view.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/dashbopard_services/balance_service.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';
import 'package:tjara/app/services/websettings_service/websetting_service.dart';

class MoreviewBody extends StatefulWidget {
  const MoreviewBody({super.key});

  @override
  State<MoreviewBody> createState() => _MoreviewBodyState();
}

class _MoreviewBodyState extends State<MoreviewBody> {
  // Safe initialization - null if service not registered
  WebsiteOptionsService? get optionsService {
    try {
      if (Get.isRegistered<WebsiteOptionsService>()) {
        return Get.find<WebsiteOptionsService>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildAlignedContent(String htmlContent) {
    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          color: Colors.grey.shade700,
          lineHeight: const LineHeight(1.6),
        ),
        "div[dir=rtl]": Style(
          direction: TextDirection.rtl,
          textAlign: TextAlign.right,
          margin: Margins.only(bottom: 10),
        ),
        "div[dir=ltr]": Style(
          direction: TextDirection.ltr,
          textAlign: TextAlign.left,
          margin: Margins.only(top: 10),
        ),
      },
      extensions: [
        TagExtension(
          tagsToExtend: {"div"},
          builder: (extensionContext) {
            final element = extensionContext.element;
            final dir = element?.attributes['dir'];
            final content = extensionContext.innerHtml;

            if (dir == 'rtl') {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Html(
                  data: content,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(14),
                      direction: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  },
                ),
              );
            } else if (dir == 'ltr') {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Html(
                  data: content,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(14),
                      direction: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFFfda730),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFfea52d), // top
                        const Color(0xFFfea52d).withOpacity(0.10),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: ProfileCard(),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ✨ About Section (if description exists and service is available)
          if (optionsService?.websiteOptions?.websiteDescription?.isNotEmpty ??
              false)
            _AboutSection(
              content: optionsService?.websiteOptions?.websiteDescription ?? '',
              buildAlignedContent: _buildAlignedContent,
            ),

          // // ✨ Quick Actions Grid
          // _QuickActionsGrid(),
          const SizedBox(height: 16),

          // ✨ Links Section
          _LinksSection(),

          const SizedBox(height: 16),

          // ✨ Help Section
          _HelpSection(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Premium Profile Card
// ========================================
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final LoginResponse? currentUser =
          AuthService.instance.authCustomerRx.value;

      if (currentUser == null) {
        return _GuestProfileCard();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with gradient border
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFfea52d).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${currentUser.user?.firstName?[0] ?? 'F'}${currentUser.user?.lastName?[0] ?? 'L'}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFfea52d),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentUser.user?.firstName ?? 'First'} ${currentUser.user?.lastName ?? 'Last'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              currentUser.user?.email ?? 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (currentUser.user?.role ?? 'Customer').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Verify Email Banner
            _VerifyEmailBanner(currentUser: currentUser),

            const SizedBox(height: 12),

            // Dashboard Button (if admin)
            if (AuthService.instance.authCustomer?.user?.role == 'admin')
              _PremiumButton(
                icon: Icons.dashboard_outlined,
                label: 'Admin Dashboard',
                onTap: () async {
                  await Get.putAsync(() => BalanceService().init());
                  Get.toNamed(Routes.DASHBOARD_ADMIN);
                },
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.teal],
                ),
              )
            else if (AuthService.instance.authCustomer?.user?.role == 'vendor')
              _PremiumButton(
                icon: Icons.dashboard_outlined,
                label: 'Vendor Dashboard',
                onTap: () async {
                  await Get.putAsync(() => BalanceService().init());
                  Get.toNamed(Routes.DASHBOARD_ADMIN);
                },
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.teal],
                ),
              )
            else
              _PremiumButton(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                onTap: () async {
                  await Get.putAsync(() => BalanceService().init());
                  Get.toNamed(Routes.DASHBOARD_ADMIN);
                },
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.teal],
                ),
              ),

            const SizedBox(height: 12),

            // Sign Out Button
            _PremiumButton(
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: () => _handleSignOut(context),
              gradient: const LinearGradient(
                colors: [Color(0xFFfea52d), Color(0xFFf97316)],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      AuthService.instance.cleanStorage();
      WishlistServiceController.instance.initCall();
      Get.find<NotificationService>().initCall();
      final CartService cartService = Get.find<CartService>();
      cartService.initcall();

      DashboardController.instance.changeIndex(0);
      NotificationHelper.showSuccess(
        context,
        'Success',
        'Signed out successfully',
      );
    } on Exception {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      AuthService.instance.cleanStorage();
      DashboardController.instance.changeIndex(0);
      NotificationHelper.showSuccess(
        context,
        'Success',
        'Signed out successfully',
      );
    }
  }
}

// ========================================
// ✨ Guest Profile Card
// ========================================
class _GuestProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFfea52d).withOpacity(0.2),
                  const Color(0xFFf97316).withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 40,
              color: Color(0xFFfea52d),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Tjara!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your account',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          _PremiumButton(
            icon: Icons.login,
            label: 'Sign In',
            onTap: () {
              // Navigate to login
            },
            gradient: const LinearGradient(
              colors: [Color(0xFFfea52d), Color(0xFFf97316)],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Premium Button Component
// ========================================
class _PremiumButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;

  const _PremiumButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// ✨ About Section
// ========================================
class _AboutSection extends StatelessWidget {
  final String content;
  final Widget Function(String) buildAlignedContent;

  const _AboutSection({
    required this.content,
    required this.buildAlignedContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About Tjara',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildAlignedContent(content),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Quick Actions Grid
// ========================================
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _QuickActionCard(
            icon: Icons.home_outlined,
            label: 'Home',
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
            ),
            onTap: () => DashboardController.instance.reset(),
          ),
          _QuickActionCard(
            icon: Icons.work_outline,
            label: 'Services',
            gradient: const LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
            ),
            onTap: () => Get.toNamed(Routes.SERVICES),
          ),
          _QuickActionCard(
            icon: Icons.business_center_outlined,
            label: 'Jobs',
            gradient: const LinearGradient(
              colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
            ),
            onTap: () => Get.toNamed(Routes.TJARA_JOBS),
          ),
          _QuickActionCard(
            icon: Icons.emoji_events_outlined,
            label: 'Contests',
            gradient: const LinearGradient(
              colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
            ),
            onTap: () => Get.toNamed(Routes.CONTESTS),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// ✨ Links Section
// ========================================
class _LinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: Color(0xFFfea52d), size: 24),
              SizedBox(width: 10),
              Text(
                'Quick Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _LinkItem(
            icon: Icons.article_outlined,
            label: 'Blogs',
            onTap: () => DashboardController.instance.changeIndex(8),
          ),
          _LinkItem(
            icon: Icons.supervised_user_circle,
            label: 'Surveys',
            onTap: () {
              Get.to(() => const SurveysScreen());
            },
          ),
          _LinkItem(
            icon: Icons.store_outlined,
            label: 'Reseller Center',
            onTap: () => DashboardController.instance.reset(),
          ),
          _LinkItem(
            icon: Icons.store_outlined,
            label: 'Jobs',
            onTap: () => Get.toNamed(Routes.TJARA_JOBS),
          ),
          _LinkItem(
            icon: Icons.store_outlined,
            label: 'Contests',
            onTap: () => Get.toNamed(Routes.CONTESTS),
          ),
          _LinkItem(
            icon: Icons.store_outlined,
            label: 'Services',
            onTap: () => Get.toNamed(Routes.SERVICES),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Help Section
// ========================================
class _HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFFfea52d), size: 24),
              SizedBox(width: 10),
              Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LinkItem(
            icon: Icons.contact_support_outlined,
            label: 'Contact Us',
            onTap: () => showContactDialog(context, const ContactFormDialog()),
          ),
          _LinkItem(
            icon: Icons.help_center_outlined,
            label: 'Help Center',
            onTap: () => DashboardController.instance.changeIndex(7),
          ),
          _LinkItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => DashboardController.instance.changeIndex(5),
          ),
          _LinkItem(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () => DashboardController.instance.changeIndex(6),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Link Item Component
// ========================================
class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFfea52d).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFfea52d), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Verify Email Banner
// ========================================
class _VerifyEmailBanner extends StatefulWidget {
  final LoginResponse? currentUser;
  const _VerifyEmailBanner({required this.currentUser});

  @override
  State<_VerifyEmailBanner> createState() => _VerifyEmailBannerState();
}

class _VerifyEmailBannerState extends State<_VerifyEmailBanner> {
  Future<bool>? _checkFuture;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkFuture = _checkEmailVerification();
  }

  Future<bool> _checkEmailVerification() async {
    final userId = widget.currentUser?.user?.id;
    if (userId == null) return true; // verified (hide banner)

    try {
      final res = await http.get(
        Uri.parse('https://api.libanbuy.com/api/users/$userId'),
        headers: {
          'user-id': userId,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Dashboard',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // API may return user directly or nested under 'user' key
        final userData =
            data is Map<String, dynamic>
                ? (data.containsKey('user') ? data['user'] : data)
                : data;
        final emailVerifiedAt = userData['email_verified_at'];
        return emailVerifiedAt != null; // true = verified
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    }
    // Default: check local data
    return widget.currentUser?.user?.emailVerifiedAt != null;
  }

  void _refreshCheck() {
    setState(() {
      _checkFuture = _checkEmailVerification();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser == null) return const SizedBox.shrink();

    return VisibilityDetector(
      key: const Key('verify-email-banner'),
      onVisibilityChanged: (info) {
        final nowVisible = info.visibleFraction > 0;
        if (nowVisible && !_isVisible) {
          _refreshCheck();
        }
        _isVisible = nowVisible;
      },
      child: FutureBuilder<bool>(
        future: _checkFuture,
        builder: (context, snapshot) {
          // While loading or if verified, hide the banner
          if (!snapshot.hasData || snapshot.data == true) {
            return const SizedBox.shrink();
          }

          // Email NOT verified - show banner
          return GestureDetector(
            onTap: () => _showVerifyEmailDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFfea52d).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfea52d).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Color(0xFFf97316),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify Your Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap to verify your email address',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFf97316),
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVerifyEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => _VerifyEmailDialog(
            currentUser: widget.currentUser!,
            onDone: _refreshCheck,
          ),
    );
  }
}

// ========================================
// Verify Email Dialog
// ========================================
class _VerifyEmailDialog extends StatefulWidget {
  final LoginResponse currentUser;
  final VoidCallback onDone;

  const _VerifyEmailDialog({required this.currentUser, required this.onDone});

  @override
  State<_VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<_VerifyEmailDialog> {
  late TextEditingController _emailController;
  bool _isUpdatingEmail = false;
  bool _isSendingVerification = false;
  bool _emailEdited = false;
  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    _originalEmail = widget.currentUser.user?.email ?? '';
    _emailController = TextEditingController(text: _originalEmail);
    _emailController.addListener(() {
      final edited = _emailController.text.trim() != _originalEmail;
      if (edited != _emailEdited) {
        setState(() => _emailEdited = edited);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || !GetUtils.isEmail(newEmail)) {
      NotificationHelper.showError(
        context,
        'Invalid Email',
        'Please enter a valid email address',
      );
      return;
    }

    setState(() => _isUpdatingEmail = true);

    try {
      final userId = widget.currentUser.user?.id ?? '';
      final res = await http.put(
        Uri.parse('https://api.libanbuy.com/api/users/$userId/update'),
        headers: {
          'user-id': userId,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Website',
        },
        body: jsonEncode({'email': newEmail}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Update local auth data
        final updatedUser = widget.currentUser.user?.copyWith(
          email: newEmail,
          emailVerifiedAt: null, // Reset since email changed
        );
        final updatedResponse = widget.currentUser.copyWith(user: updatedUser);
        AuthService.instance.saveAuthState(updatedResponse);

        _originalEmail = newEmail;
        setState(() => _emailEdited = false);

        if (mounted) {
          NotificationHelper.showSuccess(
            context,
            'Success',
            'Email updated successfully',
          );
        }
      } else {
        if (mounted) {
          var msgs = jsonDecode(res.body);
          NotificationHelper.showError(
            context,
            'Alert',
            msgs['message'] ?? 'Failed to update',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Error', 'Something went wrong');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingEmail = false);
    }
  }

  Future<void> _resendVerification() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isSendingVerification = true);

    try {
      final userId = widget.currentUser.user?.id ?? '';
      final res = await http.post(
        Uri.parse('https://api.libanbuy.com/api/email/resend'),
        headers: {
          'user-id': userId,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Website',
        },
        body: jsonEncode({'email': email}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          NotificationHelper.showSuccess(context, 'Email Sent to', email);
          Navigator.of(context).pop();
          widget.onDone();
        }
      } else {
        if (mounted) {
          NotificationHelper.showError(
            context,
            'Failed',
            'Failed to send verification email',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Error', 'Something went wrong');
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFfea52d).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                color: Color(0xFFfea52d),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'We\'ll send a verification link to your email',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFfea52d),
                ),
                suffixIcon:
                    _emailEdited
                        ? IconButton(
                          onPressed: _isUpdatingEmail ? null : _updateEmail,
                          icon:
                              _isUpdatingEmail
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFfea52d),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.save_outlined,
                                    color: Color(0xFFfea52d),
                                  ),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFfea52d),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            if (_emailEdited) ...[
              const SizedBox(height: 8),
              Text(
                'Save the new email first, then verify',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Send Verification Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isSendingVerification || _emailEdited)
                        ? null
                        : _resendVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfea52d),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child:
                    _isSendingVerification
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Send Verification Email',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 10),

            // Cancel
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDone();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
