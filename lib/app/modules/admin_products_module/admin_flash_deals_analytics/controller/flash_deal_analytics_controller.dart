import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/model/flash_deal_analytics_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/service/flash_deal_analytics_service.dart';

class FlashDealAnalyticsController extends GetxController {
  final FlashDealAnalyticsService _service = FlashDealAnalyticsService();

  // Time range filter
  final RxString selectedTimeRange = '7'.obs;

  // Analytics state
  final RxBool isLoadingAnalytics = true.obs;
  final Rxn<OverallAnalyticsResponse> analytics =
      Rxn<OverallAnalyticsResponse>();
  final RxString analyticsError = ''.obs;

  // History state
  final RxBool isLoadingHistory = true.obs;
  final RxList<FlashDealHistoryItem> historyItems =
      <FlashDealHistoryItem>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt perPage = 10.obs;
  final RxString historyError = ''.obs;

  // History filters
  final RxString historyStatus = 'all'.obs;
  final Rxn<DateTime> historyStartDate = Rxn<DateTime>();
  final Rxn<DateTime> historyEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
    fetchHistory();
  }

  /// Fetch overall analytics
  Future<void> fetchAnalytics() async {
    isLoadingAnalytics.value = true;
    analyticsError.value = '';
    try {
      final result = await _service.fetchOverallAnalytics(
        selectedTimeRange.value,
      );
      analytics.value = result;
    } catch (e) {
      analyticsError.value = e.toString();
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  /// Fetch history with pagination
  Future<void> fetchHistory({int page = 1}) async {
    isLoadingHistory.value = true;
    historyError.value = '';
    try {
      String? startDate;
      String? endDate;
      if (historyStartDate.value != null) {
        startDate = DateFormat('yyyy-MM-dd').format(historyStartDate.value!);
      }
      if (historyEndDate.value != null) {
        endDate = DateFormat('yyyy-MM-dd').format(historyEndDate.value!);
      }

      final result = await _service.fetchHistory(
        page: page,
        limit: perPage.value,
        startDate: startDate,
        endDate: endDate,
        status: historyStatus.value,
      );

      historyItems.value = result.data;
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      totalItems.value = result.total;
      perPage.value = result.perPage;
    } catch (e) {
      historyError.value = e.toString();
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Change time range and refetch analytics
  void onTimeRangeChanged(String range) {
    if (selectedTimeRange.value == range) return;
    selectedTimeRange.value = range;
    fetchAnalytics();
  }

  /// Load next page
  void loadNextPage() {
    if (currentPage.value < lastPage.value) {
      fetchHistory(page: currentPage.value + 1);
    }
  }

  /// Load previous page
  void loadPreviousPage() {
    if (currentPage.value > 1) {
      fetchHistory(page: currentPage.value - 1);
    }
  }

  /// Apply history filters (resets to page 1)
  void applyHistoryFilters() {
    fetchHistory(page: 1);
  }

  /// Clear history filters
  void clearHistoryFilters() {
    historyStatus.value = 'all';
    historyStartDate.value = null;
    historyEndDate.value = null;
    fetchHistory(page: 1);
  }

  // Formatting helpers
  String formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  String formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// Get pagination info string
  String get paginationInfo {
    if (totalItems.value == 0) return 'No items';
    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end = (currentPage.value * perPage.value).clamp(0, totalItems.value);
    return 'Showing $start-$end of ${totalItems.value}';
  }
}
