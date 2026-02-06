import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/controllers/cars_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/cars_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/actions_buttons.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';

/// Cars Table Widget - Displays car listings in an elegant table format
class CarsTableWidget extends GetView<CarsController> {
  const CarsTableWidget({super.key});

  static const double _tableWidth = 1250.0;
  static const Map<String, double> _columnWidths = {
    'id': 100,
    'image': 80,
    'name': 180,
    'shop': 150,
    'price': 100,
    'sold': 80,
    'published': 140,
    'status': 100,
    'actions': 280,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _tableWidth,
      child: Column(
        children: [
          const _CarsTableHeader(columnWidths: _columnWidths),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          Obx(() {
            if (controller.products.isEmpty) {
              return const _CarsEmptyTableState();
            }
            return Column(
              children: controller.products.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: CarsAdminTheme.spacingXs),
                  child: _CarsDataRow(
                    product: entry.value,
                    index: entry.key,
                    columnWidths: _columnWidths,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  static double getColumnWidth(String column) => _columnWidths[column] ?? 100.0;
  static double getTableWidth() => _tableWidth;
}

/// Table Header Widget
class _CarsTableHeader extends StatelessWidget {
  final Map<String, double> columnWidths;

  const _CarsTableHeader({required this.columnWidths});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: CarsAdminTheme.tableHeaderDecoration,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      child: Row(
        children: [
          _HeaderCell(title: 'ID', width: columnWidths['id']!),
          _HeaderCell(title: 'Image', width: columnWidths['image']!),
          _HeaderCell(title: 'Car Name', width: columnWidths['name']!),
          _HeaderCell(title: 'Shop', width: columnWidths['shop']!),
          _HeaderCell(title: 'Price', width: columnWidths['price']!),
          _HeaderCell(title: 'Sold', width: columnWidths['sold']!),
          _HeaderCell(title: 'Published', width: columnWidths['published']!),
          _HeaderCell(title: 'Status', width: columnWidths['status']!),
          _HeaderCell(title: 'Actions', width: columnWidths['actions']!),
        ],
      ),
    );
  }
}

/// Header Cell Widget
class _HeaderCell extends StatelessWidget {
  final String title;
  final double width;

  const _HeaderCell({required this.title, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        title.toUpperCase(),
        style: CarsAdminTheme.labelMedium.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: CarsAdminTheme.textOnPrimary,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Data Row Widget
class _CarsDataRow extends StatelessWidget {
  final AdminProducts product;
  final int index;
  final Map<String, double> columnWidths;

  const _CarsDataRow({
    required this.product,
    required this.index,
    required this.columnWidths,
  });

  // Safe getters
  String get _productId => product.meta?.productId ?? '---';
  String get _productName => product.name ?? 'Unknown Car';
  String get _shopName => product.shop?.shop?.name ?? '---';
  String get _price => '\$${product.price ?? 0}';
  bool get _isSold => product.meta?.sold == '1';
  String get _status => product.status ?? 'unknown';
  String? get _thumbnailUrl => product.thumbnail?.media?.url;
  String get _createdAt => product.createdAt?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? CarsAdminTheme.surface : CarsAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        border: Border.all(color: CarsAdminTheme.borderLight),
      ),
      child: Row(
        children: [
          // ID
          _DataCell(
            width: columnWidths['id']!,
            child: Text(
              _productId,
              style: CarsAdminTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: CarsAdminTheme.accent,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Image
          _DataCell(
            width: columnWidths['image']!,
            child: _CarImage(thumbnailUrl: _thumbnailUrl),
          ),
          // Car Name
          _DataCell(
            width: columnWidths['name']!,
            child: Text(
              _productName,
              style: CarsAdminTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Shop
          _DataCell(
            width: columnWidths['shop']!,
            child: Text(
              _shopName,
              style: CarsAdminTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Price
          _DataCell(
            width: columnWidths['price']!,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarsAdminTheme.spacingSm,
                vertical: CarsAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: CarsAdminTheme.secondaryLight,
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
              ),
              child: Text(
                _price,
                style: CarsAdminTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CarsAdminTheme.secondary,
                ),
              ),
            ),
          ),
          // Sold
          _DataCell(
            width: columnWidths['sold']!,
            child: _SoldBadge(isSold: _isSold),
          ),
          // Published
          _DataCell(
            width: columnWidths['published']!,
            child: _DateBadge(dateString: _createdAt),
          ),
          // Status
          _DataCell(
            width: columnWidths['status']!,
            child: _StatusBadge(status: _status),
          ),
          // Actions
          _DataCell(
            width: columnWidths['actions']!,
            child: _CarActionButtons(product: product),
          ),
        ],
      ),
    );
  }
}

/// Data Cell Wrapper
class _DataCell extends StatelessWidget {
  final double width;
  final Widget child;

  const _DataCell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Center(child: child),
    );
  }
}

/// Car Image Widget
class _CarImage extends StatelessWidget {
  final String? thumbnailUrl;

  const _CarImage({this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        color: CarsAdminTheme.surfaceSecondary,
        border: Border.all(color: CarsAdminTheme.border),
        boxShadow: CarsAdminTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm - 1),
        child: thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildErrorWidget(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: CarsAdminTheme.surfaceSecondary,
      child: const Icon(
        Icons.directions_car_outlined,
        color: CarsAdminTheme.textTertiary,
        size: 24,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: CarsAdminTheme.errorLight,
      child: const Icon(
        Icons.broken_image_outlined,
        color: CarsAdminTheme.error,
        size: 20,
      ),
    );
  }
}

/// Sold Badge Widget
class _SoldBadge extends StatelessWidget {
  final bool isSold;

  const _SoldBadge({required this.isSold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarsAdminTheme.spacingSm,
        vertical: CarsAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isSold ? CarsAdminTheme.successLight : CarsAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        border: Border.all(
          color: isSold ? CarsAdminTheme.success : CarsAdminTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSold ? Icons.check_circle : Icons.remove_circle_outline,
            size: 14,
            color: isSold ? CarsAdminTheme.success : CarsAdminTheme.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            isSold ? 'Yes' : 'No',
            style: CarsAdminTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isSold ? CarsAdminTheme.success : CarsAdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Date Badge Widget
class _DateBadge extends StatelessWidget {
  final String dateString;

  const _DateBadge({required this.dateString});

  String _formatDate() {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, y').format(dateTime);
    } catch (e) {
      return '---';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarsAdminTheme.spacingSm,
        vertical: CarsAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: CarsAdminTheme.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(),
            style: CarsAdminTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'active':
        return CarsAdminTheme.successLight;
      case 'inactive':
        return CarsAdminTheme.warningLight;
      case 'pending':
        return CarsAdminTheme.infoLight;
      default:
        return CarsAdminTheme.surfaceSecondary;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'active':
        return CarsAdminTheme.success;
      case 'inactive':
        return CarsAdminTheme.warning;
      case 'pending':
        return CarsAdminTheme.info;
      default:
        return CarsAdminTheme.textSecondary;
    }
  }

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.pause_circle;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarsAdminTheme.spacingSm,
        vertical: CarsAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _textColor),
          const SizedBox(width: 4),
          Text(
            status.capitalizeFirst ?? status,
            style: CarsAdminTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Car Action Buttons Widget
class _CarActionButtons extends StatelessWidget {
  final AdminProducts product;

  const _CarActionButtons({required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarsController>();

    return SizedBox(
      width: 260,
      child: ProductActionButtons(
        productId: product.id ?? '',
        productName: product.name ?? 'Car',
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
            _showSuccessMessage(response.message);
            controller.getCarsData();
          } else {
            _showErrorMessage(response.message);
          }
        },
        onFeaturedChanged: () async {
          final response = await ProductService.updateFeaturedStatus(
            shopId: product.shop?.shop?.id ?? '',
            productId: product.id ?? '',
            isFeatured: product.isFeatured == 1,
          );

          if (response.success) {
            _showSuccessMessage(response.message);
            controller.getCarsData();
          } else {
            _showErrorMessage(response.message);
          }
        },
        onDealChanged: () async {
          final response = await ProductService.updateDealStatus(
            shopId: product.shop?.shop?.id ?? '',
            productId: product.id ?? '',
            isDeal: product.isDeal == 1,
          );

          if (response.success) {
            _showSuccessMessage(response.message);
            controller.getCarsData();
          } else {
            _showErrorMessage(response.message);
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
            _showSuccessMessage('Car deleted successfully');
            controller.getCarsData();
          } else {
            _showErrorMessage(response.message);
          }
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CarsAdminTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(CarsAdminTheme.spacingLg),
      borderRadius: CarsAdminTheme.radiusMd,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CarsAdminTheme.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(CarsAdminTheme.spacingLg),
      borderRadius: CarsAdminTheme.radiusMd,
    );
  }
}

/// Empty Table State Widget
class _CarsEmptyTableState extends StatelessWidget {
  const _CarsEmptyTableState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CarsAdminTheme.spacing2Xl),
      decoration: CarsAdminTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
            decoration: const BoxDecoration(
              color: CarsAdminTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: CarsAdminTheme.primary,
            ),
          ),
          const SizedBox(height: CarsAdminTheme.spacingXl),
          const Text(
            'No Cars Found',
            style: CarsAdminTheme.headingMedium,
          ),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          Text(
            'Try adjusting your search filters or add a new car',
            textAlign: TextAlign.center,
            style: CarsAdminTheme.bodyMedium.copyWith(
              color: CarsAdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cars Pagination Widget
class CarsPaginationWidget extends GetView<CarsController> {
  const CarsPaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: CarsAdminTheme.spacingLg),
        padding: const EdgeInsets.all(CarsAdminTheme.spacingLg),
        decoration: CarsAdminTheme.cardDecoration,
        child: Column(
          children: [
            // Pagination info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarsAdminTheme.spacingMd,
                vertical: CarsAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: CarsAdminTheme.primaryLight,
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
              ),
              child: Text(
                'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                style: CarsAdminTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CarsAdminTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: CarsAdminTheme.spacingMd),

            // Showing entries text
            Text(
              'Showing ${controller.getDisplayRange()} of ${controller.totalItems.value} entries',
              style: CarsAdminTheme.bodySmall,
            ),
            const SizedBox(height: CarsAdminTheme.spacingMd),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                _PaginationNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: controller.currentPage.value > 1
                      ? controller.goToPreviousPage
                      : null,
                  tooltip: 'Previous Page',
                ),
                const SizedBox(width: CarsAdminTheme.spacingSm),

                // Page numbers
                ..._buildPageNumbers(),

                const SizedBox(width: CarsAdminTheme.spacingSm),

                // Next button
                _PaginationNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: controller.currentPage.value < controller.totalPages.value
                      ? controller.goToNextPage
                      : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),

            // Jump to page for many pages
            if (controller.totalPages.value > 10)
              Padding(
                padding: const EdgeInsets.only(top: CarsAdminTheme.spacingMd),
                child: _JumpToPageWidget(controller: controller),
              ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPageNumbers() {
    final int currentPage = controller.currentPage.value;
    final int totalPages = controller.totalPages.value;
    final int startPage = controller.calculateStartPage();
    const int visibleButtons = 5;

    return List.generate(visibleButtons, (index) {
      final int page = startPage + index;
      if (page > totalPages) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingXs),
        child: _PageNumberButton(
          page: page,
          isCurrentPage: page == currentPage,
          onTap: () => controller.goToPage(page),
        ),
      );
    });
  }
}

/// Pagination Navigation Button
class _PaginationNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _PaginationNavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isEnabled
                  ? CarsAdminTheme.surfaceSecondary
                  : CarsAdminTheme.surfaceSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
              border: Border.all(
                color: isEnabled
                    ? CarsAdminTheme.border
                    : CarsAdminTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? CarsAdminTheme.textPrimary
                  : CarsAdminTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Page Number Button
class _PageNumberButton extends StatelessWidget {
  final int page;
  final bool isCurrentPage;
  final VoidCallback onTap;

  const _PageNumberButton({
    required this.page,
    required this.isCurrentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrentPage
                ? CarsAdminTheme.primary
                : CarsAdminTheme.surface,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
            border: Border.all(
              color: isCurrentPage
                  ? CarsAdminTheme.primary
                  : CarsAdminTheme.border,
            ),
            boxShadow: isCurrentPage ? CarsAdminTheme.shadowColored(CarsAdminTheme.primary) : null,
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w500,
                color: isCurrentPage
                    ? CarsAdminTheme.textOnPrimary
                    : CarsAdminTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Jump to Page Widget
class _JumpToPageWidget extends StatelessWidget {
  final CarsController controller;

  const _JumpToPageWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Go to page:',
          style: CarsAdminTheme.bodySmall.copyWith(
            color: CarsAdminTheme.textSecondary,
          ),
        ),
        const SizedBox(width: CarsAdminTheme.spacingSm),
        SizedBox(
          width: 64,
          height: 36,
          child: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: CarsAdminTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: CarsAdminTheme.spacingSm,
                vertical: CarsAdminTheme.spacingXs,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
                borderSide: const BorderSide(color: CarsAdminTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
                borderSide: const BorderSide(color: CarsAdminTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
                borderSide: const BorderSide(color: CarsAdminTheme.primary),
              ),
            ),
            onSubmitted: (value) => _handleJump(textController),
          ),
        ),
        const SizedBox(width: CarsAdminTheme.spacingXs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleJump(textController),
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(CarsAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: CarsAdminTheme.primary,
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: CarsAdminTheme.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleJump(TextEditingController textController) {
    final page = int.tryParse(textController.text) ?? 0;
    if (page >= 1 && page <= controller.totalPages.value) {
      controller.goToPage(page);
      textController.clear();
    }
  }
}

/// Legacy CustomIconBar - kept for backward compatibility
@Deprecated('Use _CarActionButtons instead')
class CustomIconBar extends StatelessWidget {
  final AdminProducts product;

  const CustomIconBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return _CarActionButtons(product: product);
  }
}
