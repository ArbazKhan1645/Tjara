import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_config/views/admin_products_config_view.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin_contexts/insert.dart';
import 'package:tjara/app/modules/modules_admin/admin_contexts/view/contests_view.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/view/attributes_view.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/view/insert_job.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/view/jobs_view.dart';
import 'package:tjara/app/modules/modules_admin/attributes/attributes.dart';
import 'package:tjara/app/modules/modules_admin/attributes/items.dart';
import 'package:tjara/app/modules/modules_admin/auction_admin/views/auction_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/banners/banners.dart';
import 'package:tjara/app/modules/modules_admin/blogs_categories/blogs_categories.dart';
import 'package:tjara/app/modules/modules_admin/cars/cars_view.dart';
import 'package:tjara/app/modules/modules_admin/cars_products_reviews/view.dart';
import 'package:tjara/app/modules/modules_admin/countriess/country_admins.dart';
import 'package:tjara/app/modules/modules_admin/coupens/add_coupen.dart';
import 'package:tjara/app/modules/modules_admin/coupens/view.dart';
import 'package:tjara/app/modules/modules_admin/disputes/view/disputes_view.dart';
import 'package:tjara/app/modules/modules_admin/emails/emails.dart';
import 'package:tjara/app/modules/modules_admin/faqs/faqs.dart';
import 'package:tjara/app/modules/modules_admin/myshop/view.dart';
import 'package:tjara/app/modules/modules_admin/notification_logs/views/notification_log_view.dart';
import 'package:tjara/app/modules/modules_admin/notifications/notifications.dart';
import 'package:tjara/app/modules/modules_admin/popups/popups.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/views/products_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/products_attributes_group/view.dart';
import 'package:tjara/app/modules/modules_admin/products_review/view.dart';
import 'package:tjara/app/modules/modules_admin/reseller/reseller.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/all_resellers.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/view.dart';
import 'package:tjara/app/modules/modules_admin/services_admin/insert/insert_service.dart';
import 'package:tjara/app/modules/modules_admin/services_admin/insert/service_attributes.dart';
import 'package:tjara/app/modules/modules_admin/services_admin/view/services_view.dart';
import 'package:tjara/app/modules/modules_admin/stories/insert/insert_service.dart';
import 'package:tjara/app/modules/modules_admin/stories/view/stories_view.dart';
import 'package:tjara/app/modules/modules_admin/transactions/transaction_page.dart';
import 'package:tjara/app/modules/modules_admin/users/insert/insert_user.dart';
import 'package:tjara/app/modules/modules_admin/users/view/users_view.dart';
import 'package:tjara/app/modules/modules_admin/withdrawel/withdrawel.dart';
import 'package:tjara/app/modules/modules_admin/surveys/view.dart';
import 'package:tjara/app/modules/modules_customer/my_account/widgets/orders_screen.dart';
import 'package:tjara/app/modules/modules_customer/my_account/widgets/placed_orders_screen.dart';
import 'package:tjara/app/modules/modules_customer/my_activities/my_bids/views/my_bids_view.dart';
import 'package:tjara/app/modules/modules_customer/my_activities/my_job_applications/views/my_job_applications_view.dart';
import 'package:tjara/app/modules/modules_customer/my_activities/my_participations/views/my_participations_view.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/chats.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/shops/shops_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_faqs/faqs.dart';
import 'package:tjara/app/modules/web_settings/content_management/content_management_screen.dart';
import 'package:tjara/app/modules/web_settings/web_settings_dashboard/web_settings_dashboard_screen.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class AdminDrawerWidget extends StatefulWidget {
  const AdminDrawerWidget({super.key});

  @override
  State<AdminDrawerWidget> createState() => _AdminDrawerWidgetState();
}

class _AdminDrawerWidgetState extends State<AdminDrawerWidget> {
  int? expandedIndex;

  List<DrawerMenuModel> get filteredMenus {
    final roleString =
        AuthService.instance.authCustomer?.user?.meta?.dashboardView ??
        // AuthService.instance.authCustomerRx.value?.user?.role ??
        'customer';

    final userRole = RoleMenuConfig.getRoleFromString(roleString);

    // Admin ko sab menus except customer-only ones
    if (userRole == UserRole.admin) {
      return menusList
          .where(
            (menu) => !RoleMenuConfig.customerOnlyMenus.contains(menu.title),
          )
          .toList();
    }

    // Vendor/Customer ko filtered menus
    return menusList
        .where((menu) => RoleMenuConfig.isMenuAllowed(menu.title, userRole))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      color: Colors.white,
      width: size.width * .65,
      child: SafeArea(child: _buildDrawerContent(size)),
    );
  }

  Widget _buildDrawerContent(Size size) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  ...List.generate(
                    filteredMenus.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildDrawerItem(i),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 100,
            height: 60,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.logo),
                fit: BoxFit.contain,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Get.until((route) => route.isFirst);
            },
            icon: const Icon(Icons.close, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int i) {
    final item = filteredMenus[i];
    final roleString =
        AuthService.instance.authCustomerRx.value?.user?.meta?.dashboardView ??
        'customer';
    final userRole = RoleMenuConfig.getRoleFromString(roleString);

    return TileWidget(
      index: i,
      isExpanded: expandedIndex == i,
      onTap: () {
        setState(() {
          expandedIndex = expandedIndex == i ? null : i;
        });
      },
      icon: item.icon,
      title: item.title,
      arrowIcon: item.arrowIcon,
      categoriesList: item.subCategories,
      userRole: userRole,
    );
  }
}

class TileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final IconData? arrowIcon;
  final List<Map<String, dynamic>>? categoriesList;
  final bool isExpanded;
  final int index;
  final VoidCallback onTap;
  final UserRole userRole;

  const TileWidget({
    super.key,
    required this.icon,
    required this.title,
    this.arrowIcon,
    this.categoriesList,
    required this.isExpanded,
    required this.index,
    required this.onTap,
    required this.userRole,
  });

  // Filtered sub-categories based on role
  List<Map<String, dynamic>>? get filteredSubCategories {
    return RoleMenuConfig.filterSubCategories(categoriesList, userRole);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main menu item with modern card a
        Container(
          decoration: BoxDecoration(
            color:
                isExpanded
                    ? const Color(0xFF00897B)
                    : const Color(0xFF00897B).withOpacity(0.01),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(
              icon,
              color: isExpanded ? Colors.white : const Color(0xFF00897B),
              size: 22,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isExpanded ? Colors.white : Colors.black87,
              ),
            ),
            trailing:
                // Arrow sirf tab dikhao jab sub-menus available hain
                (arrowIcon == null ||
                        filteredSubCategories == null ||
                        filteredSubCategories!.isEmpty)
                    ? null
                    : AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        arrowIcon,
                        color: isExpanded ? Colors.white : Colors.black54,
                        size: 20,
                      ),
                    ),
            onTap: _handleTap,
          ),
        ),
        // Expanded sub-items (filtered by role)
        if (isExpanded &&
            filteredSubCategories != null &&
            filteredSubCategories!.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._buildSubItems(),
        ],
      ],
    );
  }

  void _handleTap() {
    // Agar filtered sub-categories empty hain to direct navigate karo
    if (filteredSubCategories == null || filteredSubCategories!.isEmpty) {
      _handleMainItemTap();
    } else {
      onTap();
    }
  }

  void _handleMainItemTap() {
    Get.back();
    switch (title) {
      case 'My bids':
        Get.to(() => MyBidsView());

        break;
      case 'My Participations':
        Get.to(() => MyParticipationsView());

        break;
      case 'My Applications':
        Get.to(() => MyJobApplicationsView());

        break;
      case 'My Shop':
        Get.to(() => const MyShopScreen());
        break;
      case 'My shop':
        // Title variant used in menusList
        Get.to(() => const MyShopScreen());
        break;
      case 'Settings':
        Get.to(() => const WebSettingsDashboardScreen());
        break;
      case 'Resellers':
        Get.to(() => const AllResellerProgramScreen());
        break;
      case 'Withdrawals':
        Get.to(() => AllWithdrawalsScreen());
        break;
      case 'My Withdrawals':
        Get.to(() => UserWithdrawalsScreen());
        break;
      case 'Auctions':
        Get.to(() => const AuctionAdminView());
        break;
      case 'Shops':
        Get.to(() => const ShopView());
        break;
      case 'Product Inquiry Chats':
        Get.to(() => const ChatsScreenView());
        break;
      case 'Countries':
        Get.to(() => CountryPage());
        break;
      case 'Transactions':
        Get.to(() => TransactionPage());
        break;
      case 'My Tjara Reseller Club':
        Get.to(() => const ResellerProgramScreen());
        break;
      case 'Bulk Emails':
        Get.to(() => const EmailMainScreen());
        break;
      case 'Bulk Notifications':
        Get.to(() => NotificationFormScreen());
        break;
      case 'Help & Center':
        Get.to(() => const DashboardHelpCenterScreen());
        break;
    }
  }

  List<Widget> _buildSubItems() {
    return filteredSubCategories!.map((item) {
      return Container(
        margin: const EdgeInsets.only(left: 16, bottom: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          minVerticalPadding: 0,
          dense: true,
          onTap: () => _handleSubItemTap(item['title']),
          leading: Icon(item['icon'], color: const Color(0xFF00897B), size: 20),
          title: Text(
            item['title'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _handleSubItemTap(String title) {
    Get.back();
    switch (title) {
      case 'My bids':
        Get.to(() => MyBidsView());

        break;
      case 'My Participations':
        Get.to(() => MyParticipationsView());

        break;
      case 'My Applications':
        Get.to(() => MyJobApplicationsView());

        break;

      case 'Products':
        Get.to(() => const ProductsAdminView());
        break;
      case 'Categories':
        Get.toNamed(Routes.ADMIN_CATEGORIES_VIEW, preventDuplicates: false);
        break;
      case 'Car Categories':
        Get.toNamed(
          Routes.ADMIN_CATEGORIES_VIEW,
          arguments: 'car',
          preventDuplicates: false,
        );
        break;
      case 'Add Products':
        Get.delete<AddProductAdminController>();
        Get.toNamed(Routes.ADD_PRODUCT_ADMIN_VIEW, preventDuplicates: false);
      case 'Products Configs':
        Get.to(() => const AdminProductsConfigView());

      case 'Add Car':
        Get.toNamed(
          Routes.ADD_PRODUCT_ADMIN_VIEW,
          preventDuplicates: false,
          arguments: 'car',
        );
        break;
      case 'Jobs':
        Get.to(() => const AdminJobsView());
        break;
      case 'Add Job':
        Get.to(() => const InsertJobScreen());
        break;
      case 'Job Categories':
        Get.to(() => JobAttributeView());
        break;
      case 'Contests':
        Get.to(() => const AdminContestsView());
        break;
      case 'Services':
        Get.to(() => const AdminServiceView());
        break;
      case 'Stories':
        Get.to(() => const AdminStoriesView());
        break;
      case 'Add Service':
        Get.to(() => const InsertServiceScreen());
        break;
      case 'Add Stories':
        Get.to(() => const InsertServiceScreen());
        break;
      case 'Cars':
        Get.to(() => const CarsView());
        break;
      case 'Received Disputes':
        Get.to(() => const AdminDisputesView(), preventDuplicates: false);
      case 'Placed Disputes':
        Get.to(
          () => const AdminDisputesView(),
          preventDuplicates: false,
          arguments: AuthService.instance.authCustomerRx.value?.user?.id ?? '',
        );
        break;
      case 'Service Attributes':
        Get.to(() => const ServiceAttributesScreen());
        break;
      case 'Add Story':
        Get.to(() => const InsertStoryScreen());
        break;
      case 'Add Contest':
        Get.to(() => const QuizForm());
        break;
      case 'Users':
        Get.to(() => const AdminUsersView());
        break;
      case 'Add User':
        Get.to(() => const InsertNewUser());
        break;
      case 'FAQs':
        Get.to(() => FAQListScreen());
        break;
      case 'Add FAQ':
        Get.to(() => const FAQFormScreen());
        break;
      case 'Discount Banners':
        Get.to(() => const DiscountBannersScreen());
        break;
      case 'Home Banners':
        Get.to(() => const homeHeroBannersScreen());
        break;
      case 'Club Page Banners':
        Get.to(() => const HeroBannersScreen());
        break;
      case 'Sale Banners':
        Get.to(() => const SaleBannersScreen());
        break;
      case 'Blogs':
        Get.to(() => const BlogsBannersScreen());
        break;
      case 'Popups':
        Get.put(ApiService());
        Get.put(PopupController());
        Get.to(() => const PopupListView());
        break;
      case 'Add Popup':
        Get.put(ApiService());
        Get.put(PopupController());
        Get.to(() => AddPopupView());
        break;
      case 'Product Reviews':
        Get.to(() => const ProductReviewScreen(name: 'Product Reviews'));
        break;
      case 'Reviews':
        Get.to(() => const CarsProductReviewScreen(name: 'Cars Reviews'));
        break;
      case 'Attributes':
        Get.to(() => const ProductAttributesScreen());
        break;
      case 'Attributes Groups':
        Get.to(() => const AttributeGroupListScreen());
        break;
      case 'Orders':
        Get.to(() => const OrdersScreen());
        break;
      case 'Placed Orders':
        Get.to(
          () => PlacedOrdersScreen(
            userId: AuthService.instance.authCustomerRx.value?.user?.id,
          ),
        );
        break;
      case 'My Tjara Reseller Club':
        Get.to(() => const ResellerProgramScreen());
        break;
      case 'Blog Categories':
        Get.to(() => CategoryManagementScreen());
        break;
      case 'Reseller Levels':
        Get.to(() => const ResellerListPage());
        break;
      case 'Coupens':
        Get.to(() => CouponScreen());
        break;
      case 'Add Coupens':
        Get.to(() => AddCouponPage());
        break;
      case 'Website Content':
        Get.to(() => ContentManagementScreen());
        break;
      case 'Notification Logs':
        Get.to(() => const NotificationLogView());
        break;
      case 'Surveys':
        Get.to(() => const SurveyListScreen());
        break;
      case 'Years':
        Get.to(
          () => const ProductAttributeItemsScreen(
            attributeId: '0000c539-9857-4b08-3556-2bbdc1474f1a',
            attributeSymbol: 'years',
            attributeName: 'Years',
          ),
        );
        break;
    }
  }
}

class DrawerMenuModel {
  final String title;
  final IconData icon;
  final IconData? arrowIcon;
  final List<Map<String, dynamic>>? subCategories;

  DrawerMenuModel({
    required this.title,
    required this.icon,
    this.subCategories,
    this.arrowIcon,
  });
}

// ============================================
// ROLE-BASED MENU CONFIGURATION
// ============================================
// Yahan easily configure karo ke kis role ko kya menus/submenus dikhne chahiye
// 'all' means sab menus milenge

enum UserRole { admin, vendor, customer }

class RoleMenuConfig {
  // ==========================================
  // CUSTOMER-ONLY MENUS - Yeh sirf customer ko dikhenge
  // ==========================================
  static const List<String> customerOnlyMenus = [
    'My bids',
    'My Participations',
    'My Applications',
  ];

  // ==========================================
  // ADMIN CONFIG - Sab kuch allowed
  // ==========================================
  static const List<String> adminMenus = ['all'];
  static const List<String> adminSubMenus = ['all'];

  // ==========================================
  // VENDOR CONFIG - Yahan customize karo
  // ==========================================
  static const List<String> vendorMenus = [
    'Products',
    'Auctions',
    'Cars',
    'Services',
    'Orders',
    'Disputes',
    'My shop',
    'My Tjara Reseller Club',
    'Product Inquiry Chats',
    'My Withdrawals',
    'Jobs',
    'Stories',
    'Help & Center',
  ];

  // Vendor ke allowed sub-menus - yahan add/remove karo
  static const List<String> vendorSubMenus = [
    // Products ke under
    'Products',
    'Add Products',
    'Product Reviews',

    // 'Categories',      // <-- Vendor ko nahi dikhega

    // 'Attributes',      // <-- Vendor ko nahi dikhega
    'Cars',
    'Add Car',
    'Services',
    // 'Add Services',
    // Orders ke under
    'Orders',
    'Placed Orders',

    // Disputes ke under
    'Received Disputes',
    'Placed Disputes',

    // Coupens ke under
    'Coupens',
    'Add Coupens',

    //jobs
    'Add Job',
    'Jobs',

    'Add Stories',
    'Stories',
  ];

  // ==========================================
  // CUSTOMER CONFIG - Yahan customize karo
  // ==========================================
  static const List<String> customerMenus = [
    'Orders',
    'Disputes',
    'My Applications',
    'My Participations',
    'My bids',
    'My Tjara Reseller Club',
    'Product Inquiry Chats',
    'Help & Center',
  ];

  // Customer ke allowed sub-menus
  static const List<String> customerSubMenus = [
    'Placed Orders',
    'Placed Disputes',
  ];

  // ==========================================
  // HELPER METHODS - Inhe change mat karo
  // ==========================================

  static UserRole getRoleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'vendor':
        return UserRole.vendor;
      default:
        return UserRole.customer;
    }
  }

  static List<String> getAllowedMenus(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminMenus;
      case UserRole.vendor:
        return vendorMenus;
      case UserRole.customer:
        return customerMenus;
    }
  }

  static List<String> getAllowedSubMenus(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminSubMenus;
      case UserRole.vendor:
        return vendorSubMenus;
      case UserRole.customer:
        return customerSubMenus;
    }
  }

  static bool isMenuAllowed(String menuTitle, UserRole role) {
    final allowedMenus = getAllowedMenus(role);
    if (allowedMenus.contains('all')) return true;
    return allowedMenus.contains(menuTitle);
  }

  static bool isSubMenuAllowed(String subMenuTitle, UserRole role) {
    final allowedSubMenus = getAllowedSubMenus(role);
    if (allowedSubMenus.contains('all')) return true;
    return allowedSubMenus.contains(subMenuTitle);
  }

  // Sub-categories filter karo role ke hisaab se
  static List<Map<String, dynamic>>? filterSubCategories(
    List<Map<String, dynamic>>? subCategories,
    UserRole role,
  ) {
    if (subCategories == null || subCategories.isEmpty) return subCategories;
    if (getAllowedSubMenus(role).contains('all')) return subCategories;

    return subCategories
        .where((sub) => isSubMenuAllowed(sub['title'] as String, role))
        .toList();
  }
}

final List<DrawerMenuModel> menusList = [
  DrawerMenuModel(
    title: 'Products',
    icon: Icons.grid_view_rounded,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Products', 'icon': Icons.grid_view_rounded},
      {'title': 'Add Products', 'icon': Icons.add_circle_outline},
      {'title': 'Products Configs', 'icon': Icons.accessibility_sharp},
      {'title': 'Categories', 'icon': Icons.category_outlined},
      {'title': 'Product Reviews', 'icon': Icons.pie_chart_outline},
      {'title': 'Attributes', 'icon': Icons.local_shipping_outlined},
      {'title': 'Attributes Groups', 'icon': Icons.local_attraction},
    ],
  ),
  DrawerMenuModel(
    title: 'Auctions',
    icon: Icons.description_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Cars',
    icon: Icons.directions_car_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Cars', 'icon': Icons.directions_car_outlined},
      {'title': 'Add Car', 'icon': Icons.add_circle_outline},
      {'title': 'Car Categories', 'icon': Icons.category_outlined},
      {'title': 'Years', 'icon': Icons.calendar_today_outlined},
      {'title': 'Reviews', 'icon': Icons.star_outline},
    ],
  ),
  DrawerMenuModel(
    title: 'Jobs',
    icon: Icons.work_outline,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Jobs', 'icon': Icons.work_outline},
      {'title': 'Add Job', 'icon': Icons.add_circle_outline},
      {'title': 'Job Categories', 'icon': Icons.category_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Services',
    icon: Icons.business_center_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Services', 'icon': Icons.business_center_outlined},
      {'title': 'Service Attributes', 'icon': Icons.category_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Contests',
    icon: Icons.emoji_events_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Contests', 'icon': Icons.emoji_events_outlined},
      {'title': 'Add Contest', 'icon': Icons.add_circle_outline},
    ],
  ),
  DrawerMenuModel(
    title: 'Orders',
    icon: Icons.shopping_bag_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Orders', 'icon': Icons.inbox_outlined},
      {'title': 'Placed Orders', 'icon': Icons.send_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Disputes',
    icon: Icons.report_problem_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Received Disputes', 'icon': Icons.error_outline},
      {'title': 'Placed Disputes', 'icon': Icons.warning_amber_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Users',
    icon: Icons.person_outline,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Users', 'icon': Icons.people_outline},
      {'title': 'Add User', 'icon': Icons.person_add_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Shops',
    icon: Icons.store_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'My shop',
    icon: Icons.storefront_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'My Applications',

    icon: Icons.app_settings_alt_rounded,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'My Participations',

    icon: Icons.paragliding,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'My bids',
    icon: Icons.bakery_dining,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Resellers',
    icon: Icons.store_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Reseller Level',
    icon: Icons.store_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Reseller Levels', 'icon': Icons.leaderboard_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'My Tjara Reseller Club',
    icon: Icons.store_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Settings',
    icon: Icons.settings_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Blogs',
    icon: Icons.article_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Blogs', 'icon': Icons.article_outlined},
      {'title': 'Blog Categories', 'icon': Icons.category_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Stories',
    icon: Icons.auto_stories_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Stories', 'icon': Icons.menu_book_outlined},
      {'title': 'Add Story', 'icon': Icons.add_circle_outline},
    ],
  ),
  DrawerMenuModel(
    title: 'Sale Banners',
    icon: Icons.discount_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Sale Banners', 'icon': Icons.label_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Hero Banners',
    icon: Icons.adjust_sharp,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Home Banners', 'icon': Icons.label_outlined},
      {'title': 'Club Page Banners', 'icon': Icons.label_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Discount Banners',
    icon: Icons.discount_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Discount Banners', 'icon': Icons.local_offer_outlined},
    ],
  ),
  DrawerMenuModel(
    title: 'Popups',
    icon: Icons.notifications_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Popups', 'icon': Icons.campaign_outlined},
      {'title': 'Add Popup', 'icon': Icons.add_circle_outline},
    ],
  ),
  DrawerMenuModel(
    title: 'FAQs',
    icon: Icons.help_outline,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'FAQs', 'icon': Icons.quiz_outlined},
      {'title': 'Add FAQ', 'icon': Icons.add_circle_outline},
    ],
  ),
  DrawerMenuModel(
    title: 'Countries',
    icon: Icons.language_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Coupens',
    icon: Icons.confirmation_number_outlined,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Coupens', 'icon': Icons.local_offer_outlined},
      {'title': 'Add Coupens', 'icon': Icons.add_circle_outline},
    ],
  ),
  DrawerMenuModel(
    title: 'Notification Logs',
    icon: Icons.notifications_paused_sharp,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Notification Logs', 'icon': Icons.notifications_paused_sharp},
    ],
  ),
  DrawerMenuModel(
    title: 'Content Managment',
    icon: Icons.confirmation_num,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Website Content', 'icon': Icons.confirmation_num},
    ],
  ),
  DrawerMenuModel(
    title: 'Surveys',
    icon: Icons.surfing,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Surveys', 'icon': Icons.surfing},
    ],
  ),
  DrawerMenuModel(
    title: 'Transactions',
    icon: Icons.account_balance_wallet_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Withdrawals',
    icon: Icons.account_balance_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'My Withdrawals',
    icon: Icons.account_balance_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Bulk Notifications',
    icon: Icons.notifications_active_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Bulk Emails',
    icon: Icons.email_outlined,
    subCategories: [],
  ),
  DrawerMenuModel(
    title: 'Product Inquiry Chats',
    icon: Icons.chat_bubble_outline,
    subCategories: [],
  ),
  DrawerMenuModel(title: 'Help & Center', icon: Icons.help, subCategories: []),
];
