import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';

import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

// Contests Filters Widget
class ContestsFilters extends StatelessWidget {
  final ContestsService contestsService;

  const ContestsFilters({super.key, required this.contestsService});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // Expanded(child: _buildStatusFilter()),
        // // const SizedBox(width: 12),
        // // Expanded(child: _buildCategoryFilter()),
        // const SizedBox(width: 12),
        // Expanded(child: _buildDateRangeFilter()),
        // const SizedBox(width: 12),
        // _buildFilterActions(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Status',
          prefixIcon: Icon(Icons.flag_outlined, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        initialValue: null,
        items:
            [
              'All Status',
              'Active',
              'Upcoming',
              'Ended',
              'Draft',
              'Cancelled',
            ].map((status) {
              return DropdownMenuItem<String>(
                value: status == 'All Status' ? null : status,
                child: Text(status),
              );
            }).toList(),
        onChanged: (value) {
          // Implement status filter
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Category',
          prefixIcon: Icon(Icons.category_outlined, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        initialValue: null,
        items:
            [
              'All Categories',
              'Design',
              'Development',
              'Marketing',
              'Writing',
              'Photography',
              'Video',
              'Other',
            ].map((category) {
              return DropdownMenuItem<String>(
                value: category == 'All Categories' ? null : category,
                child: Text(category),
              );
            }).toList(),
        onChanged: (value) {
          // Implement category filter
        },
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: _showDateRangePicker,
        borderRadius: BorderRadius.circular(12),
        child: const InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date Range',
            prefixIcon: Icon(Icons.date_range_outlined, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text('Select range', style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildFilterActions() {
    return Row(
      children: [
        IconButton(
          onPressed: _resetFilters,
          icon: const Icon(Icons.filter_alt_off),
          tooltip: 'Reset Filters',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // const SizedBox(width: 8),
        // IconButton(
        //   onPressed: _showAdvancedFilters,
        //   icon: const Icon(Icons.tune),
        //   tooltip: 'Advanced Filters',
        //   style: IconButton.styleFrom(
        //     backgroundColor: Colors.blue.shade50,
        //     foregroundColor: Colors.blue,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final dateRange = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (dateRange != null) {
      // Implement date range filter
    }
  }

  void _resetFilters() {
    // Reset all filters
    contestsService.clearSearch();
  }

  void _showAdvancedFilters() {
    Get.bottomSheet(
      _buildAdvancedFiltersSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildAdvancedFiltersSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Add more advanced filter options here
          const Text('Prize Range'),
          // Add prize range slider
          const SizedBox(height: 20),
          const Text('Participant Count'),
          // Add participant count filter
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // Apply advanced filters
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Contests Stats Cards Widget
class ContestsStatsCards extends StatelessWidget {
  final ContestsService contestsService;

  const ContestsStatsCards({super.key, required this.contestsService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Contests',
              value: contestsService.totalItems.toString(),
              icon: Icons.emoji_events_outlined,
              color: Colors.blue,
              trend: '+12%',
              trendUp: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Active Contests',
              value: _getActiveContestsCount().toString(),
              icon: Icons.play_circle_outline,
              color: Colors.green,
              trend: '+5%',
              trendUp: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Total Participants',
              value: _getTotalParticipants().toString(),
              icon: Icons.people_outline,
              color: Colors.orange,
              trend: '+18%',
              trendUp: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Total Prize Pool',
              value: '\${_getTotalPrizePool()}',
              icon: Icons.monetization_on_outlined,
              color: Colors.purple,
              trend: '-3%',
              trendUp: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (trendUp ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trendUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: trendUp ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveContestsCount() {
    return contestsService.contests
        .where((contest) => _isActiveContest(contest))
        .length;
  }

  bool _isActiveContest(ContestModel contest) {
    // Implement logic to check if contest is active
    final now = DateTime.now();

    if (contest.startTime != null && contest.endTime != null) {
      final startDate = DateTime.parse(contest.startTime!);
      final endDate = DateTime.parse(contest.endTime!);
      return now.isAfter(startDate) && now.isBefore(endDate);
    }

    return true;
  }

  int _getTotalParticipants() {
    return 0;
  }

  String _getTotalPrizePool() {
    const total = 0;

    if (total >= 1000000) {
      return '${(total / 1000000).toStringAsFixed(1)}M';
    } else if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}K';
    } else {
      return total.toStringAsFixed(0);
    }
  }
}
