import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/disputes/disputes_model.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/admin/disputes/view/order_view.dart';
import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class DisputesDataTable extends StatelessWidget {
  final AdminDisputesService service;

  const DisputesDataTable({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          final disputes = service.filteredDisputes;

          return DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF97316)),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 14,
            ),
            dataTextStyle: const TextStyle(color: Colors.black87, fontSize: 13),
            columnSpacing: 20,
            horizontalMargin: 20,
            headingRowHeight: 56,
            dataRowHeight: 64,
            showCheckboxColumn: false,
            border: TableBorder.all(color: Colors.grey.shade200, width: 1),
            columns: const [
              DataColumn(
                label: Text('Dispute ID'),
                tooltip: 'Dispute identification number',
              ),
              DataColumn(label: Text('Order ID'), tooltip: 'Related order ID'),
              DataColumn(
                label: Text('Buyer'),
                tooltip: 'Customer who placed the order',
              ),
              DataColumn(
                label: Text('Shop'),
                tooltip: 'Shop handling the order',
              ),
              DataColumn(
                label: Text('Status'),
                tooltip: 'Current dispute status',
              ),

              DataColumn(
                label: Text('Created'),
                tooltip: 'When dispute was created',
              ),
              DataColumn(label: Text('Updated'), tooltip: 'Last update time'),
              DataColumn(label: Text('Actions'), tooltip: 'Available actions'),
            ],
            rows: disputes.map((dispute) => _buildDataRow(dispute)).toList(),
          );
        }),
      ),
    );
  }

  DataRow _buildDataRow(DisputeData dispute) {
    return DataRow(
      cells: [
        // Dispute ID
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#${dispute.id ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFF97316),
              ),
            ),
          ),
        ),

        // Order ID
        DataCell(
          Text(
            dispute.orderId?.toString() ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        // Buyer
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getBuyerName(dispute),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (dispute.buyer?.user?.email != null)
                Text(
                  dispute.buyer!.user!.email!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),

        // Shop
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dispute.shop?.shop?.name ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (dispute.shop?.shop?.name != null)
                Text(
                  dispute.shop!.shop!.name!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),

        // Status
        DataCell(_buildStatusChip(dispute.status)),

        // Amount

        // Created Date
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDate(dispute.createdAt),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                _formatTime(dispute.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // Updated Date
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDate(dispute.updatedAt),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                _formatTime(dispute.updatedAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editDispute(dispute),
                tooltip: 'Edit dispute',
                color: const Color(0xFF0D9488),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    if (status == null) {
      return const Chip(label: Text('Unknown'), backgroundColor: Colors.grey);
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.pending;
        break;
      case 'resolved':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case 'closed':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        break;
      case 'escalated':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        icon = Icons.trending_up;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.capitalizeFirst!,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getBuyerName(DisputeData dispute) {
    final firstName = dispute.buyer?.user?.firstName ?? '';
    final lastName = dispute.buyer?.user?.lastName ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      return 'Unknown Buyer';
    }

    return '$firstName $lastName'.trim();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  void _viewDispute(DisputeData dispute) {
    Get.toNamed('/dispute-details', arguments: dispute.id);
  }

  void _editDispute(DisputeData dispute) {
    Get.to(
      () =>
          DisputesOrderover(order: dispute.order ?? Order(), dispute: dispute),
    );
  }

  void _handleAction(DisputeData dispute, String action) {
    switch (action) {
      case 'resolve':
        _showResolveDialog(dispute);
        break;
      case 'escalate':
        _showEscalateDialog(dispute);
        break;
      case 'close':
        _showCloseDialog(dispute);
        break;
    }
  }

  void _showResolveDialog(DisputeData dispute) {
    Get.dialog(
      AlertDialog(
        title: const Text('Resolve Dispute'),
        content: Text(
          'Are you sure you want to resolve dispute #${dispute.id}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement resolve dispute API call
              Get.snackbar(
                'Success',
                'Dispute #${dispute.id} has been resolved',
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade800,
              );
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showEscalateDialog(DisputeData dispute) {
    Get.dialog(
      AlertDialog(
        title: const Text('Escalate Dispute'),
        content: Text(
          'Are you sure you want to escalate dispute #${dispute.id}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement escalate dispute API call
              Get.snackbar(
                'Success',
                'Dispute #${dispute.id} has been escalated',
                backgroundColor: Colors.orange.shade100,
                colorText: Colors.orange.shade800,
              );
            },
            child: const Text('Escalate'),
          ),
        ],
      ),
    );
  }

  void _showCloseDialog(DisputeData dispute) {
    Get.dialog(
      AlertDialog(
        title: const Text('Close Dispute'),
        content: Text(
          'Are you sure you want to close dispute #${dispute.id}? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement close dispute API call
              Get.snackbar(
                'Success',
                'Dispute #${dispute.id} has been closed',
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade800,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
