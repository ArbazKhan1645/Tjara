import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'app/core/locators/service_locator.dart';
import 'app/core/utils/helpers/logger.dart';
import 'app/core/widgets/global_errorwidget.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(details.toString());
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Async error: $error');
    return true;
  };
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return GlobalErrorWidget(errorDetails: errorDetails);
  };
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  initDependencies();
  AppLogger.info('initialized');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TJARA',
      builder: (context, widget) {
        return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!);
      },
      // theme: lightThemeData(context),
      themeMode: ThemeMode.light,
      useInheritedMediaQuery: true,
      defaultTransition: Transition.fadeIn,
      opaqueRoute: Get.isOpaqueRouteDefault,
      popGesture: Get.isPopGestureEnable,
      enableLog: false,
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      transitionDuration: const Duration(milliseconds: 200),
      initialRoute: AppPages.INITIAL,
      navigatorObservers: [GetObserver()],
      getPages: AppPages.routes,
    );
  }
}




Future<void> fetchAllProducts() async {
  isLoading.value = true;

  Map<String, dynamic> apiParams = {
    "with": "thumbnail,shop",
    "filterJoin": "OR",
    "search": search,
    "orderBy": orderBy,
    "order": order,
    "page": currentPage,
    "per_page": 20,
  };

  List<Map<String, dynamic>> columns = [];
  List<Map<String, dynamic>> attributes = [];

  if (minPriceFilter != null) {
    columns.add({"column": "price", "value": minPriceFilter, "operator": ">"});
  }
  if (maxPriceFilter != null) {
    columns.add({"column": "price", "value": maxPriceFilter, "operator": "<"});
  }
  if (currentShopId != null) {
    columns.add({"column": "shop_id", "value": currentShopId, "operator": "="});
  }
  columns.add({"column": "status", "value": "active", "operator": "="});

  if (columns.isNotEmpty) {
    apiParams["filterByColumns"] = {"filterJoin": "AND", "columns": columns};
  }

  if (categoryFilter != null) {
    attributes.add({"key": "categories", "value": categoryFilter, "operator": "="});
  }
  if (brandFilter != null) {
    attributes.add({"key": "brands", "value": brandFilter, "operator": "="});
  }
  if (modelFilter != null) {
    attributes.add({"key": "models", "value": modelFilter, "operator": "="});
  }
  if (yearFilter != null) {
    attributes.add({"key": "years", "value": yearFilter, "operator": "="});
  }

  if (attributes.isNotEmpty) {
    apiParams["filterByAttributes"] = {"filterJoin": "AND", "attributes": attributes};
  }

  try {
    Response response = await Dio().get(
      "https://yourapi.com/products",
      queryParameters: apiParams,
    );

    if (response.statusCode == 200) {
      var data = response.data["products"];
      if (windowsWidth > 550 || currentPage <= 1) {
        productData.value = data;
      } else {
        productData.value = {...productData.value, "data": [...productData.value["data"], ...data["data"]]};
      }
      localStorage.setString("store-products-name", id);
      localStorage.setString("store-products", jsonEncode(productData.value));
    }
  } catch (e) {
    debugPrint("Error fetching products: $e");
    productData.value = [];
  } finally {
    Future.delayed(Duration(seconds: 1), () => isLoading.value = false);
  }
}
