import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/controller/admin_bundle_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/model/bundle_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/views/bundle_form_view.dart';

class AdminBundleView extends StatelessWidget {
  const AdminBundleView({super.key});

  static const Color primaryTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00796B);
  static const Color lightTeal = Color(0xFFE0F2F1);
  static const Color accentTeal = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminBundleController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Product Bundles',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _navigateToForm(context, controller),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              ),
              tooltip: 'Create Bundle',
            ),
          ),
        ],
      ),
      body: _buildBody(context, controller),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, controller),
        backgroundColor: primaryTeal,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Bundle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminBundleController controller) {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return _buildShimmerList();
      }

      if (controller.error.value.isNotEmpty && controller.bundles.isEmpty) {
        return _buildErrorState(context, controller);
      }

      if (controller.bundles.isEmpty) {
        return _buildEmptyState(context, controller);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshBundles,
        color: primaryTeal,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.bundles.length,
          itemBuilder: (context, index) {
            final bundle = controller.bundles[index];
            return _buildBundleCard(context, controller, bundle);
          },
        ),
      );
    });
  }

  Widget _buildBundleCard(
    BuildContext context,
    AdminBundleController controller,
    Bundle bundle,
  ) {
    final isActive = bundle.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with thumbnail and info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    image: bundle.thumbnailUrl != null
                        ? DecorationImage(
                            image: NetworkImage(bundle.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: bundle.thumbnailUrl == null
                      ? Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey.shade400,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bundle.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(isActive),
                        ],
                      ),
                      if (bundle.description != null &&
                          bundle.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          bundle.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Info chips row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildInfoChip(
                            icon: Icons.inventory_2_outlined,
                            label: '${bundle.productCount} products',
                          ),
                          if (bundle.discountDisplay.isNotEmpty)
                            _buildDiscountChip(bundle.discountDisplay),
                          if (bundle.startDate != null)
                            _buildInfoChip(
                              icon: Icons.calendar_today_outlined,
                              label: controller.formatDate(bundle.createdAt),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey.shade100),
          // Actions row
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    color: primaryTeal,
                    onTap: () => _showBundleDetails(context, bundle),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: Colors.blue.shade600,
                    onTap: () => _navigateToEdit(context, controller, bundle),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy URL',
                    color: Colors.purple.shade600,
                    onTap: () => controller.copyBundleUrl(context, bundle),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: Colors.orange.shade600,
                    onTap: () => controller.shareBundleUrl(bundle),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => _buildActionButton(
                        icon: Icons.content_copy_outlined,
                        label: 'Duplicate',
                        color: Colors.teal.shade600,
                        isLoading: controller.isDuplicating(bundle.id),
                        onTap: () =>
                            controller.duplicateBundle(context, bundle.id),
                      )),
                  const SizedBox(width: 8),
                  Obx(() => _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: Colors.red.shade600,
                        isLoading: controller.isDeleting(bundle.id),
                        onTap: () =>
                            _showDeleteConfirmation(context, controller, bundle),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5E9) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4CAF50) : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF2E7D32) : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountChip(String discount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        discount,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AdminBundleController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: lightTeal,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: primaryTeal.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Bundles Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first product bundle',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Create Bundle',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AdminBundleController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            controller.error.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.fetchBundles,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, AdminBundleController controller) {
    controller.clearForm();
    controller.loadInitialProducts();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BundleFormView(controller: controller),
      ),
    );
  }

  void _navigateToEdit(
    BuildContext context,
    AdminBundleController controller,
    Bundle bundle,
  ) {
    controller.clearForm();
    controller.setEditingBundleBasicInfo(bundle);
    controller.setSelectedProductIds(bundle);
    controller.loadInitialProducts();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BundleFormView(controller: controller),
      ),
    );
  }

  void _showBundleDetails(BuildContext context, Bundle bundle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (bundle.thumbnailUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        bundle.thumbnailUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    bundle.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (bundle.description != null) ...[
                    Text(
                      bundle.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDetailChip(
                        'Status',
                        bundle.status.toUpperCase(),
                        bundle.isActive ? Colors.green : Colors.red,
                      ),
                      _buildDetailChip(
                        'Products',
                        '${bundle.productCount}',
                        primaryTeal,
                      ),
                      if (bundle.discountDisplay.isNotEmpty)
                        _buildDetailChip(
                          'Discount',
                          bundle.discountDisplay,
                          Colors.green,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bundle URL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            bundle.bundleUrl,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            final controller = Get.find<AdminBundleController>();
                            controller.copyBundleUrl(context, bundle);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AdminBundleController controller,
    Bundle bundle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade600,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Bundle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${bundle.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteBundle(context, bundle.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
