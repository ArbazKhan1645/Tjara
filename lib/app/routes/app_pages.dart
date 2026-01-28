import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/bindings/add_product_auction_admin_binding.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/views/add_product_auction_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/bindings/add_product_admin_binding.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/categories_admin/bindings/categories_admin_binding.dart';
import 'package:tjara/app/modules/modules_admin/admin/categories_admin/views/categories_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/dashboard_admin/bindings/dashboard_admin_binding.dart';
import 'package:tjara/app/modules/modules_admin/admin/dashboard_admin/views/dashboard_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/bindings/products_admin_binding.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/views/products_admin_view.dart';
import 'package:tjara/app/modules/authentication/bindings/authentication_binding.dart';
import 'package:tjara/app/modules/authentication/views/authentication_view.dart';
import 'package:tjara/app/modules/modules_customer/order_checkout/bindings/checkout_binding.dart';
import 'package:tjara/app/modules/modules_customer/order_checkout/views/checkout_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/bindings/contests_binding.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/views/contests_view.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/bindings/dashboard_binding.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/views/dashboard_view.dart';
import 'package:tjara/app/modules/modules_customer/app_home/bindings/home_binding.dart';
import 'package:tjara/app/modules/modules_customer/app_home/views/home_view.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/screens/shopping_cart.dart';
import 'package:tjara/app/modules/modules_customer/dashboard_more/bindings/more_binding.dart';
import 'package:tjara/app/modules/modules_customer/dashboard_more/views/more_view.dart';
import 'package:tjara/app/modules/modules_customer/my_account/bindings/my_account_binding.dart';
import 'package:tjara/app/modules/modules_customer/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/bindings/my_cart_binding.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/views/my_cart_view.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/bindings/orders_dashboard_binding.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/views/orders_dashboard_view.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/bindings/product_detail_screen_binding.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/views/product_detail_screen_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_services/view/service+view.dart';
import 'package:tjara/app/modules/splash_screen/bindings/splash_screen_binding.dart';
import 'package:tjara/app/modules/splash_screen/views/splash_screen_view.dart';
import 'package:tjara/app/modules/modules_customer/store_page/bindings/store_page_binding.dart';
import 'package:tjara/app/modules/modules_customer/store_page/views/store_page_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_jobs/bindings/tjara_jobs_binding.dart';
import 'package:tjara/app/modules/modules_customer/tjara_jobs/views/tjara_jobs_view.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/bindings/wishlist_binding.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/views/wishlist_view.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/flash_deal_detail_screen.dart';
import 'package:tjara/app/modules/modules_customer/app_home/bindings/flash_deal_binding.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      // binding: HomeBinding(),
      children: [
        GetPage(
          name: _Paths.HOME,
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
      ],
    ),

    GetPage(name: _Paths.SERVICES, page: () => const ServicesScreen()),
    GetPage(
      name: _Paths.MY_ACCOUNT,
      page: () => const MyAccountView(),
      binding: MyAccountBinding(),
    ),
    GetPage(
      name: _Paths.MY_CART,
      page: () => const MyCartView(),
      binding: MyCartBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: '/DUPLICATE_DASHBOARD',
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.ShoppingCartScreen,
      page: () => const ShoppingCartScreen(),
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),

    GetPage(
      name: _Paths.STORE_PAGE,
      page: () => const StorePageView(),
      binding: StorePageBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL_SCREEN,
      page: () => const ProductDetailScreenView(),
      binding: ProductDetailScreenBinding(),
    ),

    GetPage(
      name: _Paths.MORE,
      page: () => const MoreView(),
      binding: MoreBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATION,
      page: () => const AuthenticationView(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.ADD_AUCTION_PRODUCT_ADMIN_VIEW,
      page: () => const AuctionAddProductAdminView(),
      binding: AuctionAddProductAdminBinding(),
    ),
    GetPage(
      name: _Paths.WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS_DASHBOARD,
      page: () => const OrdersDashboardView(),
      binding: OrdersDashboardBinding(),
    ),
    GetPage(
      name: _Paths.CONTESTS,
      page: () => const ContestsView(),
      binding: ContestsBinding(),
    ),
    GetPage(
      name: _Paths.TJARA_JOBS,
      page: () => const TjaraJobsView(),
      binding: TjaraJobsBinding(),
    ),

    // admin page side  ...
    GetPage(
      name: _Paths.DASHBOARD_ADMIN,
      page: () => const DashboardAdminView(),
      binding: DashboardAdminBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_PRODUCTS,
      page: () => const ProductsAdminView(),
      binding: ProductsAdminBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_CATEGORIES_VIEW,
      page: () => const CategoriesAdminView(),
      binding: CategoriesAdminBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PRODUCT_ADMIN_VIEW,
      page: () => const AddProductAdminView(),
      binding: AddProductAdminBinding(),
    ),
    GetPage(
      name: _Paths.FLASH_DEAL_DETAIL,
      page: () => const FlashDealDetailScreen(),
      binding: FlashDealBinding(),
    ),
  ];
}
