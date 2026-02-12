import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/controllers/ut.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/products_list_widget.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/products_view_widget.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

// Example controller that uses the enhanced service
class AdminProductsController extends GetxController with ErrorHandlingMixin {
  late final AdminProductsService _productsService;
  final LoadingStateManager loadingManager = LoadingStateManager();

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      loadingManager.startLoading('Initializing products...');
      _productsService = Get.find<AdminProductsService>();
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

  AdminProductsService get productsService => _productsService;

  // Example methods for UI actions
  Future<void> onRefresh() async {
    try {
      PerformanceTracker.startTracking('products_refresh');
      await _productsService.refreshProducts();
      showSuccessSnackbar('Products refreshed successfully');
      PerformanceTracker.endTracking('products_refresh');
    } catch (error, stackTrace) {
      handleError(error, context: 'Products Refresh', stackTrace: stackTrace);
    }
  }

  Future<void> onSearch(String query) async {
    try {
      PerformanceTracker.startTracking('products_search');
      _productsService.updateSearchQuery(query);
      PerformanceTracker.endTracking(
        'products_search',
        metadata: {
          'query_length': query.length,
          'has_results': _productsService.adminProducts.isNotEmpty,
        },
      );
    } catch (error, stackTrace) {
      handleError(error, context: 'Products Search', stackTrace: stackTrace);
    }
  }

  Future<void> onFilterChange(ProductStatus status) async {
    try {
      _productsService.updateStatusFilter(status);
      showInfoSnackbar('Filter applied: ${status.name}');
    } catch (error, stackTrace) {
      handleError(error, context: 'Filter Change', stackTrace: stackTrace);
    }
  }

  @override
  void onClose() {
    ProductsCacheManager.clearCache();
    super.onClose();
  }
}

// Example main page widget
class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminProductsController>(
      init: AdminProductsController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              controller.loadingManager.buildLoadingOverlay(
                child: EnhancedProductsViewWidget(
                  isAppBarExpanded: true,
                  adminProductsService: controller.productsService,
                ),
              ),
              // Floating bulk action bar - fixed at screen bottom
              Obx(() {
                if (controller.productsService.selectedProductIds.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BulkActionBar(
                    adminProductsService: controller.productsService,
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

// Example filter dialog
class ProductFiltersDialog extends StatelessWidget {
  final AdminProductsService service;

  const ProductFiltersDialog({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    _buildFilterSection(
                      title: 'Product Status',
                      child: Obx(
                        () => Wrap(
                          spacing: 8,
                          children:
                              ProductStatus.values.map((status) {
                                final isSelected =
                                    service.selectedStatus.value == status;
                                return FilterChip(
                                  label: Text(status.name.toUpperCase()),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    service.updateStatusFilter(status);
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Filters
                    _buildFilterSection(
                      title: 'Quick Filters',
                      child: Obx(
                        () => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              service.getPredefinedFilters().map((filter) {
                                final isActive = service.activeFilters.any(
                                  (f) => f.column == filter.column,
                                );
                                return FilterChip(
                                  label: Text(filter.name),
                                  selected: isActive,
                                  onSelected: (selected) {
                                    if (selected) {
                                      service.addColumnFilter(filter);
                                    } else {
                                      service.removeColumnFilter(filter.column);
                                    }
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Date Range
                    _buildFilterSection(
                      title: 'Date Range',
                      child: Obx(
                        () => Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateButton(
                                    label: 'Start Date',
                                    date: service.startDate.value,
                                    onTap: () => _selectStartDate(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDateButton(
                                    label: 'End Date',
                                    date: service.endDate.value,
                                    onTap: () => _selectEndDate(context),
                                  ),
                                ),
                              ],
                            ),
                            if (service.startDate.value != null ||
                                service.endDate.value != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton.icon(
                                  onPressed:
                                      () => service.updateDateRange(null, null),
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text('Clear Date Range'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      service.clearAllFilters();
                      Get.back();
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              date != null ? date.formattedDate : label,
              style: TextStyle(
                color: date != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: service.startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );
    if (picked != null) {
      service.updateDateRange(picked, service.endDate.value);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: service.endDate.value ?? DateTime.now(),
      firstDate: service.startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
    );
    if (picked != null) {
      service.updateDateRange(service.startDate.value, picked);
    }
  }
}

// Example usage in routes
class AppPages {
  static final routes = [
    GetPage(
      name: '/admin/products',
      page: () => const AdminProductsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdminProductsController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

// Example of how to open the filter dialog
void showProductFiltersDialog(AdminProductsService service) {
  Get.dialog(ProductFiltersDialog(service: service), barrierDismissible: true);
}
