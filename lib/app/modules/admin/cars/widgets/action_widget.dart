// ==================================================
// FILE 1: cars_table_widget.dart (action_widget.dart)
// ==================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/cars/controllers/cars_controller.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/actions_buttons.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';

class CustomIconBar extends StatelessWidget {
  final AdminProducts product;

  CustomIconBar({super.key, required this.product});

  final CarsController controller = Get.put(CarsController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Fixed width to match column allocation
      child: ProductActionButtons(
        productId: product.id ?? '',
        productName: product.name ?? 'Product Name',
        productSku: product.slug ?? 'N/A',
        isActive: product.status == 'active',
        isFeatured: product.isFeatured == 1,
        isDeal: product.isDeal == 1,
        onDuplicate: () async {
          final response = await Get.put<AddProductAdminController>(
            AddProductAdminController(),
          ).duplicateProduct(product);
          if (response == true) {
            Get.delete<AddProductAdminController>();
            controller.getCarsData();
          }
        },
        onActiveChanged: () async {
          final response = await ProductService.updateActiveStatus(
            shopId: product.shop?.shop?.id ?? '',
            productId: product.id ?? '',
            isActive: product.status == 'active',
          );

          if (response.success) {
            Get.snackbar(
              'Success',
              response.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            controller.getCarsData();
          } else {
            _showErrorMessage(response);
          }
        },
        onFeaturedChanged: () async {
          final response = await ProductService.updateFeaturedStatus(
            shopId: product.shop?.shop?.id ?? '',
            productId: product.id ?? '',
            isFeatured: product.isFeatured == 1,
          );

          if (response.success) {
            Get.snackbar(
              'Success',
              response.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            controller.getCarsData();
          } else {
            _showErrorMessage(response);
          }
        },
        onDealChanged: () async {
          final response = await ProductService.updateDealStatus(
            shopId: product.shop?.shop?.id ?? '',
            productId: product.id ?? '',
            isDeal: product.isDeal == 1,
          );

          if (response.success) {
            Get.snackbar(
              'Success',
              response.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            controller.getCarsData();
          } else {
            _showErrorMessage(response);
          }
        },
        onEdit: () {
          Get.delete<AddProductAdminController>();
          Get.offNamed(
            Routes.ADD_PRODUCT_ADMIN_VIEW,
            preventDuplicates: false,
            arguments: {'product': product, 'product_group': 'car'},
          );
        },
        onDelete: () async {
          final response = await ProductService.deleteProduct(
            shopId: product.shop?.shop?.id ?? '',
            productId: product.id ?? '',
          );

          if (response.success) {
            controller.getCarsData();
          } else {
            _showErrorMessage(response);
          }
        },
      ),
    );
  }

  void _showErrorMessage(ApiResponse response) {
    Get.snackbar(
      'Error',
      response.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}

class CarsTableWidget extends GetView<CarsController> {
  const CarsTableWidget({super.key});

  // Define consistent column widths as constants
  static const double _tableWidth = 1200.0;
  static const Map<String, double> _columnWidths = {
    'id': 80.0,
    'image': 60.0,
    'name': 200.0,
    'shop': 150.0,
    'price': 100.0,
    'sold': 80.0,
    'published': 140.0,
    'status': 100.0,
    'actions': 250.0,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _tableWidth,
      child: Column(
        children: [
          // Header
          _buildTableHeader(),
          // Body
          Obx(() {
            debugPrint(
              "Table rebuilding: products.length=${controller.products.length}, currentPage=${controller.currentPage.value}",
            );
            if (controller.products.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: List.generate(controller.products.length, (index) {
                final product = controller.products[index];
                debugPrint("Building row $index: product.id=${product.id}");
                return _buildDataRow(product, index, context);
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 56,
      width: _tableWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF97316), // Orange color from image
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildHeaderCell("ID", width: _columnWidths['id']!),
          _buildHeaderCell("Product Image", width: _columnWidths['image']!),
          _buildHeaderCell("Product Name", width: _columnWidths['name']!),
          _buildHeaderCell("Shop Name", width: _columnWidths['shop']!),
          _buildHeaderCell("Price", width: _columnWidths['price']!),
          _buildHeaderCell("Sold", width: _columnWidths['sold']!),
          _buildHeaderCell("Published", width: _columnWidths['published']!),
          _buildHeaderCell("Status", width: _columnWidths['status']!),
          _buildHeaderCell("Actions", width: _columnWidths['actions']!),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataRow(AdminProducts product, int index, BuildContext context) {
    return Container(
      width: _tableWidth,
      height: 72, // Fixed height per row
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          // ID
          SizedBox(
            width: _columnWidths['id']!,
            child: Text(
              product.meta?.productId ?? "---",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1e3c72),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Image
          SizedBox(
            width: _columnWidths['image']!,
            child: _buildProductImage(product),
          ),

          // Car Name
          SizedBox(
            width: _columnWidths['name']!,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                product.name ?? "---",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Shop
          SizedBox(
            width: _columnWidths['shop']!,
            child: Text(
              product.shop?.shop?.name ?? "---",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Price
          SizedBox(
            width: _columnWidths['price']!,
            child: Text(
              "\$${product.price ?? 0}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Sold Status
          SizedBox(
            width: _columnWidths['sold']!,
            child: Text(
              product.meta?.sold == '1' ? 'Yes' : 'No',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    product.meta?.sold == '1'
                        ? Colors.green[600]
                        : Colors.grey[600],
              ),
            ),
          ),

          // Published Date
          SizedBox(
            width: _columnWidths['published']!,
            child: Text(
              _formatDate(product.createdAt?.toString() ?? ""),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status
          SizedBox(
            width: _columnWidths['status']!,
            child: _buildStatusChip(product.status ?? ""),
          ),

          // Actions
          SizedBox(
            width: _columnWidths['actions']!,
            child: CustomIconBar(product: product),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    debugPrint(
      "Building empty state: products.length=${controller.products.length}, currentPage=${controller.currentPage.value}",
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No cars found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search filters",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          // Debug information
          Obx(
            () => Text(
              "Debug: Products: ${controller.products.length}, Total: ${controller.totalItems.value}, Pages: ${controller.totalPages.value}",
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(AdminProducts product) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            product.thumbnail?.media?.url != null
                ? CachedNetworkImage(
                  imageUrl: product.thumbnail!.media!.url!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                )
                : Icon(Icons.image, color: Colors.grey[400], size: 20),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('MMM d, y').format(dateTime);
    } catch (e) {
      return "---";
    }
  }

  // Static method to get column width for header
  static double getColumnWidth(String column) {
    return _columnWidths[column] ?? 100.0;
  }

  // Static method to get total table width
  static double getTableWidth() {
    return _tableWidth;
  }
}

// cars_pagination_widget.dart
class CarsPaginationWidget extends GetView<CarsController> {
  const CarsPaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 80, // Reduced height from 300
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Obx(() {
        debugPrint(
          "CarsPaginationWidget: totalPages=${controller.totalPages.value}, currentPage=${controller.currentPage.value}, totalItems=${controller.totalItems.value}",
        );

        if (controller.totalPages.value <= 1) {
          debugPrint("Pagination hidden: totalPages <= 1");
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            debugPrint("LayoutBuilder constraints: ${constraints.maxWidth}");
            if (constraints.maxWidth < 600) {
              debugPrint("Building mobile pagination");
              return _buildMobilePagination();
            } else {
              debugPrint("Building desktop pagination");
              return _buildDesktopPagination();
            }
          },
        );
      }),
    );
  }

  Widget _buildDesktopPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            "Showing ${controller.getDisplayRange()} of ${controller.totalItems.value} entries",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        _buildPaginationButtons(),
      ],
    );
  }

  Widget _buildMobilePagination() {
    return Column(
      children: [
        Obx(
          () => Text(
            "Showing ${controller.getDisplayRange()} of ${controller.totalItems.value} entries",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
        _buildPaginationButtons(),
      ],
    );
  }

  Widget _buildPaginationButtons() {
    return Obx(() {
      final int currentPage = controller.currentPage.value;
      final int totalPages = controller.totalPages.value;
      final int startPage = controller.calculateStartPage();
      const int visibleButtons = 5;

      debugPrint(
        "Building pagination buttons: currentPage=$currentPage, totalPages=$totalPages, startPage=$startPage, visibleButtons=$visibleButtons",
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPaginationButton(
            icon: Icons.chevron_left,
            onPressed: controller.goToPreviousPage,
            enabled: currentPage > 1,
          ),
          const SizedBox(width: 8),
          ...List.generate(visibleButtons, (index) {
            final int page = startPage + index;
            if (page > totalPages) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildPaginationButton(
                text: '$page',
                onPressed: () => controller.goToPage(page),
                isActive: page == currentPage,
              ),
            );
          }),
          const SizedBox(width: 8),
          _buildPaginationButton(
            icon: Icons.chevron_right,
            onPressed: controller.goToNextPage,
            enabled: currentPage < totalPages,
          ),
        ],
      );
    });
  }

  Widget _buildPaginationButton({
    String? text,
    IconData? icon,
    required VoidCallback onPressed,
    bool enabled = true,
    bool isActive = false,
  }) {
    debugPrint(
      "Building pagination button: text=$text, icon=${icon != null}, enabled=$enabled, isActive=$isActive",
    );

    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: isActive ? const Color(0xFFF97316) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap:
              enabled
                  ? () {
                    debugPrint(
                      "Pagination button tapped: text=$text, icon=${icon != null}",
                    );
                    onPressed();
                  }
                  : () {
                    debugPrint(
                      "Pagination button disabled: text=$text, icon=${icon != null}",
                    );
                  },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? const Color(0xffF97316) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child:
                  icon != null
                      ? Icon(
                        icon,
                        size: 18,
                        color:
                            enabled
                                ? (isActive ? Colors.white : Colors.grey[600])
                                : Colors.grey[400],
                      )
                      : Text(
                        text!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.grey[700],
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
