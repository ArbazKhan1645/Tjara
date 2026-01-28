import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class DisputesHeaderWidget extends StatelessWidget {
  final AdminDisputesService service;
  final bool isUserSpecific;

  const DisputesHeaderWidget({
    super.key,
    required this.service,
    required this.isUserSpecific,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Stats Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isUserSpecific ? 'Customer' : 'All'} Disputes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    service.paginationText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  )),
                ],
              ),
            ),
            
            // Refresh Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: service.refreshDisputes,
                icon: Obx(() => AnimatedRotation(
                  turns: service.isRefreshing.value ? 1 : 0,
                  duration: const Duration(milliseconds: 1000),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                )),
                tooltip: 'Refresh disputes',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Search and Filter Row
        Row(
          children: [
            // Search Bar
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: service.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search disputes by ID, buyer, shop, or status...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: Obx(() => service.searchQuery.value.isNotEmpty
                        ? IconButton(
                            onPressed: service.clearSearch,
                            icon: const Icon(Icons.clear),
                          )
                        : const SizedBox.shrink()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Status Filter
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() => DropdownButton<String>(
                value: service.selectedStatus.value.isEmpty 
                    ? null 
                    : service.selectedStatus.value,
                hint: const Text('Filter by Status'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All Status'),
                  ),
                  ...['pending', 'resolved', 'closed', 'escalated']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.capitalizeFirst!),
                          )),
                ],
                onChanged: (value) => service.setStatusFilter(value ?? ''),
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              )),
            ),
            
            const SizedBox(width: 12),
            
            // Sort Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort disputes',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'created_at:desc',
                    child: Text('Newest First'),
                  ),
                  const PopupMenuItem(
                    value: 'created_at:asc',
                    child: Text('Oldest First'),
                  ),
                  const PopupMenuItem(
                    value: 'id:desc',
                    child: Text('ID (High to Low)'),
                  ),
                  const PopupMenuItem(
                    value: 'id:asc',
                    child: Text('ID (Low to High)'),
                  ),
                ],
                onSelected: (value) {
                  final parts = value.split(':');
                  service.setSorting(parts[0], parts[1]);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}