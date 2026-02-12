// screens/product_review_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/products_review_model/products_review_model.dart';
import 'package:tjara/app/modules/modules_admin/cars_products_reviews/controller.dart';

class CarsProductReviewScreen extends StatelessWidget {
  const CarsProductReviewScreen({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CarsProductReviewController());
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(12),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.grey.withOpacity(0.1),
                  //       blurRadius: 4,
                  //       offset: const Offset(0, 2),
                  //     ),
                  //   ],
                  // ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search reviews by user, product, or content...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(
                        () =>
                            controller.searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: controller.clearSearch,
                                )
                                : const SizedBox.shrink(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),

                // Stats Bar
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    // color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Reviews',
                            controller.totalReviews.toString(),
                            Icons.rate_review,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Current Page',
                            '${controller.currentPage}/${controller.totalPages}',
                            Icons.pages,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Showing',
                            controller.reviews.length.toString(),
                            Icons.visibility,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading && !controller.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.hasError && !controller.hasData) {
                      return _buildErrorWidget(controller);
                    }

                    if (!controller.hasData) {
                      return _buildEmptyWidget();
                    }

                    return _buildReviewDataTable(controller);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(CarsProductReviewController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshReviews,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no reviews to display at the moment.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDataTable(CarsProductReviewController controller) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: SizedBox(
                width: Get.width > 800 ? Get.width : 800,
                child: DataTable(
                  headingRowHeight: 56,
                  dataRowHeight: 72,
                  columnSpacing: 16,
                  horizontalMargin: 16,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text('User'),
                      tooltip: 'User information',
                    ),
                    DataColumn(
                      label: Text('Product'),
                      tooltip: 'Product information',
                    ),
                    DataColumn(label: Text('Rating'), tooltip: 'Review rating'),
                    DataColumn(
                      label: Text('Review'),
                      tooltip: 'Review content',
                    ),
                    DataColumn(label: Text('Date'), tooltip: 'Review date'),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Available actions',
                    ),
                  ],
                  rows:
                      controller.reviews.map((review) {
                        return DataRow(
                          cells: [
                            DataCell(_buildUserCell(review)),
                            DataCell(_buildProductCell(review)),
                            DataCell(_buildRatingCell(review, controller)),
                            DataCell(_buildReviewCell(review)),
                            DataCell(_buildDateCell(review, controller)),
                            DataCell(_buildActionsCell(review, controller)),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ),

        // Load More Button
        if (controller.hasMoreData || controller.isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16),
            child:
                controller.isLoadingMore
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                      onPressed: controller.loadMoreReviews,
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Load More'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
          ),
      ],
    );
  }

  Widget _buildUserCell(ReviewData review) {
    final user = review.user?.user;
    if (user == null) {
      return const SizedBox(); // Return an empty widget if product is null
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            user.email.toString(),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
          if (user.phone.toString().isNotEmpty)
            Text(
              user.phone.toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCell(ReviewData review) {
    final product = review.product?.product;
    if (product == null) {
      return const SizedBox(); // Return an empty widget if product is null
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            product.name.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            '\$${(product.price ?? 0).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if ((product.shop?.shop?.name ?? '').isNotEmpty)
            Text(
              product.shop?.shop?.name ?? '',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildRatingCell(
    ReviewData review,
    CarsProductReviewController controller,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: controller.getRatingColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.getRatingColor().withOpacity(0.3),
            ),
          ),
          child: Text(
            controller.getRatingStars(review.rating),
            style: TextStyle(
              color: controller.getRatingColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${review.rating}/5',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildReviewCell(ReviewData review) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child:
          review.description.isNotEmpty
              ? Text(
                review.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              )
              : Text(
                'No review text',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
    );
  }

  Widget _buildDateCell(
    ReviewData review,
    CarsProductReviewController controller,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.getFormattedDate(review.createdAt),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        if (review.createdAt != review.updatedAt)
          Text(
            'Updated',
            style: TextStyle(fontSize: 10, color: Colors.orange.shade600),
          ),
      ],
    );
  }

  Widget _buildActionsCell(
    ReviewData review,
    CarsProductReviewController controller,
  ) {
    return GetBuilder<CarsProductReviewController>(
      id: 'delete_${review.id}',
      builder: (controller) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 18),
              onPressed: () => _showReviewDetails(review),
              tooltip: 'View Details',
              color: Colors.blue,
            ),
            IconButton(
              icon:
                  controller.isDeleting(review.id)
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.delete, size: 18),
              onPressed:
                  controller.isDeleting(review.id)
                      ? null
                      : () => controller.showDeleteConfirmation(review),
              tooltip: 'Delete Review',
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  void _showReviewDetails(ReviewData review) {
    final user = review.user?.user;
    final product = review.product?.product;
    final shopName = product?.shop?.shop?.name ?? '';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.rate_review, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Review Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              _buildDetailRow('User', user?.firstName ?? 'Unknown'),
              _buildDetailRow('Email', user?.email ?? 'No email'),
              if ((user?.phone?.toString().isNotEmpty ?? false))
                _buildDetailRow('Phone', user!.phone.toString()),

              const SizedBox(height: 16),
              _buildDetailRow('Product', product?.name ?? 'Unnamed Product'),
              _buildDetailRow(
                'Price',
                '\$${(product?.price ?? 0).toStringAsFixed(2)}',
              ),
              _buildDetailRow('Shop', shopName),

              const SizedBox(height: 16),
              _buildDetailRow(
                'Rating',
                '${'★' * review.rating}${'☆' * (5 - review.rating)} (${review.rating}/5)',
              ),

              if ((review.description.isNotEmpty ?? false)) ...[
                const SizedBox(height: 16),
                const Text(
                  'Review:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(review.description ?? ''),
                ),
              ],

              const SizedBox(height: 16),
              _buildDetailRow(
                'Created',
                CarsProductReviewController().getFormattedDate(
                  review.createdAt,
                ),
              ),
              if (review.createdAt != review.updatedAt)
                _buildDetailRow(
                  'Updated',
                  CarsProductReviewController().getFormattedDate(
                    review.updatedAt,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
