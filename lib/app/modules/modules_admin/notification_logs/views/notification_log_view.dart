import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/modules_admin/notification_logs/controller/notification_log_controller.dart';
import 'package:tjara/app/modules/modules_admin/notification_logs/model/notification_log_model.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

class NotificationLogView extends StatelessWidget {
  const NotificationLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationLogController());

    return Scaffold(
      backgroundColor: AdminTheme.bgColor,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          _FiltersSection(controller: controller),
          Expanded(child: _LogListSection(controller: controller)),
          _PaginationBar(controller: controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationLogController controller) {
    return AppBar(
      backgroundColor: AdminTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          const Text(
            'Notification Logs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            if (controller.totalItems.value == 0) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.totalItems.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed:
              () => controller.fetchLogs(page: controller.currentPage.value),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── FILTERS SECTION ───

class _FiltersSection extends StatelessWidget {
  final NotificationLogController controller;
  const _FiltersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Row(
            children: [
              Icon(Icons.filter_list, color: AdminTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  color: AdminTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search fields
                  _filterField(
                    controller.receiverNameCtrl,
                    'Receiver name',
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 8),
                  _filterField(
                    controller.receiverEmailCtrl,
                    'Receiver email',
                    Icons.email_outlined,
                  ),
                  const SizedBox(height: 8),
                  _filterField(
                    controller.receiverPhoneCtrl,
                    'Receiver phone',
                    Icons.phone_outlined,
                  ),
                  const SizedBox(height: 10),
                  // Coupon validity + date range
                  Row(
                    children: [
                      Expanded(child: _validityDropdown()),
                      const SizedBox(width: 8),
                      Expanded(child: _datePicker('From', true)),
                      const SizedBox(width: 8),
                      Expanded(child: _datePicker('To', false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.applyFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AdminTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Apply',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.clearFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminTheme.borderColor),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.clear,
                                  color: AdminTheme.textMuted,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AdminTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField(TextEditingController ctrl, String hint, IconData icon) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AdminTheme.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: AdminTheme.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          filled: true,
          fillColor: AdminTheme.bgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminTheme.primaryColor),
          ),
        ),
        onSubmitted: (_) => controller.applyFilters(),
      ),
    );
  }

  Widget _validityDropdown() {
    return Obx(() {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.couponValidity.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12),
            items: const [
              DropdownMenuItem(value: '', child: Text('All')),
              DropdownMenuItem(value: 'used', child: Text('Used')),
              DropdownMenuItem(value: 'available', child: Text('Available')),
            ],
            onChanged: (value) {
              controller.couponValidity.value = value ?? '';
            },
          ),
        ),
      );
    });
  }

  Widget _datePicker(String label, bool isFrom) {
    return Obx(() {
      final date = isFrom ? controller.dateFrom.value : controller.dateTo.value;
      final displayText =
          date != null ? DateFormat('MMM dd').format(date) : label;

      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: Get.context!,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AdminTheme.primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            if (isFrom) {
              controller.dateFrom.value = picked;
            } else {
              controller.dateTo.value = picked;
            }
          }
        },
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AdminTheme.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminTheme.borderColor),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AdminTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color:
                        date != null
                            ? AdminTheme.textPrimary
                            : AdminTheme.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── LOG LIST SECTION ───

class _LogListSection extends StatelessWidget {
  final NotificationLogController controller;
  const _LogListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmer();
      }

      if (controller.error.value.isNotEmpty) {
        return _buildError();
      }

      if (controller.logs.isEmpty) {
        return _buildEmpty();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.logs.length,
        itemBuilder: (context, index) {
          return _LogCard(item: controller.logs[index], controller: controller);
        },
      );
    });
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AdminShimmer(
              width: double.infinity,
              height: 130,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AdminTheme.errorColor,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Failed to load logs',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.error.value,
              style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: controller.applyFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 48, color: AdminTheme.borderColor),
            SizedBox(height: 12),
            Text(
              'No notification logs found',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: AdminTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SINGLE LOG CARD ───

class _LogCard extends StatelessWidget {
  final NotificationLogItem item;
  final NotificationLogController controller;

  const _LogCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final meta = item.metadata;
    final couponCode = item.couponCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Type + Status + User Name
          Row(
            children: [
              // Status dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      item.status == 'sent'
                          ? AdminTheme.successColor
                          : AdminTheme.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              // Type icon
              Icon(
                _typeIcon(item.type),
                size: 16,
                color: AdminTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminTheme.bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.type.toUpperCase(),
                  style: const TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              // User name
              if (meta?.userName != null)
                Flexible(
                  child: Text(
                    meta!.userName!,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Recipient
          if (item.recipient != null)
            Row(
              children: [
                Text(
                  item.recipient!,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                _statusBadge(item.status),
                const SizedBox(width: 6),
              ],
            ),
          const SizedBox(height: 6),
          // Subject
          if (item.subject != null)
            Text(
              item.subject!,
              style: const TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          // Message
          if (item.message != null) ...[
            const SizedBox(height: 3),
            Text(
              item.message!,
              style: const TextStyle(
                color: AdminTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          // Coupon info
          if (meta?.couponName != null || couponCode?.code != null)
            _buildCouponRow(meta, couponCode),
          const SizedBox(height: 8),
          // Bottom: Date + Event + Status
          Row(
            children: [
              // Date
              const Icon(
                Icons.access_time,
                size: 12,
                color: AdminTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                controller.formatDate(item.sentAt),
                style: const TextStyle(
                  color: AdminTheme.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 12),
              // Event type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminTheme.primarySurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatEventType(item.eventType),
                  style: const TextStyle(
                    color: AdminTheme.primaryColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Status badge

              // Provider
              if (item.provider != null)
                Text(
                  'via ${item.provider}',
                  style: const TextStyle(
                    color: AdminTheme.textMuted,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponRow(
    NotificationMetadata? meta,
    NotificationCouponCode? code,
  ) {
    return Row(
      children: [
        // Coupon name
        if (meta?.couponName != null) ...[
          const Text(
            'Coupon: ',
            style: TextStyle(color: AdminTheme.textMuted, fontSize: 11),
          ),
          Flexible(
            child: Text(
              meta!.couponName!,
              style: const TextStyle(
                color: AdminTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (code?.code != null) ...[
          const SizedBox(width: 10),
          // Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AdminTheme.bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AdminTheme.borderColor),
            ),
            child: Text(
              code!.code!,
              style: const TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Validity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  code.isUsed
                      ? AdminTheme.errorColor.withValues(alpha: 0.1)
                      : AdminTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code.isUsed ? 'Used' : 'Available',
              style: TextStyle(
                color:
                    code.isUsed
                        ? AdminTheme.errorColor
                        : AdminTheme.successColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusBadge(String status) {
    final isSent = status.toLowerCase() == 'sent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isSent ? AdminTheme.successColor : AdminTheme.errorColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSent ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isSent ? AdminTheme.successColor : AdminTheme.errorColor,
          ),
          const SizedBox(width: 3),
          Text(
            isSent ? 'Sent' : 'Failed',
            style: TextStyle(
              color: isSent ? AdminTheme.successColor : AdminTheme.errorColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sms':
        return Icons.sms_outlined;
      case 'email':
        return Icons.email_outlined;
      default:
        return Icons.mail_outline;
    }
  }

  String _formatEventType(String eventType) {
    return eventType.toUpperCase().replaceAll('_', ' ');
  }
}

// ─── PAGINATION BAR ───

class _PaginationBar extends StatelessWidget {
  final NotificationLogController controller;
  const _PaginationBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.totalItems.value == 0 || controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AdminTheme.borderColor, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info text
            Text(
              controller.paginationInfo,
              style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 8),
            // Page numbers
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: controller.lastPage.value,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final page = index + 1;
                  final isSelected = page == controller.currentPage.value;
                  return GestureDetector(
                    onTap: () => controller.goToPage(page),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AdminTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AdminTheme.primaryColor
                                  : AdminTheme.borderColor,
                        ),
                      ),
                      child: Text(
                        '$page',
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : AdminTheme.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
