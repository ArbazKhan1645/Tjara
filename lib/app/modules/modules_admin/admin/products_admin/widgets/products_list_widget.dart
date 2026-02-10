import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/admin_products_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/order_item_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/shimmer.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class AdminProductsList extends StatelessWidget {
  final AdminProductsService adminProductsService;

  const AdminProductsList({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.only(
          bottom: adminProductsService.selectedProductIds.isNotEmpty ? 140 : 80,
        ),
        child: Column(
          children: [
            _buildContent(context),
            if (!adminProductsService.isLoading.value &&
                adminProductsService.adminProducts.isNotEmpty)
              _buildPagination(),
            if (adminProductsService.isPaginationLoading.value)
              _buildLoadMoreIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    // Initial loading state
    if (adminProductsService.isLoading.value &&
        adminProductsService.adminProducts.isEmpty) {
      return const ProductsShimmerList(itemCount: 8);
    }

    // Empty state
    if (!adminProductsService.isLoading.value &&
        adminProductsService.adminProducts.isEmpty) {
      return _buildEmptyState();
    }

    // Products list with smooth horizontal scrolling
    return RefreshIndicator(
      onRefresh: adminProductsService.refreshProducts,
      color: AdminProductsTheme.primary,
      backgroundColor: AdminProductsTheme.surface,
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
                  const SizedBox(height: AdminProductsTheme.spacingSm),
                  ...adminProductsService.adminProducts.map((product) {
                    final productId = product.id ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AdminProductsTheme.spacingSm,
                      ),
                      child: Obx(
                        () => ProductItemCard(
                          product: product,
                          isSelected: adminProductsService.selectedProductIds
                              .contains(productId),
                          onSelectionChanged: (selected) {
                            adminProductsService.toggleProductSelection(
                              productId,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  if (adminProductsService.isPaginationLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(AdminProductsTheme.spacingLg),
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
      decoration: AdminProductsTheme.tableHeaderDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminProductsTheme.spacingLg,
        ),
        child: Row(
          children: [
            // Select all checkbox
            SizedBox(
              width: 40,
              child: Obx(
                () => Checkbox(
                  value: adminProductsService.isAllSelected,
                  onChanged: (_) => adminProductsService.toggleSelectAll(),
                  activeColor: AdminProductsTheme.primary,
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
            _buildHeaderCell('Stock', 80),
            _buildHeaderCell('Published', 120),
            _buildHeaderCell('Status', 100),
            _buildHeaderCell('Actions', 200),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AdminProductsTheme.labelMedium.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AdminProductsTheme.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminProductsTheme.spacing2Xl),
      decoration: AdminProductsTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
            decoration: const BoxDecoration(
              color: AdminProductsTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AdminProductsTheme.primary,
            ),
          ),
          const SizedBox(height: AdminProductsTheme.spacingXl),
          const Text(
            'No Products Found',
            style: AdminProductsTheme.headingMedium,
          ),
          const SizedBox(height: AdminProductsTheme.spacingSm),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: AdminProductsTheme.bodyMedium,
          ),
          const SizedBox(height: AdminProductsTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => adminProductsService.clearAllFilters(),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear Filters'),
                style: AdminProductsTheme.outlineButtonStyle,
              ),
              const SizedBox(width: AdminProductsTheme.spacingMd),
              ElevatedButton.icon(
                onPressed: () => adminProductsService.refreshProducts(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: AdminProductsTheme.primaryButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    final searchQuery = adminProductsService.searchQuery.value;
    if (searchQuery.isNotEmpty) {
      return 'No products found matching "$searchQuery".\nTry adjusting your search terms or filters.';
    }

    final selectedStatus = adminProductsService.selectedStatus.value;
    final activeFilters = adminProductsService.activeFilters;
    final startDate = adminProductsService.startDate.value;

    if (selectedStatus != ProductStatus.all ||
        activeFilters.isNotEmpty ||
        startDate != null) {
      return 'No products found with the current filters applied.\nTry removing some filters to see more results.';
    }

    return 'No products have been added yet.\nClick "Add New Product" to get started.';
  }

  Widget _buildPagination() {
    return Obx(() {
      final totalPages = adminProductsService.totalPages.value;
      if (totalPages <= 1) {
        return const SizedBox.shrink();
      }

      final currentPage = adminProductsService.currentPage.value;

      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: AdminProductsTheme.spacingLg,
        ),
        padding: const EdgeInsets.all(AdminProductsTheme.spacingLg),
        decoration: AdminProductsTheme.cardDecoration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminProductsTheme.spacingMd,
                vertical: AdminProductsTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AdminProductsTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
              ),
              child: Text(
                'Page $currentPage of $totalPages',
                style: AdminProductsTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AdminProductsTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaginationButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed:
                      currentPage > 1
                          ? adminProductsService.previousPage
                          : null,
                  tooltip: 'Previous Page',
                ),
                const SizedBox(width: AdminProductsTheme.spacingSm),
                ...adminProductsService.visiblePageNumbers().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildPageNumberButton(page, currentPage),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingSm),
                _buildPaginationButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed:
                      currentPage < totalPages
                          ? adminProductsService.nextPage
                          : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),
            if (totalPages > 10)
              Padding(
                padding: const EdgeInsets.only(
                  top: AdminProductsTheme.spacingMd,
                ),
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
          borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AdminProductsTheme.spacingSm),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? AdminProductsTheme.surfaceSecondary
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
              border: Border.all(
                color:
                    isEnabled
                        ? AdminProductsTheme.border
                        : AdminProductsTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  isEnabled
                      ? AdminProductsTheme.textPrimary
                      : AdminProductsTheme.textTertiary,
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
        onTap: () => adminProductsService.goToPage(page),
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isCurrentPage
                    ? AdminProductsTheme.primary
                    : AdminProductsTheme.surface,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            border: Border.all(
              color:
                  isCurrentPage
                      ? AdminProductsTheme.primary
                      : AdminProductsTheme.border,
            ),
            boxShadow: isCurrentPage ? AdminProductsTheme.shadowSm : null,
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w400,
              color:
                  isCurrentPage
                      ? AdminProductsTheme.textOnPrimary
                      : AdminProductsTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJumpToPage() {
    final TextEditingController controller = TextEditingController();
    final totalPages = adminProductsService.totalPages.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Go to page:', style: AdminProductsTheme.bodySmall),
        const SizedBox(width: AdminProductsTheme.spacingSm),
        SizedBox(
          width: 64,
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AdminProductsTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdminProductsTheme.spacingSm,
                vertical: AdminProductsTheme.spacingXs,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
                borderSide: const BorderSide(color: AdminProductsTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
                borderSide: const BorderSide(color: AdminProductsTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
                borderSide: const BorderSide(color: AdminProductsTheme.primary),
              ),
            ),
            onSubmitted: (value) {
              final page = int.tryParse(value) ?? 0;
              if (page >= 1 && page <= totalPages) {
                adminProductsService.goToPage(page);
                controller.clear();
              }
            },
          ),
        ),
        const SizedBox(width: AdminProductsTheme.spacingXs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final page = int.tryParse(controller.text) ?? 0;
              if (page >= 1 && page <= totalPages) {
                adminProductsService.goToPage(page);
                controller.clear();
              }
            },
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(AdminProductsTheme.spacingSm),
              decoration: BoxDecoration(
                color: AdminProductsTheme.primary,
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AdminProductsTheme.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(AdminProductsTheme.spacingLg),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AdminProductsTheme.primary,
            ),
          ),
          SizedBox(width: AdminProductsTheme.spacingMd),
          Text('Loading more products...', style: AdminProductsTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Floating bulk action bar - use at Scaffold level for true floating effect
class BulkActionBar extends StatelessWidget {
  final AdminProductsService adminProductsService;

  const BulkActionBar({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCount = adminProductsService.selectedProductIds.length;
      final isRunning = adminProductsService.isBulkOperationRunning.value;
      final progress = adminProductsService.bulkOperationProgress.value;
      final total = adminProductsService.bulkOperationTotal.value;

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF015c5d),
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
                  color: AdminProductsTheme.success,
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
                color: AdminProductsTheme.primary,
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
                onTap: adminProductsService.clearSelection,
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
              color: AdminProductsTheme.success,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Activate Products',
                    message: 'Make $selectedCount selected products active?',
                    confirmLabel: 'Activate All',
                    confirmColor: AdminProductsTheme.success,
                    icon: Icons.visibility_rounded,
                    onConfirm: () => _executeBulkActive(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.visibility_off_rounded,
              label: 'Deactivate',
              color: AdminProductsTheme.warning,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Deactivate Products',
                    message: 'Make $selectedCount selected products inactive?',
                    confirmLabel: 'Deactivate All',
                    confirmColor: AdminProductsTheme.warning,
                    icon: Icons.visibility_off_rounded,
                    onConfirm: () => _executeBulkActive(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.star_rounded,
              label: 'Feature',
              color: AdminProductsTheme.featured,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Feature Products',
                    message: 'Make $selectedCount selected products featured?',
                    confirmLabel: 'Feature All',
                    confirmColor: AdminProductsTheme.featured,
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
                    title: 'Unfeature Products',
                    message:
                        'Remove $selectedCount selected products from featured?',
                    confirmLabel: 'Unfeature All',
                    confirmColor: AdminProductsTheme.warning,
                    icon: Icons.star_outline_rounded,
                    onConfirm: () => _executeBulkFeatured(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.local_offer_rounded,
              label: 'Add Deal',
              color: AdminProductsTheme.deal,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Add to Deals',
                    message: 'Add $selectedCount selected products to deals?',
                    confirmLabel: 'Add to Deals',
                    confirmColor: AdminProductsTheme.deal,
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
                    message:
                        'Remove $selectedCount selected products from deals?',
                    confirmLabel: 'Remove from Deals',
                    confirmColor: AdminProductsTheme.warning,
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
                        'Mark $selectedCount selected products as inventory assigned?',
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
                        'Unassign inventory from $selectedCount selected products?',
                    confirmLabel: 'Unassign All',
                    confirmColor: AdminProductsTheme.warning,
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
                    message:
                        'Pin $selectedCount selected products to sale?',
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
                    message:
                        'Unpin $selectedCount selected products from sale?',
                    confirmLabel: 'Unpin All',
                    confirmColor: AdminProductsTheme.warning,
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
                    message:
                        'Make $selectedCount selected products private?',
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
                    message:
                        'Make $selectedCount selected products public?',
                    confirmLabel: 'Make Public',
                    confirmColor: AdminProductsTheme.success,
                    icon: Icons.lock_open_rounded,
                    onConfirm: () => _executeBulkPrivate(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AdminProductsTheme.error,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Delete Products',
                    message:
                        'Delete $selectedCount selected products? This cannot be undone.',
                    confirmLabel: 'Delete All',
                    confirmColor: AdminProductsTheme.error,
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
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
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
                  const SizedBox(height: AdminProductsTheme.spacingLg),
                  Text(title, style: AdminProductsTheme.headingMedium),
                  const SizedBox(height: AdminProductsTheme.spacingSm),
                  Text(
                    message,
                    style: AdminProductsTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AdminProductsTheme.spacingXl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: AdminProductsTheme.outlineButtonStyle,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AdminProductsTheme.spacingMd),
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
                              horizontal: AdminProductsTheme.spacingLg,
                              vertical: AdminProductsTheme.spacingMd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AdminProductsTheme.radiusMd,
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
    final product = adminProductsService.adminProducts.firstWhereOrNull(
      (p) => p.id == productId,
    );
    return product?.shop?.shop?.id ?? product?.shopId ?? '';
  }

  Map<String, String> _getProductTypes(List<String> productIds) {
    final map = <String, String>{};
    for (final id in productIds) {
      final product = adminProductsService.adminProducts.firstWhereOrNull(
        (p) => p.id == id,
      );
      map[id] = product?.productType ?? 'simple';
    }
    return map;
  }

  Future<void> _executeBulkActive(bool setActive) async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);
    final productTypes = _getProductTypes(ids);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateActiveStatus(
      productIds: ids,
      shopId: shopId,
      setActive: setActive,
      productTypes: productTypes,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(result, setActive ? 'activated' : 'deactivated');
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkFeatured(bool setFeatured) async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);
    final productTypes = _getProductTypes(ids);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateFeaturedStatus(
      productIds: ids,
      shopId: shopId,
      setFeatured: setFeatured,
      productTypes: productTypes,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(result, setFeatured ? 'featured' : 'unfeatured');
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkDeal(bool setDeal) async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);
    final productTypes = _getProductTypes(ids);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateDealStatus(
      productIds: ids,
      shopId: shopId,
      setDeal: setDeal,
      productTypes: productTypes,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setDeal ? 'added to deals' : 'removed from deals',
    );
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkInventory(bool setInventory) async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);
    final productTypes = _getProductTypes(ids);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateInventoryStatus(
      productIds: ids,
      shopId: shopId,
      setInventory: setInventory,
      productTypes: productTypes,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setInventory ? 'inventory assigned' : 'inventory unassigned',
    );
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkPinSale(bool setPinned) async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);
    final productTypes = _getProductTypes(ids);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdatePinSaleStatus(
      productIds: ids,
      shopId: shopId,
      setPinned: setPinned,
      productTypes: productTypes,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setPinned ? 'pinned to sale' : 'unpinned from sale',
    );
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkPrivate(bool setPrivate) async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);
    final productTypes = _getProductTypes(ids);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdatePrivateStatus(
      productIds: ids,
      shopId: shopId,
      setPrivate: setPrivate,
      productTypes: productTypes,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setPrivate ? 'made private' : 'made public',
    );
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkDelete() async {
    final ids = adminProductsService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminProductsService.isBulkOperationRunning.value = true;
    adminProductsService.bulkOperationProgress.value = 0;
    adminProductsService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkDeleteProducts(
      productIds: ids,
      shopId: shopId,
      onProgress: (completed, total) {
        adminProductsService.bulkOperationProgress.value = completed;
      },
    );

    adminProductsService.isBulkOperationRunning.value = false;
    adminProductsService.clearSelection();
    _showBulkResultSnackbar(result, 'deleted');
    await adminProductsService.refreshProducts();
    await adminProductsService.fetchProducts(refresh: true);
  }

  void _showBulkResultSnackbar(BulkOperationResult result, String action) {
    if (result.allSucceeded) {
      Get.snackbar(
        'Success',
        '${result.total} products $action successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AdminProductsTheme.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: AdminProductsTheme.radiusMd,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else if (result.allFailed) {
      Get.snackbar(
        'Error',
        'Failed to $action ${result.total} products',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AdminProductsTheme.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: AdminProductsTheme.radiusMd,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } else {
      Get.snackbar(
        'Partial Success',
        '${result.successCount} $action, ${result.failCount} failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AdminProductsTheme.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: AdminProductsTheme.radiusMd,
        icon: const Icon(Icons.info_outline, color: Colors.white),
      );
    }
  }
}
