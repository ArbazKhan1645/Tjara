import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/modules_admin/users/view/users_card.dart';
import 'package:tjara/app/services/dashbopard_services/users_service.dart';

class UsersContextsList extends StatelessWidget {
  final AdminUsersService adminProductsService;

  const UsersContextsList({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          children: [
            _buildContent(),
            if (adminProductsService.hasData) _buildPagination(),
          ],
        ),
      );
    });
  }

  Widget _buildContent() {
    if (adminProductsService.isLoading) {
      return _buildShimmerLoading();
    }

    if (adminProductsService.hasError) {
      return _buildErrorState();
    }

    if (adminProductsService.isEmpty) {
      return _buildEmptyState();
    }

    return _buildUsersList();
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Content placeholders
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 18,
                            width: double.infinity,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 200,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                height: 12,
                                width: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(width: 16),
                              Container(
                                height: 12,
                                width: 60,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status placeholder
                    Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            adminProductsService.errorMessage.value.contains('404')
                ? 'No User Found Of Search filter'
                : 'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            adminProductsService.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => adminProductsService.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Search Another Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = adminProductsService.searchQuery.value.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No users found' : 'No users yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try adjusting your search terms or filters'
                : 'Add your first user to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          if (isSearching)
            TextButton.icon(
              onPressed: adminProductsService.clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE53E3E),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add user page
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Column(
      children: [
        // Results summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${adminProductsService.filteredProducts.length} of ${adminProductsService.totalItems.value} users',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (adminProductsService.searchQuery.value.isNotEmpty)
              Chip(
                label: Text(
                  '${adminProductsService.filteredProducts.length} results',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200),
              ),
          ],
        ),

        // Users list
        ListView.separated(
          padding: const EdgeInsets.only(top: 5),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: adminProductsService.filteredProducts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = adminProductsService.filteredProducts[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutBack,
              child: UsersItemCard(
                product: user,
                onDelete: () => _showDeleteDialog(user),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      if (adminProductsService.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            _buildPaginationButton(
              icon: Icons.chevron_left,
              label: 'Previous',
              onPressed:
                  adminProductsService.canGoPrevious
                      ? adminProductsService.previousPage
                      : null,
            ),

            // Page numbers
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...adminProductsService.visiblePageNumbers().map((page) {
                    final isCurrentPage =
                        page == adminProductsService.currentPage.value;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => adminProductsService.goToPage(page),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isCurrentPage
                                    ? const Color(0xFF0D9488)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isCurrentPage
                                      ? const Color(0xFF0D9488)
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            page.toString(),
                            style: TextStyle(
                              color:
                                  isCurrentPage
                                      ? Colors.white
                                      : Colors.grey[700],
                              fontWeight:
                                  isCurrentPage
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Next button
            _buildPaginationButton(
              icon: Icons.chevron_right,
              label: 'Next',
              onPressed:
                  adminProductsService.canGoNext
                      ? adminProductsService.nextPage
                      : null,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isEnabled ? Colors.white : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.chevron_left) ...[
              Icon(
                icon,
                size: 16,
                color: isEnabled ? Colors.grey[700] : Colors.grey[400],
              ),
              const SizedBox(width: 4),
            ],

            if (icon == Icons.chevron_right) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 16,
                color: isEnabled ? Colors.grey[700] : Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(dynamic user) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this user?',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed:
                  adminProductsService.isDeleting.value
                      ? null
                      : () async {
                        final success = await adminProductsService.deleteUser(
                          user.id,
                        );
                        if (success) {
                          Get.back();
                          Get.snackbar(
                            'Success',
                            'User deleted successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  adminProductsService.isDeleting.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
