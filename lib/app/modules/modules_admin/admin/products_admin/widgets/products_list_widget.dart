import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/admin_products_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/order_item_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/shimmer.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class AdminProductsList extends StatelessWidget {
  final AdminProductsService adminProductsService;

  const AdminProductsList({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
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
          return Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              // Note: Don't use adminProductsService.scrollController here
              // That controller has pagination listener which triggers on horizontal scroll
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableHeader(),
                    const SizedBox(height: AdminProductsTheme.spacingSm),
                    ...adminProductsService.adminProducts.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AdminProductsTheme.spacingSm,
                        ),
                        child: ProductItemCard(product: product),
                      ),
                    ),
                    if (adminProductsService.isPaginationLoading.value)
                      const Padding(
                        padding: EdgeInsets.all(AdminProductsTheme.spacingLg),
                        child: ProductShimmerCard(),
                      ),
                  ],
                ),
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
        margin: const EdgeInsets.symmetric(vertical: AdminProductsTheme.spacingLg),
        padding: const EdgeInsets.all(AdminProductsTheme.spacingLg),
        decoration: AdminProductsTheme.cardDecoration,
        child: Column(
          children: [
            // Pagination info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminProductsTheme.spacingMd,
                vertical: AdminProductsTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AdminProductsTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
              ),
              child: Text(
                'Page $currentPage of $totalPages',
                style: AdminProductsTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AdminProductsTheme.spacingMd),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous page
                _buildPaginationButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: currentPage > 1
                      ? adminProductsService.previousPage
                      : null,
                  tooltip: 'Previous Page',
                ),

                const SizedBox(width: AdminProductsTheme.spacingSm),

                // Page numbers
                ...adminProductsService.visiblePageNumbers().map(
                      (page) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildPageNumberButton(page, currentPage),
                      ),
                    ),

                const SizedBox(width: AdminProductsTheme.spacingSm),

                // Next page
                _buildPaginationButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed: currentPage < totalPages
                      ? adminProductsService.nextPage
                      : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),

            // Jump to page
            if (totalPages > 10)
              Padding(
                padding: const EdgeInsets.only(top: AdminProductsTheme.spacingMd),
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
              color: isEnabled
                  ? AdminProductsTheme.surfaceSecondary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
              border: Border.all(
                color: isEnabled
                    ? AdminProductsTheme.border
                    : AdminProductsTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
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
            color: isCurrentPage
                ? AdminProductsTheme.primary
                : AdminProductsTheme.surface,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            border: Border.all(
              color: isCurrentPage
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
              color: isCurrentPage
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
        const Text(
          'Go to page:',
          style: AdminProductsTheme.bodySmall,
        ),
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
                borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
                borderSide: const BorderSide(color: AdminProductsTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
                borderSide: const BorderSide(color: AdminProductsTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
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
                borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
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
          Text(
            'Loading more products...',
            style: AdminProductsTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
