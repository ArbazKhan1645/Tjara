import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/modules_admin/admin_contexts/insert.dart';
import 'package:tjara/app/modules/modules_admin/admin_contexts/view/shimmer.dart';

import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

class ContestsDataTable extends StatelessWidget {
  final ContestsService contestsService;

  const ContestsDataTable({super.key, required this.contestsService});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 400, maxHeight: 600),
      child: Obx(() {
        if (contestsService.isLoading) {
          return const ContestsShimmer();
        }

        if (contestsService.hasError) {
          return _buildErrorState();
        }

        if (!contestsService.hasData) {
          return _buildEmptyState();
        }

        return _buildDataTable();
      }),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: Theme.of(
          Get.context!,
        ).copyWith(dividerColor: Colors.grey.shade200),
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 20,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          headingTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          dataTextStyle: const TextStyle(fontSize: 13, color: Colors.black87),
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('Image'), numeric: false),
      const DataColumn(label: Text('Contest Title'), numeric: false),
      const DataColumn(label: Text('Prize Amount'), numeric: true),
      const DataColumn(label: Text('Category'), numeric: false),
      const DataColumn(label: Text('Type'), numeric: false),
      const DataColumn(label: Text('Status'), numeric: false),
      const DataColumn(label: Text('Participants'), numeric: true),
      const DataColumn(label: Text('Start Date'), numeric: false),
      const DataColumn(label: Text('End Date'), numeric: false),
      const DataColumn(label: Text('Created'), numeric: false),
      const DataColumn(label: Text('Actions'), numeric: false),
    ];
  }

  List<DataRow> _buildRows() {
    return contestsService.contests.map((contest) {
      return DataRow(
        cells: [
          DataCell(_buildImageCell(contest)),
          DataCell(_buildTitleCell(contest)),
          DataCell(_buildPrizeCell(contest)),
          DataCell(_buildCategoryCell(contest)),
          DataCell(_buildTypeCell(contest)),
          DataCell(_buildStatusCell(contest)),
          DataCell(_buildParticipantsCell(contest)),
          DataCell(_buildDateCell(contest.startTime)),
          DataCell(_buildDateCell(contest.endTime)),
          DataCell(_buildDateCell(contest.createdAt)),
          DataCell(_buildActionsCell(contest)),
        ],
      );
    }).toList();
  }

  Widget _buildImageCell(ContestModel contest) {
    final imageUrl = contest.thumbnail?.media?.url;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 20),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 20,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleCell(ContestModel contest) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            contest.name ?? 'Untitled Contest',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (contest.description != null && contest.description!.isNotEmpty)
            const SizedBox(height: 2),
          if (contest.description != null && contest.description!.isNotEmpty)
            Text(
              contest.description!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildPrizeCell(ContestModel contest) {
    const prize = 0.0;
    return Text(
      _formatCurrency(prize),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: prize > 0 ? Colors.green.shade700 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildCategoryCell(ContestModel contest) {
    const category = 'General';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getCategoryColor(category).withOpacity(0.3)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _getCategoryColor(category),
        ),
      ),
    );
  }

  Widget _buildTypeCell(ContestModel contest) {
    const type = 'Standard';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildStatusCell(ContestModel contest) {
    final status = _getContestStatus(contest);
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCell(ContestModel contest) {
    const participants = 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          participants.toString(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDateCell(String? dateString) {
    if (dateString == null) return const Text('-');

    try {
      final date = DateTime.parse(dateString);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd MMM yyyy').format(date),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            DateFormat('hh:mm a').format(date),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      );
    } catch (e) {
      return const Text('-');
    }
  }

  Widget _buildActionsCell(ContestModel contest) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => _editContest(contest),
          tooltip: 'Edit Contest',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onSelected: (value) => _handleAction(value, contest),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Contests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contestsService.errorMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => contestsService.refreshContests(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Contests Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contestsService.searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Get started by creating your first contest',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (contestsService.searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => contestsService.clearSearch(),
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/admin/contests/add'),
              icon: const Icon(Icons.add),
              label: const Text('Create Contest'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return '-';
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Colors.purple;
      case 'development':
        return Colors.blue;
      case 'marketing':
        return Colors.orange;
      case 'writing':
        return Colors.green;
      case 'photography':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getContestStatus(ContestModel contest) {
    final now = DateTime.now();

    if (contest.startTime != null) {
      final startDate = DateTime.parse(contest.startTime!);
      if (now.isBefore(startDate)) {
        return 'Upcoming';
      }
    }

    if (contest.endTime != null) {
      final endDate = DateTime.parse(contest.endTime!);
      if (now.isAfter(endDate)) {
        return 'Ended';
      }
    }

    return 'Active';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'ended':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _editContest(ContestModel contest) {
    Get.to(() => QuizForm(contestModel: contest, contestId: contest.id))?.then((
      c,
    ) {
      contestsService.refreshContests();
    });
  }

  void _handleAction(String action, ContestModel contest) {
    switch (action) {
      case 'duplicate':
        _duplicateContest(contest);
        break;
      case 'analytics':
        _viewAnalytics(contest);
        break;
      case 'delete':
        _deleteContest(contest);
        break;
    }
  }

  void _duplicateContest(ContestModel contest) {
    Get.dialog(
      AlertDialog(
        title: const Text('Duplicate Contest'),
        content: Text('Are you sure you want to duplicate "${contest.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement duplicate logic
              Get.snackbar(
                'Success',
                'Contest duplicated successfully',
                snackPosition: SnackPosition.TOP,
              );
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _viewAnalytics(ContestModel contest) {
    Get.toNamed('/admin/contests/${contest.id}/analytics');
  }

  void _deleteContest(ContestModel contest) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Contest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${contest.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final String apiUrl =
                  'https://api.libanbuy.com/api/contests/${contest.id}/delete';
              final response = await http.delete(
                Uri.parse(apiUrl),
                headers: {
                  "X-Request-From": "Application",
                  "Content-Type": "application/json",
                },
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                Get.back();
                contestsService.refreshContests();
                // Implement delete logic
                Get.snackbar(
                  'Success',
                  'Contest deleted successfully',
                  snackPosition: SnackPosition.TOP,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete contest',
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
