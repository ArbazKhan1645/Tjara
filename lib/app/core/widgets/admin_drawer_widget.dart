import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_contexts/insert.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_contexts/view/contests_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/view/attributes_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/view/insert_job.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/view/jobs_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/attributes/attributes.dart';
import 'package:tjara/app/modules/modules_admin/admin/attributes/items.dart';
import 'package:tjara/app/modules/modules_admin/admin/auction_admin/views/auction_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/banners/banners.dart';
import 'package:tjara/app/modules/modules_admin/admin/blogs_categories/blogs_categories.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/cars_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars_products_reviews/view.dart';
import 'package:tjara/app/modules/modules_admin/admin/countriess/country_admins.dart';
import 'package:tjara/app/modules/modules_admin/admin/coupens/add_coupen.dart';
import 'package:tjara/app/modules/modules_admin/admin/coupens/view.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/disputes_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/emails/emails.dart';
import 'package:tjara/app/modules/modules_admin/admin/faqs/faqs.dart';
import 'package:tjara/app/modules/modules_admin/admin/myshop/view.dart';
import 'package:tjara/app/modules/modules_admin/admin/notifications/notifications.dart';
import 'package:tjara/app/modules/modules_admin/admin/popups/popups.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/views/products_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_review/view.dart';
import 'package:tjara/app/modules/modules_admin/admin/reseller/reseller.dart';
import 'package:tjara/app/modules/modules_admin/admin/reseller_programs/all_resellers.dart';
import 'package:tjara/app/modules/modules_admin/admin/reseller_programs/view.dart';
import 'package:tjara/app/modules/modules_admin/admin/services_admin/insert/insert_service.dart';
import 'package:tjara/app/modules/modules_admin/admin/services_admin/insert/service_attributes.dart';
import 'package:tjara/app/modules/modules_admin/admin/services_admin/view/services_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/stories/insert/insert_service.dart';
import 'package:tjara/app/modules/modules_admin/admin/stories/view/stories_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/transactions/transaction_page.dart';
import 'package:tjara/app/modules/modules_admin/admin/users/insert/insert_user.dart';
import 'package:tjara/app/modules/modules_admin/admin/users/view/users_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/websettings/websettings_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/withdrawel/withdrawel.dart';
import 'package:tjara/app/modules/modules_customer/my_account/widgets/orders_screen.dart';
import 'package:tjara/app/modules/modules_customer/my_account/widgets/placed_orders_screen.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/chats.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/shops/shops_view.dart';
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
    final userRole =
        AuthService.instance.role ??
        AuthService.instance.authCustomerRx.value?.user?.role ??
        'customer';

    if (userRole == 'admin') {
      return menusList;
    } else {
      return menusList
          .where((menu) => nonAdminAllowedMenus.contains(menu.title))
          .toList();
    }
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

  const TileWidget({
    super.key,
    required this.icon,
    required this.title,
    this.arrowIcon,
    this.categoriesList,
    required this.isExpanded,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main menu item with modern card design
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
                arrowIcon == null
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
        // Expanded sub-items
        if (isExpanded && categoriesList != null) ...[
          const SizedBox(height: 8),
          ..._buildSubItems(),
        ],
      ],
    );
  }

  void _handleTap() {
    if (categoriesList == null || categoriesList!.isEmpty) {
      _handleMainItemTap();
    } else {
      onTap();
    }
  }

  void _handleMainItemTap() {
    Get.back();
    switch (title) {
      case 'My Shop':
        Get.to(() => const MyShopScreen());
        break;
      case 'My shop':
        // Title variant used in menusList
        Get.to(() => const MyShopScreen());
        break;
      case 'Settings':
        Get.to(() => const WebSettingsView());
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
    }
  }

  List<Widget> _buildSubItems() {
    return categoriesList!.map((item) {
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
      case 'Club Hero Banners':
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

final List<String> nonAdminAllowedMenus = [
  'Orders',
  'My Tjara Reseller Club',
  'Product Inquiry Chats',
  'My Withdrawals',
];

final List<DrawerMenuModel> menusList = [
  DrawerMenuModel(
    title: 'Products',
    icon: Icons.grid_view_rounded,
    arrowIcon: Icons.keyboard_arrow_down_rounded,
    subCategories: [
      {'title': 'Products', 'icon': Icons.grid_view_rounded},
      {'title': 'Add Products', 'icon': Icons.add_circle_outline},
      {'title': 'Categories', 'icon': Icons.category_outlined},
      {'title': 'Product Reviews', 'icon': Icons.pie_chart_outline},
      {'title': 'Attributes', 'icon': Icons.local_shipping_outlined},
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
];
