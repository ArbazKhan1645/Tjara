import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/cars/widgets/car_order_item_widget.dart';
import 'package:tjara/app/modules/modules_admin/cars/widgets/cars_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/service.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/shimmer.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class AdminCarsList extends StatelessWidget {
  final AdminCarsService adminCarsService;

  const AdminCarsList({super.key, required this.adminCarsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.only(
          bottom: adminCarsService.selectedProductIds.isNotEmpty ? 140 : 80,
        ),
        child: Column(
          children: [
            _buildContent(context),
            if (!adminCarsService.isLoading.value &&
                adminCarsService.adminProducts.isNotEmpty)
              _buildPagination(),
            if (adminCarsService.isPaginationLoading.value)
              _buildLoadMoreIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    // Initial loading state (check both isLoading and isRefreshing)
    if ((adminCarsService.isLoading.value ||
            adminCarsService.isRefreshing.value) &&
        adminCarsService.adminProducts.isEmpty) {
      return const ProductsShimmerList(itemCount: 8);
    }

    // Empty state (only when not loading AND not refreshing)
    if (!adminCarsService.isLoading.value &&
        !adminCarsService.isRefreshing.value &&
        adminCarsService.adminProducts.isEmpty) {
      return _buildEmptyState();
    }

    // Cars list with smooth horizontal scrolling
    return RefreshIndicator(
      onRefresh: adminCarsService.refreshProducts,
      color: CarsAdminTheme.accent,
      backgroundColor: CarsAdminTheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(),
                  const SizedBox(height: CarsAdminTheme.spacingSm),
                  ...adminCarsService.adminProducts.map((product) {
                    final productId = product.id ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: CarsAdminTheme.spacingSm,
                      ),
                      child: Obx(
                        () => CarOrderItemCard(
                          product: product,
                          isSelected: adminCarsService.selectedProductIds
                              .contains(productId),
                          onSelectionChanged: (selected) {
                            adminCarsService.toggleProductSelection(productId);
                          },
                        ),
                      ),
                    );
                  }),
                  if (adminCarsService.isPaginationLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(CarsAdminTheme.spacingLg),
                      child: ProductShimmerCard(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: CarsAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CarsAdminTheme.spacingLg,
        ),
        child: Row(
          children: [
            // Select all checkbox
            SizedBox(
              width: 40,
              child: Obx(
                () => Checkbox(
                  value: adminCarsService.isAllSelected,
                  onChanged: (_) => adminCarsService.toggleSelectAll(),
                  activeColor: CarsAdminTheme.accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  tristate: false,
                ),
              ),
            ),
            _buildHeaderCell('Product ID', 100),
            _buildHeaderCell('Image', 80),
            _buildHeaderCell('Product Name', 180),
            _buildHeaderCell('Shop', 150),
            _buildHeaderCell('Price', 100),
            _buildHeaderCell('Sold', 135),
            _buildHeaderCell('Stock', 80),
            _buildHeaderCell('Published', 120),
            _buildHeaderCell('Status', 100),
            _buildHeaderCell('Analytics', 200),
            _buildHeaderCell('Actions', 200),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingSm),
      child: Text(
        title.toUpperCase(),
        style: CarsAdminTheme.labelMedium.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: CarsAdminTheme.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(CarsAdminTheme.spacing2Xl),
      decoration: CarsAdminTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
            decoration: const BoxDecoration(
              color: CarsAdminTheme.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: CarsAdminTheme.accent,
            ),
          ),
          const SizedBox(height: CarsAdminTheme.spacingXl),
          const Text('No Cars Found', style: CarsAdminTheme.headingMedium),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: CarsAdminTheme.bodyMedium,
          ),
          const SizedBox(height: CarsAdminTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => adminCarsService.clearAllFilters(),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear Filters'),
                style: CarsAdminTheme.outlineButtonStyle,
              ),
              const SizedBox(width: CarsAdminTheme.spacingMd),
              ElevatedButton.icon(
                onPressed: () => adminCarsService.refreshProducts(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: CarsAdminTheme.primaryButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    final searchQuery = adminCarsService.searchQuery.value;
    if (searchQuery.isNotEmpty) {
      return 'No cars found matching "$searchQuery".\nTry adjusting your search terms or filters.';
    }

    final selectedStatus = adminCarsService.selectedStatus.value;
    final activeFilters = adminCarsService.activeFilters;
    final startDate = adminCarsService.startDate.value;

    if (selectedStatus != CarProductStatus.all ||
        activeFilters.isNotEmpty ||
        startDate != null) {
      return 'No cars found with the current filters applied.\nTry removing some filters to see more results.';
    }

    return 'No cars have been added yet.\nClick "Add New Car" to get started.';
  }

  Widget _buildPagination() {
    return Obx(() {
      final totalPages = adminCarsService.totalPages.value;
      if (totalPages <= 1) {
        return const SizedBox.shrink();
      }

      final currentPage = adminCarsService.currentPage.value;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: CarsAdminTheme.spacingLg),
        padding: const EdgeInsets.all(CarsAdminTheme.spacingLg),
        decoration: CarsAdminTheme.cardDecoration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarsAdminTheme.spacingMd,
                vertical: CarsAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: CarsAdminTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
              ),
              child: Text(
                'Page $currentPage of $totalPages',
                style: CarsAdminTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: CarsAdminTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaginationButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed:
                      currentPage > 1 ? adminCarsService.previousPage : null,
                  tooltip: 'Previous Page',
                ),
                const SizedBox(width: CarsAdminTheme.spacingSm),
                ...adminCarsService.visiblePageNumbers().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildPageNumberButton(page, currentPage),
                  ),
                ),
                const SizedBox(width: CarsAdminTheme.spacingSm),
                _buildPaginationButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed:
                      currentPage < totalPages
                          ? adminCarsService.nextPage
                          : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),
            if (totalPages > 10)
              Padding(
                padding: const EdgeInsets.only(top: CarsAdminTheme.spacingMd),
                child: _buildJumpToPage(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(CarsAdminTheme.spacingSm),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? CarsAdminTheme.surfaceSecondary
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
              border: Border.all(
                color:
                    isEnabled
                        ? CarsAdminTheme.border
                        : CarsAdminTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  isEnabled
                      ? CarsAdminTheme.textPrimary
                      : CarsAdminTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(int page, int currentPage) {
    final isCurrentPage = page == currentPage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => adminCarsService.goToPage(page),
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isCurrentPage ? CarsAdminTheme.accent : CarsAdminTheme.surface,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
            border: Border.all(
              color:
                  isCurrentPage ? CarsAdminTheme.accent : CarsAdminTheme.border,
            ),
            boxShadow: isCurrentPage ? CarsAdminTheme.shadowSm : null,
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w400,
              color:
                  isCurrentPage
                      ? CarsAdminTheme.textOnPrimary
                      : CarsAdminTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJumpToPage() {
    final TextEditingController controller = TextEditingController();
    final totalPages = adminCarsService.totalPages.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Go to page:', style: CarsAdminTheme.bodySmall),
        const SizedBox(width: CarsAdminTheme.spacingSm),
        SizedBox(
          width: 64,
          height: 36,
          child: TextField(
            controller: controller,
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
                borderSide: const BorderSide(color: CarsAdminTheme.accent),
              ),
            ),
            onSubmitted: (value) {
              final page = int.tryParse(value) ?? 0;
              if (page >= 1 && page <= totalPages) {
                adminCarsService.goToPage(page);
                controller.clear();
              }
            },
          ),
        ),
        const SizedBox(width: CarsAdminTheme.spacingXs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final page = int.tryParse(controller.text) ?? 0;
              if (page >= 1 && page <= totalPages) {
                adminCarsService.goToPage(page);
                controller.clear();
              }
            },
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(CarsAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: CarsAdminTheme.accent,
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

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(CarsAdminTheme.spacingLg),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: CarsAdminTheme.accent,
            ),
          ),
          SizedBox(width: CarsAdminTheme.spacingMd),
          Text('Loading more cars...', style: CarsAdminTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Floating bulk action bar for cars admin - use at Scaffold level for true floating effect
class CarsBulkActionBar extends StatelessWidget {
  final AdminCarsService adminCarsService;

  const CarsBulkActionBar({super.key, required this.adminCarsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCount = adminCarsService.selectedProductIds.length;
      final isRunning = adminCarsService.isBulkOperationRunning.value;
      final progress = adminCarsService.bulkOperationProgress.value;
      final total = adminCarsService.bulkOperationTotal.value;

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D4F4F),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child:
              isRunning
                  ? _buildProgressRow(progress, total)
                  : _buildActionsContent(context, selectedCount),
        ),
      );
    });
  }

  Widget _buildProgressRow(int progress, int total) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Processing $progress of $total...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? progress / total : 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: CarsAdminTheme.success,
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsContent(BuildContext context, int selectedCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: selected count + clear
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: CarsAdminTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$selectedCount selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: adminCarsService.clearSelection,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 16, color: Colors.white70),
                      SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Action buttons in Wrap - all visible, no scroll needed
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildActionChip(
              context: context,
              icon: Icons.visibility_rounded,
              label: 'Activate',
              color: CarsAdminTheme.success,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Activate Cars',
                    message: 'Make $selectedCount selected cars active?',
                    confirmLabel: 'Activate All',
                    confirmColor: CarsAdminTheme.success,
                    icon: Icons.visibility_rounded,
                    onConfirm: () => _executeBulkActive(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.visibility_off_rounded,
              label: 'Deactivate',
              color: CarsAdminTheme.warning,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Deactivate Cars',
                    message: 'Make $selectedCount selected cars inactive?',
                    confirmLabel: 'Deactivate All',
                    confirmColor: CarsAdminTheme.warning,
                    icon: Icons.visibility_off_rounded,
                    onConfirm: () => _executeBulkActive(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.star_rounded,
              label: 'Feature',
              color: CarsAdminTheme.warning,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Feature Cars',
                    message: 'Make $selectedCount selected cars featured?',
                    confirmLabel: 'Feature All',
                    confirmColor: CarsAdminTheme.warning,
                    icon: Icons.star_rounded,
                    onConfirm: () => _executeBulkFeatured(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.star_outline_rounded,
              label: 'Unfeature',
              color: const Color(0xFF94A3B8),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Unfeature Cars',
                    message:
                        'Remove $selectedCount selected cars from featured?',
                    confirmLabel: 'Unfeature All',
                    confirmColor: CarsAdminTheme.warning,
                    icon: Icons.star_outline_rounded,
                    onConfirm: () => _executeBulkFeatured(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.sell_rounded,
              label: 'Mark Sold',
              color: const Color(0xFFD97706),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Mark Cars as Sold',
                    message: 'Mark $selectedCount selected cars as sold?',
                    confirmLabel: 'Mark Sold',
                    confirmColor: const Color(0xFFD97706),
                    icon: Icons.sell_rounded,
                    onConfirm: () => _executeBulkSold(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.sell_outlined,
              label: 'Mark Unsold',
              color: const Color(0xFF94A3B8),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Mark Cars as Unsold',
                    message: 'Mark $selectedCount selected cars as unsold?',
                    confirmLabel: 'Mark Unsold',
                    confirmColor: const Color(0xFF94A3B8),
                    icon: Icons.sell_outlined,
                    onConfirm: () => _executeBulkSold(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.local_offer_rounded,
              label: 'Add Deal',
              color: const Color(0xFFEC4899),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Add to Deals',
                    message: 'Add $selectedCount selected cars to deals?',
                    confirmLabel: 'Add to Deals',
                    confirmColor: const Color(0xFFEC4899),
                    icon: Icons.local_offer_rounded,
                    onConfirm: () => _executeBulkDeal(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.local_offer_outlined,
              label: 'Remove Deal',
              color: const Color(0xFF94A3B8),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Remove from Deals',
                    message: 'Remove $selectedCount selected cars from deals?',
                    confirmLabel: 'Remove from Deals',
                    confirmColor: CarsAdminTheme.warning,
                    icon: Icons.local_offer_outlined,
                    onConfirm: () => _executeBulkDeal(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.inventory_2_rounded,
              label: 'Assign Inventory',
              color: const Color(0xFF8B5CF6),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Assign Inventory',
                    message:
                        'Mark $selectedCount selected cars as inventory assigned?',
                    confirmLabel: 'Assign All',
                    confirmColor: const Color(0xFF8B5CF6),
                    icon: Icons.inventory_2_rounded,
                    onConfirm: () => _executeBulkInventory(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.inventory_2_outlined,
              label: 'Unassign Inventory',
              color: const Color(0xFF94A3B8),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Unassign Inventory',
                    message:
                        'Unassign inventory from $selectedCount selected cars?',
                    confirmLabel: 'Unassign All',
                    confirmColor: CarsAdminTheme.warning,
                    icon: Icons.inventory_2_outlined,
                    onConfirm: () => _executeBulkInventory(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.push_pin_rounded,
              label: 'Pin Sale',
              color: const Color(0xFFEC4899),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Pin Sale',
                    message: 'Pin $selectedCount selected cars to sale?',
                    confirmLabel: 'Pin All',
                    confirmColor: const Color(0xFFEC4899),
                    icon: Icons.push_pin_rounded,
                    onConfirm: () => _executeBulkPinSale(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.push_pin_outlined,
              label: 'Unpin Sale',
              color: const Color(0xFF94A3B8),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Unpin Sale',
                    message: 'Unpin $selectedCount selected cars from sale?',
                    confirmLabel: 'Unpin All',
                    confirmColor: CarsAdminTheme.warning,
                    icon: Icons.push_pin_outlined,
                    onConfirm: () => _executeBulkPinSale(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.lock_rounded,
              label: 'Make Private',
              color: const Color(0xFF6366F1),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Make Private',
                    message: 'Make $selectedCount selected cars private?',
                    confirmLabel: 'Make Private',
                    confirmColor: const Color(0xFF6366F1),
                    icon: Icons.lock_rounded,
                    onConfirm: () => _executeBulkPrivate(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.lock_open_rounded,
              label: 'Make Public',
              color: const Color(0xFF94A3B8),
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Make Public',
                    message: 'Make $selectedCount selected cars public?',
                    confirmLabel: 'Make Public',
                    confirmColor: CarsAdminTheme.success,
                    icon: Icons.lock_open_rounded,
                    onConfirm: () => _executeBulkPrivate(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: CarsAdminTheme.error,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Delete Cars',
                    message:
                        'Delete $selectedCount selected cars? This cannot be undone.',
                    confirmLabel: 'Delete All',
                    confirmColor: CarsAdminTheme.error,
                    icon: Icons.delete_outline_rounded,
                    onConfirm: () => _executeBulkDelete(),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: confirmColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: confirmColor),
                  ),
                  const SizedBox(height: CarsAdminTheme.spacingLg),
                  Text(title, style: CarsAdminTheme.headingMedium),
                  const SizedBox(height: CarsAdminTheme.spacingSm),
                  Text(
                    message,
                    style: CarsAdminTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CarsAdminTheme.spacingXl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: CarsAdminTheme.outlineButtonStyle,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: CarsAdminTheme.spacingMd),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: CarsAdminTheme.spacingLg,
                              vertical: CarsAdminTheme.spacingMd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                CarsAdminTheme.radiusMd,
                              ),
                            ),
                          ),
                          child: Text(confirmLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _getShopId(String productId) {
    final product = adminCarsService.adminProducts.firstWhereOrNull(
      (p) => p.id == productId,
    );
    return product?.shop?.shop?.id ?? product?.shopId ?? '';
  }

  Future<void> _executeBulkActive(bool setActive) async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateActiveStatus(
      productIds: ids,
      shopId: shopId,
      setActive: setActive,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(result, setActive ? 'activated' : 'deactivated');
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkFeatured(bool setFeatured) async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateFeaturedStatus(
      productIds: ids,
      shopId: shopId,
      setFeatured: setFeatured,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(result, setFeatured ? 'featured' : 'unfeatured');
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkSold(bool setSold) async {
    final ids = adminCarsService.selectedProductIds.toList();

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateSoldStatus(
      productIds: ids,
      setSold: setSold,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setSold ? 'marked as sold' : 'marked as unsold',
    );
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkDeal(bool setDeal) async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateDealStatus(
      productIds: ids,
      shopId: shopId,
      setDeal: setDeal,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setDeal ? 'added to deals' : 'removed from deals',
    );
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkInventory(bool setInventory) async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateInventoryStatus(
      productIds: ids,
      shopId: shopId,
      setInventory: setInventory,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setInventory ? 'inventory assigned' : 'inventory unassigned',
    );
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkPinSale(bool setPinned) async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdatePinSaleStatus(
      productIds: ids,
      shopId: shopId,
      setPinned: setPinned,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setPinned ? 'pinned to sale' : 'unpinned from sale',
    );
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkPrivate(bool setPrivate) async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdatePrivateStatus(
      productIds: ids,
      shopId: shopId,
      setPrivate: setPrivate,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setPrivate ? 'made private' : 'made public',
    );
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkDelete() async {
    final ids = adminCarsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminCarsService.isBulkOperationRunning.value = true;
    adminCarsService.bulkOperationProgress.value = 0;
    adminCarsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkDeleteProducts(
      productIds: ids,
      shopId: shopId,
      onProgress: (completed, total) {
        adminCarsService.bulkOperationProgress.value = completed;
      },
    );

    adminCarsService.isBulkOperationRunning.value = false;
    adminCarsService.clearSelection();
    _showBulkResultSnackbar(result, 'deleted');
    await adminCarsService.refreshProducts();
    await adminCarsService.fetchProducts(refresh: true);
  }

  void _showBulkResultSnackbar(BulkOperationResult result, String action) {
    if (result.allSucceeded) {
      Get.snackbar(
        'Success',
        '${result.total} cars $action successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CarsAdminTheme.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: CarsAdminTheme.radiusMd,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else if (result.allFailed) {
      Get.snackbar(
        'Error',
        'Failed to $action ${result.total} cars',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CarsAdminTheme.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: CarsAdminTheme.radiusMd,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } else {
      Get.snackbar(
        'Partial Success',
        '${result.successCount} $action, ${result.failCount} failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CarsAdminTheme.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: CarsAdminTheme.radiusMd,
        icon: const Icon(Icons.info_outline, color: Colors.white),
      );
    }
  }
}
