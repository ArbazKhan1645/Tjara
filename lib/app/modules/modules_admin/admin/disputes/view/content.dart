import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/datatable.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/pagination.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/shimmer.dart';

import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class DisputesContentWidget extends StatelessWidget {
  final AdminDisputesService service;

  const DisputesContentWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Content Area
          Obx(() {
            if (service.isLoading.value) {
              return const DisputesShimmerLoading();
            }

            if (service.hasError.value) {
              return DisputesErrorState(
                message: service.errorMessage.value,
                onRetry: () => service.loadDisputes(userId: Get.arguments),
              );
            }

            if (!service.hasFilteredData) {
              return DisputesEmptyState(
                hasSearchQuery: service.searchQuery.value.isNotEmpty,
                onClearSearch: service.clearSearch,
              );
            }

            return DisputesDataTable(service: service);
          }),

          // Pagination
          Obx(() {
            if (service.isLoading.value || !service.hasData) {
              return const SizedBox.shrink();
            }

            return DisputesPaginationWidget(service: service);
          }),
        ],
      ),
    );
  }
}

class DisputesEmptyState extends StatelessWidget {
  final bool hasSearchQuery;
  final VoidCallback? onClearSearch;

  const DisputesEmptyState({
    super.key,
    required this.hasSearchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              hasSearchQuery ? Icons.search_off : Icons.gavel,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            hasSearchQuery ? 'No matching disputes found' : 'No disputes yet',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            hasSearchQuery
                ? 'Try adjusting your search terms or filters to find what you\'re looking for.'
                : 'When customers raise disputes about their orders, they will appear here for resolution.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Action Button
          if (hasSearchQuery && onClearSearch != null)
            ElevatedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Disputes will automatically appear here when customers need assistance with their orders.',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 14,
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
}

class DisputesErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DisputesErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
          ),

          const SizedBox(height: 24),

          // Error Title
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Error Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade800,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Retry Button
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

          const SizedBox(height: 16),

          // Help Text
          Text(
            'If the problem persists, please contact technical support.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
