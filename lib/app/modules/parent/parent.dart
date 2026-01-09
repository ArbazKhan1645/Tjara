// // parent_admin_controller.dart
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
// import 'package:tjara/app/modules/admin/add_product_admin/views/add_product_admin_view.dart';
// import 'package:tjara/app/modules/admin/admin_contexts/insert.dart';
// import 'package:tjara/app/modules/admin/admin_contexts/view/contests_view.dart';
// import 'package:tjara/app/modules/admin/admin_jobs/view/attributes_view.dart';
// import 'package:tjara/app/modules/admin/admin_jobs/view/insert_job.dart';
// import 'package:tjara/app/modules/admin/admin_jobs/view/jobs_view.dart';
// import 'package:tjara/app/modules/admin/attributes/attributes.dart';
// import 'package:tjara/app/modules/admin/auction_admin/views/auction_admin_view.dart';
// import 'package:tjara/app/modules/admin/banners/banners.dart';
// import 'package:tjara/app/modules/admin/cars/cars_view.dart';
// import 'package:tjara/app/modules/admin/cars_products_reviews/view.dart';
// import 'package:tjara/app/modules/admin/categories_admin/views/categories_admin_view.dart';
// import 'package:tjara/app/modules/admin/countriess/country_admins.dart';
// import 'package:tjara/app/modules/admin/dashboard_admin/views/dashboard_admin_view.dart';
// import 'package:tjara/app/modules/admin/disputes/view/disputes_view.dart';
// import 'package:tjara/app/modules/admin/emails/emails.dart';
// import 'package:tjara/app/modules/admin/faqs/faqs.dart';
// import 'package:tjara/app/modules/admin/notifications/notifications.dart';
// import 'package:tjara/app/modules/admin/popups/popups.dart';
// import 'package:tjara/app/modules/admin/products_admin/views/products_admin_view.dart';
// import 'package:tjara/app/modules/admin/products_review/view.dart';
// import 'package:tjara/app/modules/admin/services_admin/insert/insert_service.dart';
// import 'package:tjara/app/modules/admin/services_admin/insert/service_attributes.dart';
// import 'package:tjara/app/modules/admin/services_admin/view/services_view.dart';
// import 'package:tjara/app/modules/admin/stories/insert/insert_service.dart';
// import 'package:tjara/app/modules/admin/stories/view/stories_view.dart';
// import 'package:tjara/app/modules/admin/transactions/transaction_page.dart';
// import 'package:tjara/app/modules/admin/users/insert/insert_user.dart';
// import 'package:tjara/app/modules/admin/users/view/users_view.dart';
// import 'package:tjara/app/modules/admin/websettings/websettings_view.dart';
// import 'package:tjara/app/modules/my_account/widgets/orders_screen.dart';
// import 'package:tjara/app/modules/orders_dashboard/widgets/chats.dart';
// import 'package:tjara/app/modules/orders_dashboard/widgets/orders_dashboard_widget.dart';
// import 'package:tjara/app/modules/samad/views/shops/shops_view.dart';
// import 'package:tjara/app/services/auth/auth_service.dart';

// class ParentAdminController extends GetxController {
//   // Current screen management
//   final RxString currentScreenTitle = 'Dashboard'.obs;
//   final RxString currentScreenKey = 'dashboard'.obs;
//   final RxBool isDrawerOpen = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Initialize with dashboard
//     setCurrentScreen('Dashboard', 'dashboard');
//   }

//   @override
//   void onClose() {
//     // Clear cache when controller is disposed

//     super.onClose();
//   }

//   void setCurrentScreen(String title, String screenKey) {
//     // Clean up previous screen's controller if it exists

//     currentScreenTitle.value = title;
//     currentScreenKey.value = screenKey;
//   }

//   Widget getCurrentScreen() {
//     final screenKey = currentScreenKey.value;

//     // Create new screen widget
//     Widget screen = _createScreenWidget(screenKey);

//     return screen;
//   }

//   Widget _createScreenWidget(String screenKey) {
//     switch (screenKey) {
//       case 'dashboard':
//         return DashboardAdminView();

//       case 'Products':
//         return ProductsAdminView();

//       case 'Categories':
//         return CategoriesAdminView();

//       case 'Add Products':
//         return AddProductAdminView();

//       case 'Add Car':
//         return AddProductAdminView();

//       case 'Jobs':
//         return AdminJobsView();

//       case 'Add Job':
//         return InsertJobScreen();

//       case 'Job Categories':
//         return JobAttributeView();

//       case 'Contests':
//         return AdminContestsView();

//       case 'Services':
//         return AdminServiceView();

//       case 'Stories':
//         return AdminStoriesView();

//       case 'Add Service':
//         return InsertServiceScreen();

//       case 'Add Stories':
//         return InsertServiceScreen();

//       case 'Cars':
//         return CarsView();

//       case 'Received Disputes':
//         return AdminDisputesView();

//       case 'My Tjara Reseller Club':
//         return Container(); // Placeholder

//       case 'Service Attributes':
//         return ServiceAttributesScreen();

//       case 'Add Story':
//         return InsertStoryScreen();

//       case 'Add Contest':
//         return QuizForm();

//       case 'Users':
//         return AdminUsersView();

//       case 'Add User':
//         return InsertNewUser();

//       case 'FAQs':
//         return FAQListScreen();

//       case 'Add FAQ':
//         return FAQFormScreen();

//       case 'Discount Banners':
//         return DiscountBannersScreen();

//       case 'Hero Banners':
//         return HeroBannersScreen();

//       case 'Sale Banners':
//         return SaleBannersScreen();

//       case 'Blogs':
//         return BlogsBannersScreen();

//       case 'Popups':
//         Get.put(ApiService());
//         Get.put(PopupController());
//         return PopupListView();

//       case 'Add Popup':
//         Get.put(ApiService());
//         Get.put(PopupController());
//         return AddPopupView();

//       case 'Product Reviews':
//         return ProductReviewScreen(name: 'Product Reviews');

//       case 'Reviews':
//         return CarsProductReviewScreen(name: 'Cars Reviews');

//       case 'Attributes':
//         return ProductAttributesScreen();

//       case 'Received Orders':
//         return Scaffold(body: OrdersScreen());

//       case 'Placed Orders':
//         return Scaffold(
//           body: OrdersScreen(
//             userId: AuthService.instance.authCustomerRx.value?.user?.id,
//           ),
//         );
//       case 'Settings':
//         return WebSettingsView();

//       case 'Auctions':
//         return AuctionAdminView();

//       case 'Shops':
//         return ShopView();

//       case 'Product Inquiry Chats':
//         return ChatsScreenView();

//       case 'Countries':
//         return CountryPage();

//       case 'Transactions':
//         return TransactionPage();

//       case 'Bulk Emails':
//         return EmailMainScreen();

//       case 'Bulk Notifications':
//         return NotificationFormScreen();

//       default:
//         return Container();
//     }
//   }

//   void toggleDrawer() {
//     isDrawerOpen.value = !isDrawerOpen.value;
//   }

//   void closeDrawer() {
//     Get.back();
//   }

//   void goBack() {}
// }

// // parent_admin_view.dart
// class ParentAdminView extends GetView<ParentAdminController> {
//   const ParentAdminView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ParentAdminController>(
//       init: ParentAdminController(),
//       builder: (controller) {
//         return Scaffold(
//           drawer: OptimizedAdminDrawer(),

//           appBar: AppBar(),
//           body: Obx(() => controller.getCurrentScreen()),
//         );
//       },
//     );
//   }
// }

// // optimized_admin_drawer.dart
// class OptimizedAdminDrawer extends GetView<ParentAdminController> {
//   const OptimizedAdminDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.65,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(2, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildDrawerHeader(),
//           Expanded(
//             child: ListView.builder(
//               itemCount: optimizedMenusList.length,
//               itemBuilder: (context, index) {
//                 return OptimizedDrawerTile(
//                   menuItem: optimizedMenusList[index],
//                   onItemTap: _handleItemTap,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerHeader() {
//     return Container(
//       height: 80,
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/icons/logo.png'),
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleItemTap(String title, String screenKey) {
//     controller.setCurrentScreen(title, screenKey);
//     controller.closeDrawer();
//   }
// }

// // optimized_drawer_tile.dart
// class OptimizedDrawerTile extends StatefulWidget {
//   final OptimizedMenuModel menuItem;
//   final Function(String title, String screenKey) onItemTap;

//   const OptimizedDrawerTile({
//     super.key,
//     required this.menuItem,
//     required this.onItemTap,
//   });

//   @override
//   State<OptimizedDrawerTile> createState() => _OptimizedDrawerTileState();
// }

// class _OptimizedDrawerTileState extends State<OptimizedDrawerTile> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           leading: Icon(widget.menuItem.icon, color: Colors.pink, size: 20),
//           title: Text(
//             widget.menuItem.title,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           trailing:
//               widget.menuItem.hasSubItems
//                   ? AnimatedRotation(
//                     turns: isExpanded ? 0.5 : 0.0,
//                     duration: const Duration(milliseconds: 200),
//                     child: const Icon(
//                       Icons.keyboard_arrow_down_rounded,
//                       size: 18,
//                     ),
//                   )
//                   : null,
//           onTap: () {
//             if (widget.menuItem.hasSubItems) {
//               setState(() {
//                 isExpanded = !isExpanded;
//               });
//             } else {
//               widget.onItemTap(widget.menuItem.title, widget.menuItem.title);
//             }
//           },
//         ),
//         if (isExpanded && widget.menuItem.hasSubItems)
//           ...widget.menuItem.subItems.map(
//             (subItem) => Padding(
//               padding: const EdgeInsets.only(left: 32),
//               child: ListTile(
//                 leading: Icon(subItem.icon, color: Colors.pink, size: 18),
//                 title: Text(
//                   subItem.title,
//                   style: const TextStyle(fontSize: 13),
//                 ),
//                 onTap: () => widget.onItemTap(subItem.title, subItem.title),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// // optimized_menu_model.dart
// class OptimizedMenuModel {
//   final String title;
//   final String screenKey;
//   final IconData icon;
//   final List<OptimizedSubMenuItem> subItems;

//   OptimizedMenuModel({
//     required this.title,
//     required this.screenKey,
//     required this.icon,
//     this.subItems = const [],
//   });

//   bool get hasSubItems => subItems.isNotEmpty;
// }

// class OptimizedSubMenuItem {
//   final String title;
//   final String screenKey;
//   final IconData icon;

//   OptimizedSubMenuItem({
//     required this.title,
//     required this.screenKey,
//     required this.icon,
//   });
// }

// // Menu data configuration
// final List<OptimizedMenuModel> optimizedMenusList = [
//   OptimizedMenuModel(
//     title: 'Dashboard',
//     screenKey: 'dashboard',
//     icon: Icons.dashboard_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Products',
//     screenKey: 'products',
//     icon: Icons.inventory_2_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Products',
//         screenKey: 'products',
//         icon: Icons.article,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add Products',
//         screenKey: 'add_products',
//         icon: Icons.add,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Categories',
//         screenKey: 'categories',
//         icon: Icons.category,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Product Reviews',
//         screenKey: 'product_reviews',
//         icon: Icons.star,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Attributes',
//         screenKey: 'attributes',
//         icon: Icons.tune,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Cars',
//     screenKey: 'cars',
//     icon: Icons.directions_car_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Cars',
//         screenKey: 'cars',
//         icon: Icons.directions_car,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add Car',
//         screenKey: 'add_car',
//         icon: Icons.add,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Reviews',
//         screenKey: 'car_reviews',
//         icon: Icons.star,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Stories',
//     screenKey: 'stories',
//     icon: Icons.library_books_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Stories',
//         screenKey: 'stories',
//         icon: Icons.library_books,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add Story',
//         screenKey: 'add_story',
//         icon: Icons.add,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Jobs',
//     screenKey: 'jobs',
//     icon: Icons.work_outline,
//     subItems: [
//       OptimizedSubMenuItem(title: 'Jobs', screenKey: 'jobs', icon: Icons.work),
//       OptimizedSubMenuItem(
//         title: 'Add Job',
//         screenKey: 'add_job',
//         icon: Icons.add,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Job Categories',
//         screenKey: 'job_categories',
//         icon: Icons.category,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Services',
//     screenKey: 'services',
//     icon: Icons.handyman_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Services',
//         screenKey: 'services',
//         icon: Icons.handyman,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add Service',
//         screenKey: 'add_service',
//         icon: Icons.add,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Service Attributes',
//         screenKey: 'service_attributes',
//         icon: Icons.tune,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Contests',
//     screenKey: 'contests',
//     icon: Icons.emoji_events_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Contests',
//         screenKey: 'contests',
//         icon: Icons.emoji_events,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add Contest',
//         screenKey: 'add_contest',
//         icon: Icons.add,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Orders',
//     screenKey: 'orders',
//     icon: Icons.shopping_bag_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Received Orders',
//         screenKey: 'received_orders',
//         icon: Icons.inbox,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Placed Orders',
//         screenKey: 'placed_orders',
//         icon: Icons.outbox,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Disputes',
//     screenKey: 'disputes',
//     icon: Icons.error_outline,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Received Disputes',
//         screenKey: 'received_disputes',
//         icon: Icons.error,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Users',
//     screenKey: 'users',
//     icon: Icons.people_outline,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Users',
//         screenKey: 'users',
//         icon: Icons.people,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add User',
//         screenKey: 'add_user',
//         icon: Icons.person_add,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Shops',
//     screenKey: 'shops',
//     icon: Icons.storefront_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'My Shop',
//     screenKey: 'my_shop',
//     icon: Icons.store_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Reseller Club',
//     screenKey: 'reseller_club',
//     icon: Icons.group_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Banners',
//     screenKey: 'banners',
//     icon: Icons.image_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Sale Banners',
//         screenKey: 'sale_banners',
//         icon: Icons.local_offer,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Hero Banners',
//         screenKey: 'hero_banners',
//         icon: Icons.view_carousel,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Discount Banners',
//         screenKey: 'discount_banners',
//         icon: Icons.discount,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Auctions',
//     screenKey: 'auctions',
//     icon: Icons.gavel_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Popups',
//     screenKey: 'popups',
//     icon: Icons.notification_important_outlined,
//     subItems: [
//       OptimizedSubMenuItem(
//         title: 'Popups',
//         screenKey: 'popups',
//         icon: Icons.notification_important,
//       ),
//       OptimizedSubMenuItem(
//         title: 'Add Popup',
//         screenKey: 'add_popup',
//         icon: Icons.add,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'FAQs',
//     screenKey: 'faqs',
//     icon: Icons.help_outline,
//     subItems: [
//       OptimizedSubMenuItem(title: 'FAQs', screenKey: 'faqs', icon: Icons.help),
//       OptimizedSubMenuItem(
//         title: 'Add FAQ',
//         screenKey: 'add_faq',
//         icon: Icons.add,
//       ),
//     ],
//   ),
//   OptimizedMenuModel(
//     title: 'Settings',
//     screenKey: 'settings',
//     icon: Icons.settings_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Countries',
//     screenKey: 'countries',
//     icon: Icons.public_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Transactions',
//     screenKey: 'transactions',
//     icon: Icons.payment_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Bulk Notifications',
//     screenKey: 'bulk_notifications',
//     icon: Icons.notifications_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Bulk Emails',
//     screenKey: 'bulk_emails',
//     icon: Icons.email_outlined,
//   ),
//   OptimizedMenuModel(
//     title: 'Product Inquiry Chats',
//     screenKey: 'product_chats',
//     icon: Icons.chat_outlined,
//   ),
// ];

// // Placeholder screen widgets (replace with your actual implementations)
// class _AdminDashboardScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.dashboard, size: 64, color: Colors.pink),
//           SizedBox(height: 16),
//           Text(
//             'Admin Dashboard',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text('Welcome to the admin panel'),
//         ],
//       ),
//     );
//   }
// }
