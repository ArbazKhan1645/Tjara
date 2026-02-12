import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/popups/popups.dart';
import 'package:tjara/app/services/dashbopard_services/adminJobs_service.dart';
import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';
import 'package:tjara/app/services/dashbopard_services/admin_dashboard_service.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';
import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';
import 'package:tjara/app/services/dashbopard_services/services_service.dart';
import 'package:tjara/app/services/dashbopard_services/shops_service.dart';
import 'package:tjara/app/services/dashbopard_services/stories_service.dart';
import 'package:tjara/app/services/dashbopard_services/users_service.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/services/chat_messages/chat_messages_service.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';
import 'package:tjara/app/services/others/others_service.dart';
import 'package:tjara/app/services/placed_orders_service.dart';
import 'package:tjara/app/services/websettings_service/websetting_service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

Future<void> initDependencies() async {
  await _initAppService();
  await _initSetupServices();
}

Future<void> _initAppService() async {
  try {
    await Get.putAsync(() => AuthService().init(), permanent: true);
  } catch (e, stackTrace) {
    Get.log('Error initializing AuthService: $e\n$stackTrace', isError: true);
  }
}

Future<void> _initSetupServices() async {
  try {
    await Get.putAsync(() => AdminDashboardService().init(), permanent: true);
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminDashboardService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => CartService().init());
  } catch (e, stackTrace) {
    Get.log('Error initializing CartService: $e\n$stackTrace', isError: true);
  }

  try {
    await Get.putAsync(() => WishlistServiceController().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing WishlistService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => CountryService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing CountryService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => NotificationService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing NotificationService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => OrderService().init());
  } catch (e, stackTrace) {
    Get.log('Error initializing OrderService: $e\n$stackTrace', isError: true);
  }

  try {
    await Get.putAsync(() => PlacedOrderService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing PlacedOrderService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => AdminJobsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminJobsService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => ContestsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing ContestsService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => ServicesService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing ServicesService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => StoriesService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing StoriesService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => AdminShopsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminShopsService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => AdminCarsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminCarsService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => AdminDisputesService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminDisputesService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => AdminUsersService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminUsersService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => ApiService().init());
  } catch (e, stackTrace) {
    Get.log('Error initializing ApiService: $e\n$stackTrace', isError: true);
  }

  try {
    await Get.putAsync(() => AdminAuctionService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminAuctionService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => WebsiteOptionsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing WebsiteOptionsService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    final con = Get.put(HomeController(), permanent: true);
    await con.oninits();
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing HomeController: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => ProductChatsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing ProductChatsService: $e\n$stackTrace',
      isError: true,
    );
  }

  try {
    await Get.putAsync(() => AdminProductsService().init());
  } catch (e, stackTrace) {
    Get.log(
      'Error initializing AdminProductsService: $e\n$stackTrace',
      isError: true,
    );
  }
}
