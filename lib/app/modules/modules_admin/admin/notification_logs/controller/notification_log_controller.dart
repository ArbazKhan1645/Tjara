import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/modules_admin/admin/notification_logs/model/notification_log_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/notification_logs/service/notification_log_service.dart';

class NotificationLogController extends GetxController {
  final NotificationLogService _service = NotificationLogService();

  // Loading & error
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // Data
  final RxList<NotificationLogItem> logs = <NotificationLogItem>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt perPage = 10.obs;

  // Filters
  final TextEditingController receiverNameCtrl = TextEditingController();
  final TextEditingController receiverEmailCtrl = TextEditingController();
  final TextEditingController receiverPhoneCtrl = TextEditingController();
  final RxString couponValidity = ''.obs; // '', 'used', 'available'
  final Rxn<DateTime> dateFrom = Rxn<DateTime>();
  final Rxn<DateTime> dateTo = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  @override
  void onClose() {
    receiverNameCtrl.dispose();
    receiverEmailCtrl.dispose();
    receiverPhoneCtrl.dispose();
    super.onClose();
  }

  /// Fetch logs from API
  Future<void> fetchLogs({int page = 1}) async {
    isLoading.value = true;
    error.value = '';
    try {
      String? dateFromStr;
      String? dateToStr;
      if (dateFrom.value != null) {
        dateFromStr = DateFormat('yyyy-MM-dd').format(dateFrom.value!);
      }
      if (dateTo.value != null) {
        dateToStr = DateFormat('yyyy-MM-dd').format(dateTo.value!);
      }

      final result = await _service.fetchLogs(
        page: page,
        perPage: perPage.value,
        receiverName: receiverNameCtrl.text.trim(),
        receiverEmail: receiverEmailCtrl.text.trim(),
        receiverPhone: receiverPhoneCtrl.text.trim(),
        couponCodeValidity: couponValidity.value,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      logs.value = result.data;
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      totalItems.value = result.total;
      perPage.value = result.perPage;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to a specific page
  void goToPage(int page) {
    if (page < 1 || page > lastPage.value || page == currentPage.value) return;
    fetchLogs(page: page);
  }

  /// Apply current filters and reset to page 1
  void applyFilters() {
    fetchLogs(page: 1);
  }

  /// Clear all filters and refetch
  void clearFilters() {
    receiverNameCtrl.clear();
    receiverEmailCtrl.clear();
    receiverPhoneCtrl.clear();
    couponValidity.value = '';
    dateFrom.value = null;
    dateTo.value = null;
    fetchLogs(page: 1);
  }

  /// Format ISO date to readable string
  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('d MMM yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// Pagination info string
  String get paginationInfo {
    if (totalItems.value == 0) return 'No items';
    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end =
        (currentPage.value * perPage.value).clamp(0, totalItems.value);
    return 'Showing $start-$end of ${totalItems.value}';
  }
}
