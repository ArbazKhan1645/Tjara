import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            // Main content area
            _buildContent(),

            // Pagination
            if (!adminProductsService.isLoading.value &&
                adminProductsService.adminProducts.isNotEmpty)
              _buildPagination(),

            // Load more indicator for infinite scroll
            if (adminProductsService.isPaginationLoading.value)
              _buildLoadMoreIndicator(),
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
      return _buildEmptyState();
    }

    // Products list
    return RefreshIndicator(
      onRefresh: adminProductsService.refreshProducts,
      child: SingleChildScrollView(
        controller: adminProductsService.scrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            _buildTableHeader(),

            // Products
            ...adminProductsService.adminProducts.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OrderItemCard(product: product),
              ),
            ),

            // Loading more indicator at bottom of list
            if (adminProductsService.isPaginationLoading.value)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: ProductShimmerCard(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicWidth(
        child: Row(
          children: [
            _buildHeaderCell('Product ID', 100),
            _buildHeaderCell('Image', 150),
            _buildHeaderCell('Product Name', 120),
            _buildHeaderCell('Shop Name', 150),
            _buildHeaderCell('Price', 100),
            _buildHeaderCell('Stock', 100),
            _buildHeaderCell('Published At', 120),
            _buildHeaderCell('Status', 100),
            _buildHeaderCell('Actions', 250),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => adminProductsService.clearAllFilters(),
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => adminProductsService.refreshProducts(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    if (adminProductsService.searchQuery.value.isNotEmpty) {
      return 'No products found matching "${adminProductsService.searchQuery.value}".\nTry adjusting your search terms or filters.';
    }

    if (adminProductsService.selectedStatus.value != ProductStatus.all ||
        adminProductsService.activeFilters.isNotEmpty ||
        adminProductsService.startDate.value != null) {
      return 'No products found with the current filters applied.\nTry removing some filters to see more results.';
    }

    return 'No products have been added yet.\nClick "Add New Product" to get started.';
  }

  Widget _buildPagination() {
    return Obx(() {
      if (adminProductsService.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: Column(
          children: [
            // Pagination info
            Text(
              'Page ${adminProductsService.currentPage.value} of ${adminProductsService.totalPages.value}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First page
                // _buildPaginationButton(
                //   icon: Icons.first_page,
                //   onPressed:
                //       adminProductsService.currentPage.value > 1
                //           ? () => adminProductsService.goToPage(1)
                //           : null,
                //   tooltip: 'First Page',
                // ),

                // Previous page
                _buildPaginationButton(
                  icon: Icons.chevron_left,
                  onPressed:
                      adminProductsService.currentPage.value > 1
                          ? adminProductsService.previousPage
                          : null,
                  tooltip: 'Previous Page',
                ),

                const SizedBox(width: 8),

                // Page numbers
                ...adminProductsService.visiblePageNumbers().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildPageNumberButton(page),
                  ),
                ),

                const SizedBox(width: 8),

                // Next page
                _buildPaginationButton(
                  icon: Icons.chevron_right,
                  onPressed:
                      adminProductsService.currentPage.value <
                              adminProductsService.totalPages.value
                          ? adminProductsService.nextPage
                          : null,
                  tooltip: 'Next Page',
                ),

                // Last page
                // _buildPaginationButton(
                //   icon: Icons.last_page,
                //   onPressed:
                //       adminProductsService.currentPage.value <
                //               adminProductsService.totalPages.value
                //           ? () => adminProductsService.goToPage(
                //             adminProductsService.totalPages.value,
                //           )
                //           : null,
                //   tooltip: 'Last Page',
                // ),
              ],
            ),

            // Jump to page
            if (adminProductsService.totalPages.value > 10)
              Padding(
                padding: const EdgeInsets.only(top: 12),
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
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: onPressed != null ? Colors.grey.shade100 : null,
          foregroundColor:
              onPressed != null ? Colors.black87 : Colors.grey.shade400,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(int page) {
    final isCurrentPage = page == adminProductsService.currentPage.value;

    return SizedBox(
      width: 36,
      height: 36,
      child: ElevatedButton(
        onPressed: () => adminProductsService.goToPage(page),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: isCurrentPage ? Colors.blue : Colors.grey.shade100,
          foregroundColor: isCurrentPage ? Colors.white : Colors.black87,
          elevation: isCurrentPage ? 2 : 0,
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildJumpToPage() {
    final TextEditingController controller = TextEditingController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Go to page:',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          height: 32,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              isDense: true,
            ),
            onSubmitted: (value) {
              final page = int.tryParse(value);
              if (page != null &&
                  page >= 1 &&
                  page <= adminProductsService.totalPages.value) {
                adminProductsService.goToPage(page);
                controller.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () {
            final page = int.tryParse(controller.text);
            if (page != null &&
                page >= 1 &&
                page <= adminProductsService.totalPages.value) {
              adminProductsService.goToPage(page);
              controller.clear();
            }
          },
          icon: const Icon(Icons.arrow_forward, size: 16),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(4),
            minimumSize: const Size(24, 24),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more products...',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
