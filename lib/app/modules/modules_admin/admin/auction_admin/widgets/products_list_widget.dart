import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/auction_admin/widgets/order_item_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/shimmer.dart';
import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';

class AdminAuctionList extends StatelessWidget {
  final AdminAuctionService adminAuctionService;

  const AdminAuctionList({super.key, required this.adminAuctionService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.only(
          bottom: adminAuctionService.selectedProductIds.isNotEmpty ? 140 : 80,
        ),
        child: Column(
          children: [
            _buildContent(context),
            if (!adminAuctionService.isLoading.value &&
                adminAuctionService.adminProducts.isNotEmpty)
              _buildPagination(),
            if (adminAuctionService.isPaginationLoading.value)
              _buildLoadMoreIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    // Initial loading state (check both isLoading and isRefreshing)
    if ((adminAuctionService.isLoading.value ||
            adminAuctionService.isRefreshing.value) &&
        adminAuctionService.adminProducts.isEmpty) {
      return const ProductsShimmerList(itemCount: 8);
    }

    // Empty state (only when not loading AND not refreshing)
    if (!adminAuctionService.isLoading.value &&
        !adminAuctionService.isRefreshing.value &&
        adminAuctionService.adminProducts.isEmpty) {
      return _buildEmptyState();
    }

    // Auctions list with smooth horizontal scrolling
    return RefreshIndicator(
      onRefresh: adminAuctionService.refreshProducts,
      color: AuctionAdminTheme.accent,
      backgroundColor: AuctionAdminTheme.surface,
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
                  const SizedBox(height: AuctionAdminTheme.spacingSm),
                  ...adminAuctionService.adminProducts.map((product) {
                    final productId = product.id ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AuctionAdminTheme.spacingSm,
                      ),
                      child: Obx(
                        () => AuctionOrderItemCard(
                          product: product,
                          isSelected: adminAuctionService.selectedProductIds
                              .contains(productId),
                          onSelectionChanged: (selected) {
                            adminAuctionService.toggleProductSelection(
                              productId,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  if (adminAuctionService.isPaginationLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(AuctionAdminTheme.spacingLg),
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
        color: AuctionAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        border: Border.all(color: AuctionAdminTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AuctionAdminTheme.spacingLg,
        ),
        child: Row(
          children: [
            // Select all checkbox
            SizedBox(
              width: 40,
              child: Obx(
                () => Checkbox(
                  value: adminAuctionService.isAllSelected,
                  onChanged: (_) => adminAuctionService.toggleSelectAll(),
                  activeColor: AuctionAdminTheme.accent,
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
            _buildHeaderCell('Auction Start', 140),
            _buildHeaderCell('Auction End', 140),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AuctionAdminTheme.labelMedium.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AuctionAdminTheme.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacing2Xl),
      decoration: AuctionAdminTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
            decoration: const BoxDecoration(
              color: AuctionAdminTheme.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_outlined,
              size: 48,
              color: AuctionAdminTheme.accent,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingXl),
          const Text(
            'No Auctions Found',
            style: AuctionAdminTheme.headingMedium,
          ),
          const SizedBox(height: AuctionAdminTheme.spacingSm),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: AuctionAdminTheme.bodyMedium,
          ),
          const SizedBox(height: AuctionAdminTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => adminAuctionService.clearAllFilters(),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear Filters'),
                style: AuctionAdminTheme.outlineButtonStyle,
              ),
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              ElevatedButton.icon(
                onPressed: () => adminAuctionService.refreshProducts(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: AuctionAdminTheme.primaryButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    final searchQuery = adminAuctionService.searchQuery.value;
    if (searchQuery.isNotEmpty) {
      return 'No auctions found matching "$searchQuery".\nTry adjusting your search terms or filters.';
    }

    final selectedStatus = adminAuctionService.selectedStatus.value;
    final activeFilters = adminAuctionService.activeFilters;
    final startDate = adminAuctionService.startDate.value;

    if (selectedStatus != ProductStatus.all ||
        activeFilters.isNotEmpty ||
        startDate != null) {
      return 'No auctions found with the current filters applied.\nTry removing some filters to see more results.';
    }

    return 'No auctions have been added yet.\nClick "Add New Auction" to get started.';
  }

  Widget _buildPagination() {
    return Obx(() {
      final totalPages = adminAuctionService.totalPages.value;
      if (totalPages <= 1) {
        return const SizedBox.shrink();
      }

      final currentPage = adminAuctionService.currentPage.value;

      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: AuctionAdminTheme.spacingLg,
        ),
        padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
        decoration: AuctionAdminTheme.cardDecoration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingMd,
                vertical: AuctionAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(
                  AuctionAdminTheme.radiusSm,
                ),
              ),
              child: Text(
                'Page $currentPage of $totalPages',
                style: AuctionAdminTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AuctionAdminTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaginationButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed:
                      currentPage > 1
                          ? adminAuctionService.previousPage
                          : null,
                  tooltip: 'Previous Page',
                ),
                const SizedBox(width: AuctionAdminTheme.spacingSm),
                ...adminAuctionService.visiblePageNumbers().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildPageNumberButton(page, currentPage),
                  ),
                ),
                const SizedBox(width: AuctionAdminTheme.spacingSm),
                _buildPaginationButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed:
                      currentPage < totalPages
                          ? adminAuctionService.nextPage
                          : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),
            if (totalPages > 10)
              Padding(
                padding: const EdgeInsets.only(
                  top: AuctionAdminTheme.spacingMd,
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
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? AuctionAdminTheme.surfaceSecondary
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              border: Border.all(
                color:
                    isEnabled
                        ? AuctionAdminTheme.border
                        : AuctionAdminTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  isEnabled
                      ? AuctionAdminTheme.textPrimary
                      : AuctionAdminTheme.textTertiary,
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
        onTap: () => adminAuctionService.goToPage(page),
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isCurrentPage
                    ? AuctionAdminTheme.accent
                    : AuctionAdminTheme.surface,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            border: Border.all(
              color:
                  isCurrentPage
                      ? AuctionAdminTheme.accent
                      : AuctionAdminTheme.border,
            ),
            boxShadow: isCurrentPage ? AuctionAdminTheme.shadowSm : null,
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w400,
              color:
                  isCurrentPage
                      ? AuctionAdminTheme.textOnPrimary
                      : AuctionAdminTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJumpToPage() {
    final TextEditingController controller = TextEditingController();
    final totalPages = adminAuctionService.totalPages.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Go to page:', style: AuctionAdminTheme.bodySmall),
        const SizedBox(width: AuctionAdminTheme.spacingSm),
        SizedBox(
          width: 64,
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AuctionAdminTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingSm,
                vertical: AuctionAdminTheme.spacingXs,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AuctionAdminTheme.radiusSm,
                ),
                borderSide: const BorderSide(color: AuctionAdminTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AuctionAdminTheme.radiusSm,
                ),
                borderSide: const BorderSide(color: AuctionAdminTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AuctionAdminTheme.radiusSm,
                ),
                borderSide: const BorderSide(color: AuctionAdminTheme.accent),
              ),
            ),
            onSubmitted: (value) {
              final page = int.tryParse(value) ?? 0;
              if (page >= 1 && page <= totalPages) {
                adminAuctionService.goToPage(page);
                controller.clear();
              }
            },
          ),
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final page = int.tryParse(controller.text) ?? 0;
              if (page >= 1 && page <= totalPages) {
                adminAuctionService.goToPage(page);
                controller.clear();
              }
            },
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.accent,
                borderRadius: BorderRadius.circular(
                  AuctionAdminTheme.radiusSm,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AuctionAdminTheme.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AuctionAdminTheme.accent,
            ),
          ),
          SizedBox(width: AuctionAdminTheme.spacingMd),
          Text('Loading more auctions...', style: AuctionAdminTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Floating bulk action bar for auction admin - use at Scaffold level for true floating effect
class AuctionBulkActionBar extends StatelessWidget {
  final AdminAuctionService adminAuctionService;

  const AuctionBulkActionBar({super.key, required this.adminAuctionService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCount = adminAuctionService.selectedProductIds.length;
      final isRunning = adminAuctionService.isBulkOperationRunning.value;
      final progress = adminAuctionService.bulkOperationProgress.value;
      final total = adminAuctionService.bulkOperationTotal.value;

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
                  color: AuctionAdminTheme.success,
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
                color: AuctionAdminTheme.accent,
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
                onTap: adminAuctionService.clearSelection,
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
              color: AuctionAdminTheme.success,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Activate Auctions',
                    message: 'Make $selectedCount selected auctions active?',
                    confirmLabel: 'Activate All',
                    confirmColor: AuctionAdminTheme.success,
                    icon: Icons.visibility_rounded,
                    onConfirm: () => _executeBulkActive(true),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.visibility_off_rounded,
              label: 'Deactivate',
              color: AuctionAdminTheme.warning,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Deactivate Auctions',
                    message: 'Make $selectedCount selected auctions inactive?',
                    confirmLabel: 'Deactivate All',
                    confirmColor: AuctionAdminTheme.warning,
                    icon: Icons.visibility_off_rounded,
                    onConfirm: () => _executeBulkActive(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.star_rounded,
              label: 'Feature',
              color: AuctionAdminTheme.warning,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Feature Auctions',
                    message: 'Make $selectedCount selected auctions featured?',
                    confirmLabel: 'Feature All',
                    confirmColor: AuctionAdminTheme.warning,
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
                    title: 'Unfeature Auctions',
                    message:
                        'Remove $selectedCount selected auctions from featured?',
                    confirmLabel: 'Unfeature All',
                    confirmColor: AuctionAdminTheme.warning,
                    icon: Icons.star_outline_rounded,
                    onConfirm: () => _executeBulkFeatured(false),
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
                    message: 'Add $selectedCount selected auctions to deals?',
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
                    message:
                        'Remove $selectedCount selected auctions from deals?',
                    confirmLabel: 'Remove from Deals',
                    confirmColor: AuctionAdminTheme.warning,
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
                        'Mark $selectedCount selected auctions as inventory assigned?',
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
                        'Unassign inventory from $selectedCount selected auctions?',
                    confirmLabel: 'Unassign All',
                    confirmColor: AuctionAdminTheme.warning,
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
                        'Pin $selectedCount selected auctions to sale?',
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
                        'Unpin $selectedCount selected auctions from sale?',
                    confirmLabel: 'Unpin All',
                    confirmColor: AuctionAdminTheme.warning,
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
                        'Make $selectedCount selected auctions private?',
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
                        'Make $selectedCount selected auctions public?',
                    confirmLabel: 'Make Public',
                    confirmColor: AuctionAdminTheme.success,
                    icon: Icons.lock_open_rounded,
                    onConfirm: () => _executeBulkPrivate(false),
                  ),
            ),
            _buildActionChip(
              context: context,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AuctionAdminTheme.error,
              onTap:
                  () => _showBulkConfirmation(
                    context: context,
                    title: 'Delete Auctions',
                    message:
                        'Delete $selectedCount selected auctions? This cannot be undone.',
                    confirmLabel: 'Delete All',
                    confirmColor: AuctionAdminTheme.error,
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
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
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
                  const SizedBox(height: AuctionAdminTheme.spacingLg),
                  Text(title, style: AuctionAdminTheme.headingMedium),
                  const SizedBox(height: AuctionAdminTheme.spacingSm),
                  Text(
                    message,
                    style: AuctionAdminTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AuctionAdminTheme.spacingXl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: AuctionAdminTheme.outlineButtonStyle,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AuctionAdminTheme.spacingMd),
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
                              horizontal: AuctionAdminTheme.spacingLg,
                              vertical: AuctionAdminTheme.spacingMd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AuctionAdminTheme.radiusMd,
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
    final product = adminAuctionService.adminProducts.firstWhereOrNull(
      (p) => p.id == productId,
    );
    return product?.shop?.shop?.id ?? product?.shopId ?? '';
  }

  Future<void> _executeBulkActive(bool setActive) async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateActiveStatus(
      productIds: ids,
      shopId: shopId,
      setActive: setActive,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(result, setActive ? 'activated' : 'deactivated');
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkFeatured(bool setFeatured) async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateFeaturedStatus(
      productIds: ids,
      shopId: shopId,
      setFeatured: setFeatured,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(result, setFeatured ? 'featured' : 'unfeatured');
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkDeal(bool setDeal) async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateDealStatus(
      productIds: ids,
      shopId: shopId,
      setDeal: setDeal,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setDeal ? 'added to deals' : 'removed from deals',
    );
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkInventory(bool setInventory) async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdateInventoryStatus(
      productIds: ids,
      shopId: shopId,
      setInventory: setInventory,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setInventory ? 'inventory assigned' : 'inventory unassigned',
    );
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkPinSale(bool setPinned) async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdatePinSaleStatus(
      productIds: ids,
      shopId: shopId,
      setPinned: setPinned,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setPinned ? 'pinned to sale' : 'unpinned from sale',
    );
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkPrivate(bool setPrivate) async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkUpdatePrivateStatus(
      productIds: ids,
      shopId: shopId,
      setPrivate: setPrivate,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(
      result,
      setPrivate ? 'made private' : 'made public',
    );
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  Future<void> _executeBulkDelete() async {
    final ids = adminAuctionService.selectedProductIds.toList();
    final shopId = _getShopId(ids.first);

    adminAuctionService.isBulkOperationRunning.value = true;
    adminAuctionService.bulkOperationProgress.value = 0;
    adminAuctionService.bulkOperationTotal.value = ids.length;

    final result = await ProductService.bulkDeleteProducts(
      productIds: ids,
      shopId: shopId,
      onProgress: (completed, total) {
        adminAuctionService.bulkOperationProgress.value = completed;
      },
    );

    adminAuctionService.isBulkOperationRunning.value = false;
    adminAuctionService.clearSelection();
    _showBulkResultSnackbar(result, 'deleted');
    await adminAuctionService.refreshProducts();
    await adminAuctionService.fetchProducts(refresh: true);
  }

  void _showBulkResultSnackbar(BulkOperationResult result, String action) {
    if (result.allSucceeded) {
      Get.snackbar(
        'Success',
        '${result.total} auctions $action successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AuctionAdminTheme.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: AuctionAdminTheme.radiusMd,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else if (result.allFailed) {
      Get.snackbar(
        'Error',
        'Failed to $action ${result.total} auctions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AuctionAdminTheme.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: AuctionAdminTheme.radiusMd,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } else {
      Get.snackbar(
        'Partial Success',
        '${result.successCount} $action, ${result.failCount} failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AuctionAdminTheme.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: AuctionAdminTheme.radiusMd,
        icon: const Icon(Icons.info_outline, color: Colors.white),
      );
    }
  }
}
