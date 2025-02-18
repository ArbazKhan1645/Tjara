import 'package:get/get.dart';

import '../modules/blog/bindings/blog_binding.dart';
import '../modules/blog/views/blog_view.dart';
import '../modules/categories/bindings/categories_binding.dart';
import '../modules/categories/views/categories_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/widgets/shopping_cart.dart';
import '../modules/my_account/bindings/my_account_binding.dart';
import '../modules/my_account/views/my_account_view.dart';
import '../modules/my_cart/bindings/my_cart_binding.dart';
import '../modules/my_cart/views/my_cart_view.dart';
import '../modules/product_detail_screen/bindings/product_detail_screen_binding.dart';
import '../modules/product_detail_screen/views/product_detail_screen_view.dart';
import '../modules/store_page/bindings/store_page_binding.dart';
import '../modules/store_page/views/store_page_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.DASHBOARD;

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
    GetPage(
      name: _Paths.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
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
      name: _Paths.ShoppingCartScreen,
      page: () => const ShoppingCartScreen(),
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: _Paths.BLOG,
      page: () => const BlogView(),
      binding: BlogBinding(),
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
  ];
}
