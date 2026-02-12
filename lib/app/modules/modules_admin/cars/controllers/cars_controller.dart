import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/cars/widgets/car_products_list_widget.dart';
import 'package:tjara/app/modules/modules_admin/cars/widgets/car_products_view_widget.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/controllers/ut.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class CarsController extends GetxController {
  late final AdminCarsService _productsService;
  final LoadingStateManager loadingManager = LoadingStateManager();

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      loadingManager.startLoading('Initializing cars...');
      _productsService = Get.find<AdminCarsService>();
      loadingManager.stopLoading();
    } catch (error, stackTrace) {
      loadingManager.stopLoading();
      handleError(
        error,
        context: 'Service Initialization',
        stackTrace: stackTrace,
      );
    }
  }

  String _getUserFriendlyMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid data format received from server.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  void handleError(dynamic error, {String? context, StackTrace? stackTrace}) {
    final String userMessage = _getUserFriendlyMessage(error);
    _showErrorSnackbar(userMessage);
  }

  AdminCarsService get carsService => _productsService;

  Future<void> onRefresh() async {
    try {
      PerformanceTracker.startTracking('cars_refresh');
      await _productsService.refreshProducts();
      showSuccessSnackbar('Cars refreshed successfully');
      PerformanceTracker.endTracking('cars_refresh');
    } catch (error, stackTrace) {
      handleError(error, context: 'Cars Refresh', stackTrace: stackTrace);
    }
  }

  void showSuccessSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  Future<void> onSearch(String query) async {
    try {
      PerformanceTracker.startTracking('cars_search');
      _productsService.updateSearchQuery(query);
      PerformanceTracker.endTracking(
        'cars_search',
        metadata: {
          'query_length': query.length,
          'has_results': _productsService.adminProducts.isNotEmpty,
        },
      );
    } catch (error, stackTrace) {
      handleError(error, context: 'Cars Search', stackTrace: stackTrace);
    }
  }

  Future<void> onFilterChange(CarProductStatus status) async {
    try {
      _productsService.updateStatusFilter(status);
      showInfoSnackbar('Filter applied: ${status.name}');
    } catch (error, stackTrace) {
      handleError(error, context: 'Filter Change', stackTrace: stackTrace);
    }
  }

  void showInfoSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  @override
  void onClose() {
    ProductsCacheManager.clearCache();
    super.onClose();
  }
}

// Main page widget
class AdminCarsPage extends StatelessWidget {
  const AdminCarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarsController>(
      init: CarsController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              controller.loadingManager.buildLoadingOverlay(
                child: EnhancedCarsViewWidget(
                  isAppBarExpanded: true,
                  adminCarsService: controller.carsService,
                ),
              ),
              // Floating bulk action bar - fixed at screen bottom
              Obx(() {
                if (controller.carsService.selectedProductIds.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CarsBulkActionBar(
                    adminCarsService: controller.carsService,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
