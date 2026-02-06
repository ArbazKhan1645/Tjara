import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/auction_admin/widgets/order_item_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/shimmer.dart';
import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';

class AdminAuctionList extends StatelessWidget {
  final AdminAuctionService adminProductsService;

  const AdminAuctionList({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          children: [
            // Main content area
            _buildContent(),

            // Pagination
            if (!adminProductsService.isLoading.value &&
                adminProductsService.adminProducts.isNotEmpty)
              _AuctionPagination(adminProductsService: adminProductsService),

            // Load more indicator for infinite scroll
            if (adminProductsService.isPaginationLoading.value)
              const _LoadMoreIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildContent() {
    // Initial loading state
    if (adminProductsService.isLoading.value &&
        adminProductsService.adminProducts.isEmpty) {
      return const ProductsShimmerList(itemCount: 10);
    }

    // Empty state
    if (!adminProductsService.isLoading.value &&
        adminProductsService.adminProducts.isEmpty) {
      return _AuctionEmptyState(adminProductsService: adminProductsService);
    }

    // Products list
    return RefreshIndicator(
      onRefresh: adminProductsService.refreshProducts,
      color: AuctionAdminTheme.accent,
      backgroundColor: AuctionAdminTheme.surface,
      child: SingleChildScrollView(
        // Note: Don't use adminProductsService.scrollController here
        // That controller has pagination listener which triggers on horizontal scroll
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            const _AuctionTableHeader(),

            // Products
            ...adminProductsService.adminProducts.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: AuctionAdminTheme.spacingSm),
                child: AuctionOrderItemCard(product: product),
              ),
            ),

            // Loading more indicator at bottom of list
            if (adminProductsService.isPaginationLoading.value)
              const Padding(
                padding: EdgeInsets.all(AuctionAdminTheme.spacingLg),
                child: ProductShimmerCard(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Auction Table Header Widget
class _AuctionTableHeader extends StatelessWidget {
  const _AuctionTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: AuctionAdminTheme.spacingSm),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AuctionAdminTheme.accent, AuctionAdminTheme.accentDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        boxShadow: AuctionAdminTheme.shadowColored(AuctionAdminTheme.accent),
      ),
      child: const IntrinsicWidth(
        child: Row(
          children: [
            _HeaderCell(title: 'ID', width: 100),
            _HeaderCell(title: 'Product Image', width: 150),
            _HeaderCell(title: 'Product Name', width: 120),
            _HeaderCell(title: 'Shop Name', width: 150),
            _HeaderCell(title: 'Price', width: 100),
            _HeaderCell(title: 'Stock', width: 100),
            _HeaderCell(title: 'Auction Start', width: 170),
            _HeaderCell(title: 'Auction End', width: 170),
            _HeaderCell(title: 'Published', width: 120),
            _HeaderCell(title: 'Status', width: 100),
            _HeaderCell(title: 'Actions', width: 250),
          ],
        ),
      ),
    );
  }
}

/// Header Cell Widget
class _HeaderCell extends StatelessWidget {
  final String title;
  final double width;

  const _HeaderCell({
    required this.title,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingMd,
        vertical: AuctionAdminTheme.spacingMd,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Auction Empty State Widget
class _AuctionEmptyState extends StatelessWidget {
  final AdminAuctionService adminProductsService;

  const _AuctionEmptyState({required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AuctionAdminTheme.spacing2Xl),
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surface,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
        border: Border.all(color: AuctionAdminTheme.border),
        boxShadow: AuctionAdminTheme.shadowSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
            decoration: BoxDecoration(
              color: AuctionAdminTheme.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              size: 48,
              color: AuctionAdminTheme.accent,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingXl),

          // Title
          const Text(
            'No Auctions Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AuctionAdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingSm),

          // Message
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AuctionAdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingXl),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _EmptyStateButton(
                icon: Icons.clear_all_rounded,
                label: 'Clear Filters',
                onTap: () => adminProductsService.clearAllFilters(),
                isPrimary: false,
              ),
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              _EmptyStateButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onTap: () => adminProductsService.refreshProducts(),
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    if (adminProductsService.searchQuery.value.isNotEmpty) {
      return 'No auctions found matching "${adminProductsService.searchQuery.value}".\nTry adjusting your search terms or filters.';
    }

    if (adminProductsService.selectedStatus.value != ProductStatus.all ||
        adminProductsService.activeFilters.isNotEmpty ||
        adminProductsService.startDate.value != null) {
      return 'No auctions found with the current filters applied.\nTry removing some filters to see more results.';
    }

    return 'No auctions have been added yet.\nClick "Add Auction" to get started.';
  }
}

/// Empty State Button Widget
class _EmptyStateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _EmptyStateButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AuctionAdminTheme.spacingLg,
            vertical: AuctionAdminTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? AuctionAdminTheme.accent
                : AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(
              color: isPrimary
                  ? AuctionAdminTheme.accent
                  : AuctionAdminTheme.border,
            ),
            boxShadow: isPrimary
                ? AuctionAdminTheme.shadowColored(AuctionAdminTheme.accent)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : AuctionAdminTheme.textSecondary,
              ),
              const SizedBox(width: AuctionAdminTheme.spacingSm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : AuctionAdminTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Auction Pagination Widget
class _AuctionPagination extends StatelessWidget {
  final AdminAuctionService adminProductsService;

  const _AuctionPagination({required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (adminProductsService.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: AuctionAdminTheme.spacingLg),
        padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
        decoration: BoxDecoration(
          color: AuctionAdminTheme.surface,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
          border: Border.all(color: AuctionAdminTheme.border),
          boxShadow: AuctionAdminTheme.shadowSm,
        ),
        child: Column(
          children: [
            // Pagination info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingMd,
                vertical: AuctionAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.accentLight,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: Text(
                'Page ${adminProductsService.currentPage.value} of ${adminProductsService.totalPages.value}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AuctionAdminTheme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AuctionAdminTheme.spacingMd),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous page
                _PaginationButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: adminProductsService.currentPage.value > 1
                      ? adminProductsService.previousPage
                      : null,
                  tooltip: 'Previous Page',
                ),

                const SizedBox(width: AuctionAdminTheme.spacingSm),

                // Page numbers
                ...adminProductsService.visiblePageNumbers().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuctionAdminTheme.spacingXs,
                    ),
                    child: _PageNumberButton(
                      page: page,
                      isCurrentPage:
                          page == adminProductsService.currentPage.value,
                      onTap: () => adminProductsService.goToPage(page),
                    ),
                  ),
                ),

                const SizedBox(width: AuctionAdminTheme.spacingSm),

                // Next page
                _PaginationButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: adminProductsService.currentPage.value <
                          adminProductsService.totalPages.value
                      ? adminProductsService.nextPage
                      : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Pagination Button Widget
class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _PaginationButton({
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
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isEnabled
                  ? AuctionAdminTheme.surfaceSecondary
                  : AuctionAdminTheme.surfaceSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              border: Border.all(
                color: isEnabled
                    ? AuctionAdminTheme.border
                    : AuctionAdminTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? AuctionAdminTheme.textPrimary
                  : AuctionAdminTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Page Number Button Widget
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
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrentPage
                ? AuctionAdminTheme.accent
                : AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            border: Border.all(
              color: isCurrentPage
                  ? AuctionAdminTheme.accent
                  : AuctionAdminTheme.border,
            ),
            boxShadow: isCurrentPage
                ? AuctionAdminTheme.shadowColored(AuctionAdminTheme.accent)
                : null,
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w500,
                color: isCurrentPage
                    ? Colors.white
                    : AuctionAdminTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Load More Indicator Widget
class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AuctionAdminTheme.accent.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: AuctionAdminTheme.spacingMd),
          const Text(
            'Loading more auctions...',
            style: TextStyle(
              fontSize: 13,
              color: AuctionAdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
