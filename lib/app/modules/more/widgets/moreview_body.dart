// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/surveys/view/survey_view.dart';
import 'package:tjara/app/modules/wishlist/controllers/wishlist_service.dart';
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
  final WebsiteOptionsService optionsService =
      Get.find<WebsiteOptionsService>();

  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
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

          // ✨ About Section (if description exists)
          if (optionsService.websiteOptions?.websiteDescription?.isNotEmpty ??
              false)
            _AboutSection(
              content: optionsService.websiteOptions?.websiteDescription ?? '',
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
    final LoginResponse? currentUser = AuthService.instance.authCustomer;

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

          const SizedBox(height: 20),

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
                colors: [Color(0xFF00897B), Color(0xFF004D40)],
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
                colors: [Color(0xFF00897B), Color(0xFF004D40)],
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
