// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/products_review_model/products_review_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_review/controller.dart';

class ProductReviewScreen extends StatelessWidget {
  const ProductReviewScreen({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductReviewController());
    const _expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: _expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: controller.refreshReviews,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Stats Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Obx(
                              () => Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Reviews',
                                      controller.totalReviews.toString(),
                                      Icons.rate_review,
                                      Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Current Page',
                                      '${controller.currentPage}/${controller.totalPages}',
                                      Icons.pages,
                                      Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
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
                        ),

                        // Reviews List Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Search Input
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: controller.searchController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search reviews by user, product, or content...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                    ),
                                    suffixIcon: Obx(
                                      () =>
                                          controller.searchQuery.isNotEmpty
                                              ? IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.grey[600],
                                                ),
                                                onPressed:
                                                    controller.clearSearch,
                                              )
                                              : const SizedBox.shrink(),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),

                              // Reviews Section Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.rate_review,
                                      color: Colors.grey[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Product Reviews',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Reviews Content
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Obx(() {
                                  if (controller.isLoading &&
                                      !controller.hasData) {
                                    return const SizedBox(
                                      height: 300,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF4CAF50),
                                        ),
                                      ),
                                    );
                                  }

                                  if (controller.hasError &&
                                      !controller.hasData) {
                                    return SizedBox(
                                      height: 300,
                                      child: _buildErrorWidget(controller),
                                    );
                                  }

                                  if (!controller.hasData) {
                                    return SizedBox(
                                      height: 300,
                                      child: _buildEmptyWidget(),
                                    );
                                  }

                                  return _buildReviewsList(controller);
                                }),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Load More button
                        if (controller.hasMoreData || controller.isLoadingMore)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            child:
                                controller.isLoadingMore
                                    ? Container(
                                      padding: const EdgeInsets.all(16),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : ElevatedButton(
                                      onPressed: controller.loadMoreReviews,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.expand_more),
                                          SizedBox(width: 8),
                                          Text(
                                            'Load More',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ProductReviewController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshReviews,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
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
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Reviews Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no reviews to display at the moment.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(ProductReviewController controller) {
    return Column(
      children:
          controller.reviews.map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with user info and rating
                  Row(
                    children: [
                      // User info
                      Expanded(child: _buildUserInfo(review)),
                      // Rating
                      _buildRatingWidget(review, controller),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product info
                  _buildProductInfo(review),

                  // Review content
                  if (review.description.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        review.description ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Footer with date and actions
                  Row(
                    children: [
                      Text(
                        controller.getFormattedDate(review.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (review.createdAt != review.updatedAt) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Updated',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            onPressed: () => _showReviewDetails(review),
                            color: Colors.blue,
                          ),
                          GetBuilder<ProductReviewController>(
                            id: 'delete_${review.id}',
                            builder: (controller) {
                              return IconButton(
                                icon:
                                    controller.isDeleting(review.id)
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.delete, size: 20),
                                onPressed:
                                    controller.isDeleting(review.id)
                                        ? null
                                        : () => controller
                                            .showDeleteConfirmation(review),
                                color: Colors.red,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildUserInfo(ReviewData review) {
    final user = review.user?.user;
    if (user == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          user.email.toString(),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (user.phone?.toString().isNotEmpty ?? false)
          Text(
            user.phone.toString(),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildRatingWidget(
    ReviewData review,
    ProductReviewController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: controller.getRatingColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: controller.getRatingColor().withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            controller.getRatingStars(review.rating),
            style: TextStyle(
              color: controller.getRatingColor(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${review.rating}/5',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ReviewData review) {
    final product = review.product?.product;
    if (product == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '\$${(product.price ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if ((product.shop?.shop?.name ?? '').isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${product.shop?.shop?.name ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(review.description ?? ''),
                ),
              ],

              const SizedBox(height: 16),
              _buildDetailRow(
                'Created',
                ProductReviewController().getFormattedDate(review.createdAt),
              ),
              if (review.createdAt != review.updatedAt)
                _buildDetailRow(
                  'Updated',
                  ProductReviewController().getFormattedDate(review.updatedAt),
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
