import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';

import 'package:tjara/app/models/popups/popups-model.dart';

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
    {'value': 'lead_generation_popup', 'label': 'Lead Generation'},
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

// Updated Popup List View
class PopupListView extends GetView<PopupController> {
  const PopupListView({super.key});

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Popups',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Add New Popup Button Card
                        GestureDetector(
                          onTap: () => Get.to(() => AddPopupView()),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Add New Button
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add New Popup',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Popups List Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Search Input
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                  controller: controller.searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search popups',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF97316),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          bottomLeft: Radius.circular(25),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    controller.searchQuery.value = value;
                                  },
                                ),
                              ),

                              // Filter buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    _buildFilterButton(
                                      'Filter by: All Types',
                                      () {
                                        _showTypeFilterDialog();
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    _buildFilterButton(
                                      'Filter by: All Status',
                                      () {
                                        _showStatusFilterDialog();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Table Header
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF97316),
                                      ),
                                      child: const Row(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            child: Center(
                                              child: Text(
                                                'Thumbnail',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Center(
                                              child: Text(
                                                'ID',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Center(
                                              child: Text(
                                                'Name',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Center(
                                              child: Text(
                                                'Category',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Center(
                                              child: Text(
                                                'Status',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: Center(
                                              child: Text(
                                                'Analytics',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Center(
                                              child: Text(
                                                'Action',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Popups List
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Obx(() {
                                        if (controller.isLoading.value) {
                                          return const SizedBox(
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFFF97316),
                                              ),
                                            ),
                                          );
                                        }

                                        if (controller.filteredPopups.isEmpty) {
                                          return SizedBox(
                                            height: 200,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.campaign_outlined,
                                                    size: 64,
                                                    color: Colors.grey[400],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'No popups found',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return Column(
                                          children:
                                              controller.filteredPopups.map((
                                                popup,
                                              ) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color:
                                                            Colors.grey[200]!,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      // Thumbnail (width: 80)
                                                      SizedBox(
                                                        width: 80,
                                                        child: Center(
                                                          child: Container(
                                                            width: 60,
                                                            height: 60,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              color:
                                                                  Colors
                                                                      .grey[200],
                                                              border: Border.all(
                                                                color:
                                                                    Colors
                                                                        .grey[300]!,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child:
                                                                popup
                                                                            .thumbnail
                                                                            ?.media
                                                                            ?.url !=
                                                                        null
                                                                    ? ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                      child: Image.network(
                                                                        popup
                                                                            .thumbnail!
                                                                            .media!
                                                                            .url!,
                                                                        width:
                                                                            60,
                                                                        height:
                                                                            60,
                                                                        fit:
                                                                            BoxFit.cover,
                                                                        errorBuilder:
                                                                            (
                                                                              context,
                                                                              error,
                                                                              stackTrace,
                                                                            ) => Center(
                                                                              child: Icon(
                                                                                Icons.image_not_supported,
                                                                                size:
                                                                                    24,
                                                                                color:
                                                                                    Colors.grey[400],
                                                                              ),
                                                                            ),
                                                                      ),
                                                                    )
                                                                    : Center(
                                                                      child: Icon(
                                                                        Icons
                                                                            .image,
                                                                        color:
                                                                            Colors.grey[400],
                                                                        size:
                                                                            24,
                                                                      ),
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                      // ID (width: 100)
                                                      SizedBox(
                                                        width: 100,
                                                        child: Center(
                                                          child: Text(
                                                            popup.popupId
                                                                    ?.toString() ??
                                                                'N/A',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                              fontFamily:
                                                                  'monospace',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      // Name (width: 120)
                                                      SizedBox(
                                                        width: 120,
                                                        child: Center(
                                                          child: Text(
                                                            popup.name ??
                                                                'Unnamed',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      // Category (width: 120)
                                                      SizedBox(
                                                        width: 120,
                                                        child: Center(
                                                          child: Builder(
                                                            builder: (context) {
                                                              final categoryNames =
                                                                  popup
                                                                      .categoryNames;

                                                              if (categoryNames ==
                                                                      null ||
                                                                  categoryNames
                                                                      .isEmpty) {
                                                                return Text(
                                                                  'No Category',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .grey[500],
                                                                  ),
                                                                );
                                                              }

                                                              return Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children:
                                                                    categoryNames.map((
                                                                      category,
                                                                    ) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              2,
                                                                        ),
                                                                        child: Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            const Text(
                                                                              '• ',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    12,
                                                                                color: Color(
                                                                                  0xFFF97316,
                                                                                ),
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                category,
                                                                                style: const TextStyle(
                                                                                  fontSize:
                                                                                      12,
                                                                                ),
                                                                                overflow:
                                                                                    TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      // Status (width: 80)
                                                      SizedBox(
                                                        width: 80,
                                                        child: Center(
                                                          child: Builder(
                                                            builder: (context) {
                                                              final now =
                                                                  DateTime.now();
                                                              DateTime? endTime;

                                                              // Parse end time if it exists
                                                              if (popup
                                                                      .endTime !=
                                                                  null) {
                                                                endTime = DateTime.tryParse(
                                                                  popup.endTime
                                                                      .toString(),
                                                                );
                                                              }

                                                              // Determine if expired
                                                              final isExpired =
                                                                  endTime !=
                                                                      null &&
                                                                  now.isAfter(
                                                                    endTime,
                                                                  );

                                                              return Text(
                                                                isExpired
                                                                    ? 'Expired'
                                                                    : 'Active',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      isExpired
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 200,
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'views: ${popup.views}',
                                                              ),
                                                              Text(
                                                                'clicks: ${popup.clicks}',
                                                              ),
                                                              Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  final int
                                                                  views =
                                                                      popup
                                                                          .views ??
                                                                      0;
                                                                  final int
                                                                  clicks =
                                                                      popup
                                                                          .clicks ??
                                                                      0;

                                                                  final double
                                                                  ctr =
                                                                      views > 0
                                                                          ? (clicks /
                                                                                  views) *
                                                                              100
                                                                          : 0;
                                                                  final String
                                                                  ctrText =
                                                                      'CTR: ${ctr.toStringAsFixed(2)}%';

                                                                  return Text(
                                                                    ctrText,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          Colors
                                                                              .blueGrey,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Action (width: 80)
                                                      SizedBox(
                                                        width: 80,
                                                        child: PopupMenuButton<
                                                          String
                                                        >(
                                                          onSelected:
                                                              (value) =>
                                                                  _handleAction(
                                                                    value,
                                                                    popup,
                                                                  ),
                                                          itemBuilder:
                                                              (context) => [
                                                                const PopupMenuItem(
                                                                  value: 'edit',
                                                                  child: Text(
                                                                    'Edit',
                                                                  ),
                                                                ),
                                                                const PopupMenuItem(
                                                                  value:
                                                                      'delete',
                                                                  child: Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                          child: const Icon(
                                                            Icons.more_horiz,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Pagination button
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              // Add pagination logic here
                              controller.refreshData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '1/1',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFilterButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  void _showTypeFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              controller.typeOptions.map((option) {
                return ListTile(
                  title: Text(option['label'] as String),
                  onTap: () {
                    controller.onTypeFilterChanged(option['value'] as String);
                    Get.back();
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showStatusFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              controller.statusOptions.map((option) {
                return ListTile(
                  title: Text(option['label'] as String),
                  onTap: () {
                    controller.onStatusFilterChanged(option['value'] as String);
                    Get.back();
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  void _handleAction(String action, Data popup) {
    switch (action) {
      case 'edit':
        Get.to(() => AddPopupView(), arguments: {'popup': popup})?.then((_) {
          controller.refreshData();
        });
        break;
      case 'delete':
        controller.deletePopup(popup.id!);
        break;
    }
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

  final formKey = GlobalKey<FormState>();

  // ALL options lists
  final typeOptions = [
    {'value': 'banner_popup', 'label': 'Banner Popup'},
    {'value': 'lead_generation_popup', 'label': 'Lead Generation'},
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

  Future<void> savePopup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Upload image first if a new image is selected
      if (selectedImage.value != null) {
        final thumbnailId = await _uploadImage(selectedImage.value!);
        if (thumbnailId != null) {
          selectedThumbnailId.value = thumbnailId;
        } else {
          _handleError('Failed to upload image');
          isLoading.value = false;
          return;
        }
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

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');

      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['X-Request-From'] = 'Application';
      request.headers['Accept'] = 'application/json';

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'media',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add additional fields
      request.fields['media_type'] = 'image';
      request.fields['context'] = 'popup';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Extract media ID from response
        // Adjust this based on your API response structure
        if (responseData['media'] != null &&
            responseData['media']['id'] != null) {
          return responseData['media']['id'].toString();
        } else if (responseData['id'] != null) {
          return responseData['id'].toString();
        }
      }

      print('Image upload failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
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

// Complete Add Popup View with ALL fields
class AddPopupView extends StatelessWidget {
  AddPopupView({super.key});

  final controller = Get.put(AddPopupController());

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit Popup' : 'Add Popup',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Obx(
                        () => Text(
                          controller.isEditMode.value
                              ? 'Edit Popup'
                              : 'Add Popup',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          // Basic Information Card
                          _buildBasicInformationCard(),
                          const SizedBox(height: 16),

                          // Image Upload Card
                          _buildImageUploadCard(),
                          const SizedBox(height: 16),

                          // Display Settings Card
                          _buildDisplaySettingsCard(),
                          const SizedBox(height: 16),

                          // Link Settings Card
                          _buildLinkSettingsCard(),
                          const SizedBox(height: 16),

                          // A/B Test Card (conditional)
                          Obx(
                            () =>
                                controller.isAbTest.value
                                    ? _buildAbTestCard()
                                    : const SizedBox(),
                          ),
                          Obx(
                            () =>
                                controller.isAbTest.value
                                    ? const SizedBox(height: 16)
                                    : const SizedBox(),
                          ),

                          // Product Information Card (conditional)
                          Obx(
                            () =>
                                controller.selectedType.value ==
                                        'feature_product_popup'
                                    ? _buildProductCard()
                                    : const SizedBox(),
                          ),
                          Obx(
                            () =>
                                controller.selectedType.value ==
                                        'feature_product_popup'
                                    ? const SizedBox(height: 16)
                                    : const SizedBox(),
                          ),

                          // Action buttons
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildBasicInformationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Separate container with padding from all sides
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Text(
                  'Basic Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popup Name
                _buildTextField(
                  'Popup Name *',
                  controller.nameController,
                  'Enter the unique name of your popup',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Popup name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Popup Type
                _buildDropdown(
                  'Popup Type',
                  controller.selectedType,
                  controller.typeOptions,
                ),
                const SizedBox(height: 20),

                // User Segment
                _buildDropdown(
                  'User Segment',
                  controller.selectedUserSegment,
                  controller.userSegmentOptions,
                ),
                const SizedBox(height: 20),

                // Description
                _buildTextField(
                  'Description',
                  controller.descriptionController,
                  'Craft a comprehensive description that highlights the unique features',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Active Status
                Obx(
                  () => SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Show popup to users'),
                    value: controller.isActive.value,
                    onChanged: (value) => controller.isActive.value = value,
                    activeThumbColor: const Color(0xFFF97316),
                  ),
                ),

                // Enable A/B Testing
                Obx(
                  () => SwitchListTile(
                    title: const Text('Enable A/B Testing'),
                    subtitle: const Text('This is your primary popup version'),
                    value: controller.isAbTest.value,
                    onChanged: (value) => controller.isAbTest.value = value,
                    activeThumbColor: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.image, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Popup Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Image *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an eye-catching image for your popup (recommended: 800x600px)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Image preview and upload button
                Obx(() {
                  final hasImage =
                      controller.selectedImage.value != null ||
                      controller.existingImageUrl.value.isNotEmpty;

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (hasImage) ...[
                          // Image preview
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
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
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFFF97316),
                                                  ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                          );
                                        },
                                      ),
                            ),
                          ),
                          // Action buttons for existing image
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: controller.pickImage,
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Change Image'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF97316),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: controller.removeImage,
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Remove'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Upload button when no image
                          GestureDetector(
                            onTap: controller.pickImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF97316,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Color(0xFFF97316),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to upload image',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Supported: JPG, PNG (Max 5MB)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
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
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Separate container with padding from all sides
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Text(
                  'Display Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Location
                _buildTextField(
                  'Display Location',
                  controller.pageLocationController,
                  'e.g., Show on all pages',
                ),
                const SizedBox(height: 20),

                // Display Delay
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
                const SizedBox(height: 20),

                // Show Once Per Session
                Obx(
                  () => SwitchListTile(
                    title: const Text('Show Once Per Session'),
                    value: controller.showOncePerSession.value,
                    onChanged:
                        (value) => controller.showOncePerSession.value = value,
                    activeThumbColor: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(height: 16),

                // Start and End Time
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateTimeField(
                        'End Time',
                        controller.endTime,
                        () => controller.selectDateTime(
                          controller.endTime,
                          'End Time',
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
    );
  }

  Widget _buildLinkSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Separate container with padding from all sides
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Text(
                  'Link Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Link Type
                _buildDropdown(
                  'Variant A Link Type',
                  controller.selectedLinkType,
                  controller.linkTypeOptions,
                ),
                const SizedBox(height: 20),

                // Link URL
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
          ),
        ],
      ),
    );
  }

  Widget _buildAbTestCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Warning Header
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Variant A (Control) - This is your primary popup version.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Header - Separate container with padding from all sides
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Text(
                  'A/B Test Configuration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variant B Link Type
                _buildDropdown(
                  'Variant B Link Type',
                  controller.selectedVariantBLinkType,
                  controller.linkTypeOptions,
                ),
                const SizedBox(height: 20),

                // Variant B Link URL
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
                const SizedBox(height: 20),

                // A/B Test Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeField(
                        'A/B Test Start Time',
                        controller.abTestStartTime,
                        () => controller.selectDateTime(
                          controller.abTestStartTime,
                          'A/B Test Start Time',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateTimeField(
                        'A/B Test End Time',
                        controller.abTestEndTime,
                        () => controller.selectDateTime(
                          controller.abTestEndTime,
                          'A/B Test End Time',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // A/B Test Options
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => SwitchListTile(
                          title: const Text('Auto Select Winner'),
                          value: controller.abTestAutoSelectWinner.value,
                          onChanged:
                              (value) =>
                                  controller.abTestAutoSelectWinner.value =
                                      value,
                          activeThumbColor: const Color(0xFFF97316),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => SwitchListTile(
                          title: const Text('Test Completed'),
                          value: controller.abTestCompleted.value,
                          onChanged:
                              (value) =>
                                  controller.abTestCompleted.value = value,
                          activeThumbColor: const Color(0xFFF97316),
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
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Separate container with padding from all sides
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Text(
                  'Product Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product ID
                _buildTextField(
                  'Product ID',
                  controller.productIdController,
                  'Enter product ID',
                ),
                const SizedBox(height: 20),

                // Product Name
                _buildTextField(
                  'Product Name',
                  controller.productNameController,
                  'Enter product name',
                ),
                const SizedBox(height: 20),

                // Product Price
                _buildTextField(
                  'Product Price',
                  controller.productPriceController,
                  'Enter product price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save button
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.savePopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
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
                      : Text(
                        controller.isEditMode.value
                            ? 'Update Popup'
                            : 'Create Popup',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget builders
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixText: prefixText,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue.value,
                isExpanded: true,
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
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => Text(
                dateTime.value != null
                    ? '${dateTime.value!.day}/${dateTime.value!.month}/${dateTime.value!.year} ${dateTime.value!.hour}:${dateTime.value!.minute.toString().padLeft(2, '0')}'
                    : 'Select date and time',
                style: TextStyle(
                  color:
                      dateTime.value != null ? Colors.black : Colors.grey[500],
                ),
              ),
            ),
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
      'X-Request-From': 'Application',
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
