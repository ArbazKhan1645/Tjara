import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

import 'package:tjara/app/models/popups/popups-model.dart';
import 'package:tjara/app/modules/modules_admin/popups/popup_analytics.dart';
import 'package:tjara/main.dart';

// Updated Popup Controller
class PopupController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable variables
  var isLoading = false.obs;
  var popups = <Data>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var selectedType = ''.obs;
  var selectedStatus = ''.obs;
  var searchQuery = ''.obs;

  // Controllers
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  // Filter options
  final typeOptions = [
    {'value': '', 'label': 'All Types'},
    {'value': 'banner_popup', 'label': 'Banner Popup'},
    {'value': 'feature_product_popup', 'label': 'Feature Product'},
  ];

  final statusOptions = [
    {'value': '', 'label': 'All Status'},
    {'value': 'active', 'label': 'Active'},
    {'value': 'inactive', 'label': 'Inactive'},
  ];

  List<Data> get filteredPopups {
    var filtered = popups.toList();

    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((popup) {
            final query = searchQuery.toLowerCase();
            // Search by name
            final matchesName =
                popup.name?.toLowerCase().contains(query) ?? false;
            // Search by ID
            final matchesId = popup.id?.toLowerCase().contains(query) ?? false;

            return matchesName || matchesId;
          }).toList();
    }

    if (selectedType.isNotEmpty) {
      filtered =
          filtered.where((popup) => popup.type == selectedType.value).toList();
    }

    if (selectedStatus.isNotEmpty) {
      final isActive = selectedStatus.value == 'active';
      filtered = filtered.where((popup) => popup.isActive == isActive).toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    fetchPopups();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchPopups({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      isLoading.value = true;

      final response = await _apiService.get('/popups');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final popupModel = PopUpModels.fromJson(data);

        if (isRefresh || currentPage.value == 1) {
          popups.clear();
        }

        if (popupModel.popups?.data != null) {
          popups.addAll(popupModel.popups!.data!);
          totalPages.value = popupModel.popups!.lastPage ?? 1;
          hasMoreData.value = currentPage.value < totalPages.value;
        }
      } else {
        _handleError('Failed to fetch popups');
      }
    } catch (e) {
      _handleError('Error fetching popups: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void onTypeFilterChanged(String? value) {
    selectedType.value = value ?? '';
  }

  void onStatusFilterChanged(String? value) {
    selectedStatus.value = value ?? '';
  }

  Future<void> deletePopup(String id) async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this popup?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await _performDelete(id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      _handleError('Error deleting popup: ${e.toString()}');
    }
  }

  Future<void> _performDelete(String id) async {
    try {
      isLoading.value = true;

      final response = await _apiService.delete('/popups/$id/delete');

      if (response.statusCode == 200) {
        popups.removeWhere((popup) => popup.id == id);
        Get.snackbar(
          'Success',
          'Popup deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _handleError('Failed to delete popup');
      }
    } catch (e) {
      _handleError('Error deleting popup: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> togglePopupStatus(String id, bool currentStatus) async {
    try {
      isLoading.value = true;

      final response = await _apiService.put(
        '/popups/$id/update',
        data: {'is_active': !currentStatus},
      );

      if (response.statusCode == 200) {
        final index = popups.indexWhere((popup) => popup.id == id);
        if (index != -1) {
          popups[index].isActive = !currentStatus;
          popups.refresh();
        }

        Get.snackbar(
          'Success',
          'Popup status updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _handleError('Failed to update popup status');
      }
    } catch (e) {
      _handleError('Error updating popup status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void refreshData() {
    fetchPopups(isRefresh: true);
  }
}

// Popup List View - Card-based mobile design
class PopupListView extends GetView<PopupController> {
  const PopupListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => PopupAnalyticsView()),
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            tooltip: 'Analytics',
          ),
          const AdminAppBarActionsSimple(),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Popup Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Get.to(
              () => AddPopupView(),
            )?.then((_) => controller.refreshData()),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Popup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 12),
            Expanded(child: _buildPopupList()),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search popups...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
          Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? InkWell(
                      onTap: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: [
            _buildFilterChip(
              label:
                  controller.selectedType.value.isEmpty
                      ? 'All Types'
                      : controller.typeOptions.firstWhere(
                        (o) => o['value'] == controller.selectedType.value,
                        orElse: () => {'label': 'All Types'},
                      )['label']!,
              isActive: controller.selectedType.value.isNotEmpty,
              onTap: () => _showTypeFilterSheet(),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label:
                  controller.selectedStatus.value.isEmpty
                      ? 'All Status'
                      : controller.selectedStatus.value == 'active'
                      ? 'Active'
                      : 'Inactive',
              isActive: controller.selectedStatus.value.isNotEmpty,
              onTap: () => _showStatusFilterSheet(),
            ),
            if (controller.selectedType.value.isNotEmpty ||
                controller.selectedStatus.value.isNotEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  controller.selectedType.value = '';
                  controller.selectedStatus.value = '';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear_all, size: 14, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.teal : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.teal : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? Colors.teal : Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        );
      }

      final popups = controller.filteredPopups;

      if (popups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No popups found',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first popup to get started',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: Colors.teal,
        onRefresh: () => controller.fetchPopups(isRefresh: true),
        child: ListView.builder(
          controller: controller.scrollController,
          itemCount: popups.length,
          itemBuilder: (context, index) {
            final popup = popups[index];
            if (popup.isAbTest == true) {
              return _buildAbTestCard(popup);
            }
            return _buildPopupCard(popup);
          },
        ),
      );
    });
  }

  Widget _buildPopupCard(Data popup) {
    final now = DateTime.now();
    DateTime? endTime;
    DateTime? startTime;
    if (popup.endTime != null) endTime = DateTime.tryParse(popup.endTime!);
    if (popup.startTime != null)
      startTime = DateTime.tryParse(popup.startTime!);
    final isExpired = endTime != null && now.isAfter(endTime);
    final isActive = popup.isActive == true && !isExpired;

    final statusColor =
        isExpired
            ? const Color(0xFFEF4444)
            : (isActive ? const Color(0xFF10B981) : Colors.grey);
    final statusText =
        isExpired ? 'Expired' : (isActive ? 'Active' : 'Inactive');
    final statusIcon =
        isExpired
            ? Icons.timer_off_outlined
            : (isActive
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline);

    final int views = popup.views ?? 0;
    final int clicks = popup.clicks ?? 0;
    final double ctr = views > 0 ? (clicks / views) * 100 : 0;

    final String typeLabel = _getTypeLabel(popup.type);
    final imageUrl = popup.thumbnail?.media?.url;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Thumbnail + Name + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child:
                      imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.image_not_supported,
                                    size: 22,
                                    color: Colors.grey[400],
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.campaign_outlined,
                            size: 22,
                            color: Colors.grey[400],
                          ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        popup.name ?? 'Unnamed',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'ID: ${popup.popupId ?? '-'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (popup.userSegment != null) ...[
                            Text(
                              '  \u2022  ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              _getSegmentLabel(popup.userSegment!),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Info chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildInfoChip(
                  Icons.widgets_outlined,
                  typeLabel,
                  color: Colors.teal,
                ),
                if (popup.pageLocation != null &&
                    popup.pageLocation!.isNotEmpty)
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    popup.pageLocation!,
                  ),
                if (startTime != null && endTime != null)
                  _buildInfoChip(
                    Icons.calendar_today_outlined,
                    '${_formatShortDate(startTime)} - ${_formatShortDate(endTime)}',
                  ),
                if (isExpired && endTime != null)
                  _buildInfoChip(
                    Icons.timer_off_outlined,
                    'Ended ${_timeAgo(endTime)}',
                    color: const Color(0xFFEF4444),
                  )
                else if (!isExpired && endTime != null)
                  _buildInfoChip(
                    Icons.schedule,
                    '${endTime.difference(now).inDays}d left',
                    color: const Color(0xFF10B981),
                  ),
              ],
            ),

            // Row 3: Categories
            if (popup.categoryNames != null &&
                popup.categoryNames!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...popup.categoryNames!.take(3).map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.teal.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.teal,
                        ),
                      ),
                    );
                  }),
                  if (popup.categoryNames!.length > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${popup.categoryNames!.length - 3} more',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ],

            // Row 4: Analytics
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  _buildAnalyticItem(
                    'Views',
                    views.toString(),
                    Icons.visibility_outlined,
                  ),
                  _buildAnalyticDivider(),
                  _buildAnalyticItem(
                    'Clicks',
                    clicks.toString(),
                    Icons.touch_app_outlined,
                  ),
                  _buildAnalyticDivider(),
                  _buildAnalyticItem(
                    'CTR',
                    '${ctr.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    highlight: ctr > 2,
                  ),
                  if (popup.conversions != null && popup.conversions! > 0) ...[
                    _buildAnalyticDivider(),
                    _buildAnalyticItem(
                      'Conv.',
                      popup.conversions.toString(),
                      Icons.shopping_cart_outlined,
                    ),
                  ],
                ],
              ),
            ),

            // Row 5: Actions
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Get.to(
                      () => AddPopupView(),
                      arguments: {'popup': popup},
                    )?.then((_) {
                      controller.refreshData();
                    });
                  },
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => controller.deletePopup(popup.id!),
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: BorderSide(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbTestCard(Data popup) {
    final now = DateTime.now();
    DateTime? endTime;
    if (popup.endTime != null) endTime = DateTime.tryParse(popup.endTime!);
    final isExpired = endTime != null && now.isAfter(endTime);
    final statusColor =
        isExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final statusText = isExpired ? 'Expired' : 'Active';

    final int totalViews =
        (popup.abVariantAViews ?? 0) + (popup.abVariantBViews ?? 0);
    final int totalClicks =
        (popup.abVariantAClicks ?? 0) + (popup.abVariantBClicks ?? 0);
    final double totalCtr =
        totalViews > 0 ? (totalClicks / totalViews) * 100 : 0;

    final imageUrl = popup.thumbnail?.media?.url;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // A/B Test header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 16,
                  color: Colors.purple[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A/B Testing: ${popup.name ?? 'Unnamed'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Combined analytics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple[50]?.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Views: $totalViews',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Clicks: $totalClicks',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'CTR: ${totalCtr.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (popup.abTestMethod != null)
                  Text(
                    'Method: ${popup.abTestMethod}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),

          // Variant A
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _buildVariantRow(
              label: 'Variant A',
              color: Colors.blue,
              imageUrl: imageUrl,
              views: popup.abVariantAViews ?? 0,
              clicks: popup.abVariantAClicks ?? 0,
              conversions: popup.abVariantAConversions ?? 0,
              isWinner: popup.abTestWinner == 'variant_a',
            ),
          ),

          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 14,
            endIndent: 14,
          ),

          // Variant B
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _buildVariantRow(
              label: 'Variant B',
              color: Colors.orange,
              imageUrl: popup.variantBThumbnail?.media?.url,
              views: popup.abVariantBViews ?? 0,
              clicks: popup.abVariantBClicks ?? 0,
              conversions: popup.abVariantBConversions ?? 0,
              isWinner: popup.abTestWinner == 'variant_b',
            ),
          ),

          // Categories
          if (popup.categoryNames != null && popup.categoryNames!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    popup.categoryNames!.take(3).map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.teal.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.teal,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Get.to(
                      () => AddPopupView(),
                      arguments: {'popup': popup},
                    )?.then((_) {
                      controller.refreshData();
                    });
                  },
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => controller.deletePopup(popup.id!),
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: BorderSide(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildVariantRow({
    required String label,
    required Color color,
    String? imageUrl,
    required int views,
    required int clicks,
    required int conversions,
    required bool isWinner,
  }) {
    final double ctr = views > 0 ? (clicks / views) * 100 : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child:
                imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Icon(
                              Icons.image,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                      ),
                    )
                    : Icon(Icons.image, size: 18, color: Colors.grey[400]),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isWinner) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: Colors.amber[700],
                    ),
                    Text(
                      ' Winner',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'CTR: ${ctr.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildMiniStat('$views', 'views'),
              const SizedBox(width: 12),
              _buildMiniStat('$clicks', 'clicks'),
              const SizedBox(width: 12),
              _buildMiniStat('$conversions', 'conv.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    final chipColor = color ?? Colors.grey[600]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticItem(
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? Colors.teal : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: highlight ? Colors.teal : Colors.grey[800],
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildAnalyticDivider() {
    return Container(width: 1, height: 30, color: Colors.grey[200]);
  }

  Widget _buildPaginationControls() {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed:
                  controller.currentPage.value > 1
                      ? () {
                        controller.currentPage.value--;
                        controller.fetchPopups();
                      }
                      : null,
              icon: const Icon(Icons.chevron_left),
              color: Colors.teal,
              disabledColor: Colors.grey[300],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.currentPage.value} / ${controller.totalPages.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  controller.currentPage.value < controller.totalPages.value
                      ? () {
                        controller.currentPage.value++;
                        controller.fetchPopups();
                      }
                      : null,
              icon: const Icon(Icons.chevron_right),
              color: Colors.teal,
              disabledColor: Colors.grey[300],
            ),
          ],
        ),
      );
    });
  }

  void _showTypeFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter by Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...controller.typeOptions.map((option) {
              final isSelected =
                  controller.selectedType.value == option['value'];
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? Colors.teal : Colors.grey[400],
                  size: 20,
                ),
                title: Text(
                  option['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.teal : Colors.grey[700],
                  ),
                ),
                onTap: () {
                  controller.onTypeFilterChanged(option['value'] as String);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter by Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...controller.statusOptions.map((option) {
              final isSelected =
                  controller.selectedStatus.value == option['value'];
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? Colors.teal : Colors.grey[400],
                  size: 20,
                ),
                title: Text(
                  option['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.teal : Colors.grey[700],
                  ),
                ),
                onTap: () {
                  controller.onStatusFilterChanged(option['value'] as String);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'banner_popup':
        return 'Banner';
      case 'lead_generation_popup':
        return 'Lead Gen';
      case 'feature_product_popup':
        return 'Product';
      default:
        return type ?? 'Unknown';
    }
  }

  String _getSegmentLabel(String segment) {
    switch (segment) {
      case 'all':
        return 'All Users';
      case 'pre_registration':
        return 'Pre-Reg';
      case 'post_registration':
        return 'Post-Reg';
      default:
        return segment;
    }
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year.toString().substring(2)}';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// Complete Add Popup Controller with ALL fields
class AddPopupController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var isEditMode = false.obs;
  var popupId = ''.obs;

  // Image handling
  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<File?>(null);
  var existingImageUrl = ''.obs;

  // Form controllers - ALL fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkUrlController = TextEditingController();
  final pageLocationController = TextEditingController();
  final displayDelayController = TextEditingController();
  final productIdController = TextEditingController();
  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();
  final variantBLinkUrlController = TextEditingController();

  // Form data - ALL observables
  var selectedType = 'banner_popup'.obs;
  var selectedUserSegment = 'all'.obs;
  var selectedLinkType = 'url'.obs;
  var selectedVariantBLinkType = 'url'.obs;
  var isActive = true.obs;
  var showOncePerSession = false.obs;
  var isAbTest = false.obs;
  var abTestAutoSelectWinner = false.obs;
  var abTestCompleted = false.obs;
  var selectedThumbnailId = ''.obs;
  var selectedVariantBThumbnailId = ''.obs;
  var startTime = Rx<DateTime?>(null);
  var endTime = Rx<DateTime?>(null);
  var abTestStartTime = Rx<DateTime?>(null);
  var abTestEndTime = Rx<DateTime?>(null);

  // Date time validation error messages
  var startTimeError = RxnString();
  var endTimeError = RxnString();
  var abTestStartTimeError = RxnString();
  var abTestEndTimeError = RxnString();

  final formKey = GlobalKey<FormState>();

  // ALL options lists
  final typeOptions = [
    {'value': 'banner_popup', 'label': 'Banner Popup'},

    {'value': 'feature_product_popup', 'label': 'Feature Product'},
  ];

  final userSegmentOptions = [
    {'value': 'all', 'label': 'All Users'},
    {'value': 'pre_registration', 'label': 'Pre Registration'},
    {'value': 'post_registration', 'label': 'Post Registration'},
  ];

  final linkTypeOptions = [
    {'value': 'url', 'label': 'Custom URL'},
    {'value': 'popup', 'label': 'Link to Popup'},
  ];

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments['popup'] != null) {
      isEditMode.value = true;
      _loadPopupData(arguments['popup']);
    }
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    nameController.dispose();
    descriptionController.dispose();
    linkUrlController.dispose();
    pageLocationController.dispose();
    displayDelayController.dispose();
    productIdController.dispose();
    productNameController.dispose();
    productPriceController.dispose();
    variantBLinkUrlController.dispose();
  }

  void _loadPopupData(dynamic popup) {
    popupId.value = popup.id ?? '';
    nameController.text = popup.name ?? '';
    descriptionController.text = popup.description ?? '';
    linkUrlController.text = popup.linkUrl ?? '';
    pageLocationController.text = popup.pageLocation ?? '';
    displayDelayController.text = popup.displayDelay?.toString() ?? '';
    productIdController.text = popup.productId ?? '';
    productNameController.text = popup.productName ?? '';
    productPriceController.text = popup.productPrice ?? '';
    variantBLinkUrlController.text = popup.variantBLinkUrl ?? '';

    selectedType.value = popup.type ?? 'banner_popup';
    selectedUserSegment.value = popup.userSegment ?? 'all';
    selectedLinkType.value = popup.linkType ?? 'url';
    selectedVariantBLinkType.value = popup.variantBLinkType ?? 'url';
    isActive.value = popup.isActive ?? true;
    showOncePerSession.value = popup.showOncePerSession ?? false;
    isAbTest.value = popup.isAbTest ?? false;
    abTestAutoSelectWinner.value = popup.abTestAutoSelectWinner ?? false;
    abTestCompleted.value = popup.abTestCompleted ?? false;
    selectedThumbnailId.value = popup.thumbnailId ?? '';
    selectedVariantBThumbnailId.value = popup.variantBThumbnailId ?? '';

    // Load existing image URL
    if (popup.thumbnail?.media?.url != null) {
      existingImageUrl.value = popup.thumbnail!.media!.url!;
    }

    // Parse dates
    if (popup.startTime != null) {
      startTime.value = DateTime.tryParse(popup.startTime!);
    }
    if (popup.endTime != null) {
      endTime.value = DateTime.tryParse(popup.endTime!);
    }
    if (popup.abTestStartTime != null) {
      abTestStartTime.value = DateTime.tryParse(
        popup.abTestStartTime.toString(),
      );
    }
    if (popup.abTestEndTime != null) {
      abTestEndTime.value = DateTime.tryParse(popup.abTestEndTime.toString());
    }
  }

  bool _validateDateTimes() {
    bool isValid = true;

    // Clear previous errors
    startTimeError.value = null;
    endTimeError.value = null;
    abTestStartTimeError.value = null;
    abTestEndTimeError.value = null;

    // Validate start time
    if (startTime.value == null) {
      startTimeError.value = 'Start time is required';
      isValid = false;
    }

    // Validate end time
    if (endTime.value == null) {
      endTimeError.value = 'End time is required';
      isValid = false;
    }

    // End time must be after start time
    if (startTime.value != null &&
        endTime.value != null &&
        !endTime.value!.isAfter(startTime.value!)) {
      endTimeError.value = 'End time must be after start time';
      isValid = false;
    }

    // A/B test date validations
    if (isAbTest.value) {
      if (abTestStartTime.value == null) {
        abTestStartTimeError.value = 'Test start time is required';
        isValid = false;
      }
      if (abTestEndTime.value == null) {
        abTestEndTimeError.value = 'Test end time is required';
        isValid = false;
      }
      if (abTestStartTime.value != null &&
          abTestEndTime.value != null &&
          !abTestEndTime.value!.isAfter(abTestStartTime.value!)) {
        abTestEndTimeError.value = 'Test end time must be after start time';
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> savePopup() async {
    final formValid = formKey.currentState!.validate();
    final datesValid = _validateDateTimes();

    if (!formValid || !datesValid) {
      return;
    }

    try {
      isLoading.value = true;

      // Upload image first if a new image is selected
      if (selectedImage.value != null) {
        final thumbnailId = await uploadMedia([selectedImage.value!]);
        selectedThumbnailId.value = thumbnailId;
      }

      final data = _buildFormData();

      final response =
          isEditMode.value
              ? await _apiService.put(
                '/popups/${popupId.value}/update',
                data: data,
              )
              : await _apiService.post('/popups/insert', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          isEditMode.value
              ? 'Popup updated successfully'
              : 'Popup created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _handleError(
          'Failed to ${isEditMode.value ? 'update' : 'create'} popup',
        );
      }
    } catch (e) {
      _handleError(
        'Error ${isEditMode.value ? 'updating' : 'creating'} popup: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildFormData() {
    final data = <String, dynamic>{
      'name': nameController.text.trim(),
      'description':
          descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
      'type': selectedType.value,
      'page_location': pageLocationController.text.trim(),
      'link_url':
          linkUrlController.text.trim().isEmpty
              ? null
              : linkUrlController.text.trim(),
      'is_active': isActive.value,
      'show_once_per_session': showOncePerSession.value,
      'user_segment': selectedUserSegment.value,
      'link_type': selectedLinkType.value,
      'is_ab_test': isAbTest.value,
      'ab_test_auto_select_winner': abTestAutoSelectWinner.value,
      'ab_test_completed': abTestCompleted.value,
    };

    // Add optional fields
    if (selectedThumbnailId.value.isNotEmpty) {
      data['thumbnail_id'] = selectedThumbnailId.value;
    }

    if (displayDelayController.text.isNotEmpty) {
      data['display_delay'] = int.tryParse(displayDelayController.text) ?? 0;
    }

    if (startTime.value != null) {
      data['start_time'] = startTime.value!.toIso8601String();
    }

    if (endTime.value != null) {
      data['end_time'] = endTime.value!.toIso8601String();
    }

    // A/B Testing specific fields
    if (isAbTest.value) {
      if (selectedVariantBThumbnailId.value.isNotEmpty) {
        data['variant_b_thumbnail_id'] = selectedVariantBThumbnailId.value;
      }

      if (variantBLinkUrlController.text.isNotEmpty) {
        data['variant_b_link_url'] = variantBLinkUrlController.text.trim();
      }

      data['variant_b_link_type'] = selectedVariantBLinkType.value;

      if (abTestStartTime.value != null) {
        data['ab_test_start_time'] = abTestStartTime.value!.toIso8601String();
      }

      if (abTestEndTime.value != null) {
        data['ab_test_end_time'] = abTestEndTime.value!.toIso8601String();
      }
    }

    // Product-specific fields
    if (selectedType.value == 'feature_product_popup') {
      if (productIdController.text.isNotEmpty) {
        data['product_id'] = productIdController.text.trim();
      }
      if (productNameController.text.isNotEmpty) {
        data['product_name'] = productNameController.text.trim();
      }
      if (productPriceController.text.isNotEmpty) {
        data['product_price'] =
            double.tryParse(productPriceController.text) ?? 0.0;
      }
    }

    return data;
  }

  Future<void> selectDateTime(Rx<DateTime?> dateTimeVar, String title) async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: dateTimeVar.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(
          dateTimeVar.value ?? DateTime.now(),
        ),
      );

      if (time != null) {
        dateTimeVar.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // Clear error for this field
        if (dateTimeVar == startTime) startTimeError.value = null;
        if (dateTimeVar == endTime) endTimeError.value = null;
        if (dateTimeVar == abTestStartTime) abTestStartTimeError.value = null;
        if (dateTimeVar == abTestEndTime) abTestEndTimeError.value = null;
      }
    }
  }

  void _handleError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      _handleError('Error picking image: ${e.toString()}');
    }
  }

  void removeImage() {
    selectedImage.value = null;
    existingImageUrl.value = '';
  }
}

// Complete Add Popup View with ALL fields - Elegant teal design
class AddPopupView extends StatelessWidget {
  AddPopupView({super.key});

  final controller = Get.put(AddPopupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit Popup' : 'Create Popup',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildBasicInformationCard(),
              const SizedBox(height: 16),
              _buildImageUploadCard(),
              const SizedBox(height: 16),
              _buildDisplaySettingsCard(),
              const SizedBox(height: 16),
              _buildLinkSettingsCard(),
              const SizedBox(height: 16),
              Obx(
                () =>
                    controller.isAbTest.value
                        ? Column(
                          children: [
                            _buildAbTestCard(),
                            const SizedBox(height: 16),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
              // Obx(
              //   () =>
              //       controller.selectedType.value == 'feature_product_popup'
              //           ? Column(
              //             children: [
              //               _buildProductCard(),
              //               const SizedBox(height: 16),
              //             ],
              //           )
              //           : const SizedBox.shrink(),
              // ),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          if (required) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBasicInformationCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Basic Information',
            Icons.info_outline,
            required: true,
          ),
          _buildTextField(
            'Popup Name',
            controller.nameController,
            'Enter the unique name of your popup',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Popup name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Popup Type',
            controller.selectedType,
            controller.typeOptions,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'User Segment',
            controller.selectedUserSegment,
            controller.userSegmentOptions,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Description',
            controller.descriptionController,
            'Describe your popup content and purpose',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchRow(
            'Active',
            'Show popup to users',
            controller.isActive,
            Icons.visibility_outlined,
          ),
          const SizedBox(height: 8),
          _buildSwitchRow(
            'Enable A/B Testing',
            'Compare two popup variants',
            controller.isAbTest,
            Icons.science_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    RxBool value,
    IconData icon,
  ) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              value.value
                  ? Colors.teal.withValues(alpha: 0.04)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                value.value
                    ? Colors.teal.withValues(alpha: 0.2)
                    : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: value.value ? Colors.teal : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: value.value ? Colors.teal[800] : Colors.grey[700],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Switch(
              value: value.value,
              onChanged: (v) => value.value = v,
              activeThumbColor: Colors.teal,
              activeTrackColor: Colors.teal.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Popup Image', Icons.image_outlined),
          Text(
            'Choose an eye-catching image for your popup (recommended: 800x600px)',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final hasImage =
                controller.selectedImage.value != null ||
                controller.existingImageUrl.value.isNotEmpty;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      hasImage
                          ? Colors.teal.withValues(alpha: 0.3)
                          : Colors.grey[300]!,
                  width: hasImage ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (hasImage) ...[
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                        child:
                            controller.selectedImage.value != null
                                ? Image.file(
                                  controller.selectedImage.value!,
                                  fit: BoxFit.cover,
                                )
                                : Image.network(
                                  controller.existingImageUrl.value,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.teal,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (_, __, ___) => Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.pickImage,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Change'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: BorderSide(
                                  color: Colors.teal.withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.removeImage,
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Remove'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: BorderSide(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Tap to upload image',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'JPG, PNG supported (Max 5MB)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDisplaySettingsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Display Settings', Icons.tune_outlined),
          _buildTextField(
            'Display Location',
            controller.pageLocationController,
            'e.g., Show on all pages',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Display location is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Display Delay (seconds)',
            controller.displayDelayController,
            'Enter delay in seconds',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final delay = int.tryParse(value);
                if (delay == null || delay < 0) {
                  return 'Please enter a valid delay in seconds';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchRow(
            'Show Once Per Session',
            'Prevent repeat display per session',
            controller.showOncePerSession,
            Icons.repeat_one_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  'Start Time',
                  controller.startTime,
                  () => controller.selectDateTime(
                    controller.startTime,
                    'Start Time',
                  ),
                  errorText: controller.startTimeError,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimeField(
                  'End Time',
                  controller.endTime,
                  () =>
                      controller.selectDateTime(controller.endTime, 'End Time'),
                  errorText: controller.endTimeError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkSettingsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Link Settings', Icons.link_outlined),
          _buildDropdown(
            'Variant A Link Type',
            controller.selectedLinkType,
            controller.linkTypeOptions,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Variant A Link URL',
            controller.linkUrlController,
            'https://example.com',
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final urlPattern = RegExp(
                  r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)',
                );
                if (!urlPattern.hasMatch(value)) {
                  return 'Please enter a valid URL';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAbTestCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purple header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    size: 16,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'A/B Test Configuration',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
          ),
          // Info banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Variant A (Control) is your primary popup. Configure Variant B below.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  'Variant B Link Type',
                  controller.selectedVariantBLinkType,
                  controller.linkTypeOptions,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Variant B Link URL',
                  controller.variantBLinkUrlController,
                  'https://example.com',
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final urlPattern = RegExp(
                        r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)',
                      );
                      if (!urlPattern.hasMatch(value)) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeField(
                        'Test Start',
                        controller.abTestStartTime,
                        () => controller.selectDateTime(
                          controller.abTestStartTime,
                          'A/B Test Start',
                        ),
                        errorText: controller.abTestStartTimeError,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateTimeField(
                        'Test End',
                        controller.abTestEndTime,
                        () => controller.selectDateTime(
                          controller.abTestEndTime,
                          'A/B Test End',
                        ),
                        errorText: controller.abTestEndTimeError,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSwitchRow(
                  'Auto Select Winner',
                  'Automatically pick the best variant',
                  controller.abTestAutoSelectWinner,
                  Icons.emoji_events_outlined,
                ),
                const SizedBox(height: 8),
                _buildSwitchRow(
                  'Test Completed',
                  'Mark A/B test as finished',
                  controller.abTestCompleted,
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Product Information',
            Icons.shopping_bag_outlined,
          ),
          _buildTextField(
            'Product ID',
            controller.productIdController,
            'Enter product ID',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Product Name',
            controller.productNameController,
            'Enter product name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Product Price',
            controller.productPriceController,
            'Enter product price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixText: '\$ ',
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Please enter a valid price';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.savePopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.teal.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  controller.isLoading.value
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            controller.isEditMode.value
                                ? 'Updating...'
                                : 'Saving...',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.isEditMode.value
                                ? Icons.save_outlined
                                : Icons.add_circle_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.isEditMode.value
                                ? 'Update Popup'
                                : 'Create Popup',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixText: prefixText,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    RxString selectedValue,
    List<Map<String, String>> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue.value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[500],
                  size: 20,
                ),
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                items:
                    options.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value']!,
                        child: Text(option['label']!),
                      );
                    }).toList(),
                onChanged: (value) => selectedValue.value = value!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(
    String label,
    Rx<DateTime?> dateTime,
    VoidCallback onTap, {
    RxnString? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () {
              final hasError =
                  errorText != null && errorText.value != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(
                        color:
                            hasError
                                ? const Color(0xFFEF4444)
                                : dateTime.value != null
                                    ? Colors.teal.withValues(alpha: 0.3)
                                    : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color:
                              hasError
                                  ? const Color(0xFFEF4444)
                                  : dateTime.value != null
                                      ? Colors.teal
                                      : Colors.grey[400],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            dateTime.value != null
                                ? '${dateTime.value!.day}/${dateTime.value!.month}/${dateTime.value!.year} ${dateTime.value!.hour}:${dateTime.value!.minute.toString().padLeft(2, '0')}'
                                : 'Select date & time',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  dateTime.value != null
                                      ? Colors.grey[800]
                                      : Colors.grey[400],
                            ),
                          ),
                        ),
                        if (dateTime.value != null)
                          GestureDetector(
                            onTap: () => dateTime.value = null,
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 14),
                      child: Text(
                        errorText.value!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Complete ApiService class
class ApiService extends GetxService {
  Future<ApiService> init() async {
    return this;
  }

  final String baseUrl = 'https://api.libanbuy.com/api';

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path?_t=${DateTime.now().millisecondsSinceEpoch}',
    ).replace(queryParameters: queryParameters);
    final headers = await _getHeaders();

    try {
      final response = await http.get(uri, headers: headers);
      _logResponse('GET', uri.path, response);
      _checkError(response);
      return response;
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  Future<http.Response> post(String path, {dynamic data}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      _logResponse('POST', uri.path, response);
      _checkError(response);
      return response;
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  Future<http.Response> put(String path, {dynamic data}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      _logResponse('PUT', uri.path, response);
      _checkError(response);
      return response;
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();

    try {
      final response = await http.delete(uri, headers: headers);
      _logResponse('DELETE', uri.path, response);
      _checkError(response);
      return response;
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-From': 'Dashboard',
      'shop-id': AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
      'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
    };
  }

  void _logResponse(String method, String path, http.Response response) {
    print('RESPONSE [$method] $path => ${response.statusCode}');
  }

  void _checkError(http.Response response) {
    if (response.statusCode >= 400) {
      final data = json.decode(response.body);
      final message = data['message'] ?? 'Server error: ${response.statusCode}';
      _showError(message);
    }
  }

  void _handleException(dynamic error) {
    String message = 'An error occurred';
    if (error is http.ClientException) {
      message = 'Network error. Please check your internet connection.';
    } else {
      message = error.toString();
    }
    _showError(message);
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
