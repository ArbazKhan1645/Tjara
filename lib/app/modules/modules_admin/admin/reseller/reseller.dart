// models/membership_plan.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/main.dart';

class MembershipPlan {
  final String id;
  final String slug;
  final String userType;
  final String name;
  final double price;
  final String? description;
  final String duration;
  final String? parentId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MembershipPlanFeature> features;

  MembershipPlan({
    required this.id,
    required this.slug,
    required this.userType,
    required this.name,
    required this.price,
    this.description,
    required this.duration,
    this.parentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.features,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'],
      slug: json['slug'],
      userType: json['user_type'],
      name: json['name'],
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      duration: json['duration'],
      parentId: json['parent_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      features:
          (json['features']['membership_plan_features'] as List?)
              ?.map((f) => MembershipPlanFeature.fromJson(f))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'user_type': userType,
      'description': description,
      'price': price,
      'duration': duration,
      'parent_id': parentId,
      'features': features.map((f) => f.toJson()).toList(),
    };
  }
}

class MembershipPlanFeature {
  final String? id;
  final String? planId;
  final String name;
  final String value;
  final String isAvailable;

  MembershipPlanFeature({
    this.id,
    this.planId,
    required this.name,
    required this.value,
    required this.isAvailable,
  });

  factory MembershipPlanFeature.fromJson(Map<String, dynamic> json) {
    return MembershipPlanFeature(
      id: json['id']?.toString(),
      planId: json['plan_id']?.toString(),
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      isAvailable: json['is_available']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'is_available': isAvailable, // Send as integer
      if (planId != null) 'plan_id': planId,
    };
  }
}

class ResellerService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  static Map<String, String> get headers => {
    'X-Request-From': 'Application',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>> getMembershipPlans({
    int page = 1,
    int perPage = 10,
    String search = '',
  }) async {
    final url = Uri.parse(
      '$baseUrl/membership-plans?with=thumbnail,shop&filterJoin=OR&search=$search&orderBy=created_at&order=desc&page=$page&per_page=$perPage&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=user_type&filterByColumns[columns][0][value]=reseller&filterByColumns[columns][0][operator]=%3D',
    );

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load membership plans: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static createMembershipPlan(MembershipPlan plan, String? thumbnailId) async {
    final url = Uri.parse('$baseUrl/membership-plans/insert');

    try {
      final Map<String, String> body = {
        'name': plan.name,
        'user_type': 'reseller',
        'description': plan.description ?? '',
        'price': plan.price.toString(),
        'duration': plan.duration.toString(),
        'status': 'active',
      };

      // Add each feature as features[index]
      for (int i = 0; i < plan.features.length; i++) {
        final feature = plan.features[i];
        body['features[$i]'] = jsonEncode({
          'name': feature.name,
          'value': feature.value,
          'is_available': 1,
        });
      }
      // Then send like this
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Server error: ${errorData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error creating membership plan: $e');
      throw Exception('Failed to create membership plan: $e');
    }
  }

  static updateMembershipPlan(
    String id,
    MembershipPlan plan,
    String? thumbnailId,
  ) async {
    final url = Uri.parse('$baseUrl/membership-plans/$id/update');

    final Map<String, String> body = {
      'name': plan.name,
      'user_type': 'reseller',
      'description': plan.description ?? '',
      'price': plan.price.toString(),
      'duration': plan.duration.toString(),
      'status': 'active',
    };

    // Add each feature as features[index]
    for (int i = 0; i < plan.features.length; i++) {
      final feature = plan.features[i];
      body['features[$i]'] = jsonEncode({
        'name': feature.name,
        'value': feature.value,
        'is_available': 1,
      });
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.back();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Server error: ${errorData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error updating membership plan: $e');
      throw Exception('Failed to update membership plan: $e');
    }
  }

  static Future<void> deleteMembershipPlan(String id) async {
    final url = Uri.parse('$baseUrl/membership-plans/$id/delete');

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Server error: ${errorData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete membership plan: $e');
    }
  }
}

class ResellerController extends GetxController {
  final RxList<MembershipPlan> membershipPlans = <MembershipPlan>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadMembershipPlans();
    setupScrollListener();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMoreData.value) {
          loadMorePlans();
        }
      }
    });
  }

  Future<void> loadMembershipPlans({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    isLoading.value = true;
    try {
      final response = await ResellerService.getMembershipPlans(
        page: currentPage.value,
        search: searchQuery.value,
      );

      final plans =
          (response['membership_plans']['data'] as List?)
              ?.map((json) => MembershipPlan.fromJson(json))
              .toList() ??
          [];

      if (refresh) {
        membershipPlans.value = plans;
      } else {
        membershipPlans.addAll(plans);
      }

      totalPages.value = response['membership_plans']['last_page'] ?? 1;
      hasMoreData.value = currentPage.value < totalPages.value;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load membership plans: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMorePlans() async {
    if (!hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      final response = await ResellerService.getMembershipPlans(
        page: currentPage.value,
        search: searchQuery.value,
      );

      final plans =
          (response['membership_plans']['data'] as List?)
              ?.map((json) => MembershipPlan.fromJson(json))
              .toList() ??
          [];

      membershipPlans.addAll(plans);
      hasMoreData.value = currentPage.value < totalPages.value;
    } catch (e) {
      currentPage.value--;
      Get.snackbar(
        'Error',
        'Failed to load more plans: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadMembershipPlans(refresh: true);
  }

  Future<void> deletePlan(String id) async {
    try {
      await ResellerService.deleteMembershipPlan(id);
      membershipPlans.removeWhere((plan) => plan.id == id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete membership plan: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void showDeleteConfirmation(MembershipPlan plan) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              deletePlan(plan.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

class AddEditResellerController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  // Observable variables
  final RxString selectedDuration = 'monthly'.obs;
  final RxBool isLoading = false.obs;
  final RxList<File> selectedImages = <File>[].obs;

  // Feature controllers
  final minSpentController = TextEditingController();
  final checkoutDiscountController = TextEditingController();
  final bonusAmountController = TextEditingController();
  final referralEarningsController = TextEditingController();
  final RxBool freeShipping = false.obs;

  final List<String> durationOptions = ['monthly', 'yearly'];

  MembershipPlan? editingPlan;
  bool get isEditing => editingPlan != null;

  @override
  void onInit() {
    super.onInit();
    // Check if we're editing
    if (Get.arguments != null && Get.arguments is MembershipPlan) {
      editingPlan = Get.arguments as MembershipPlan;
      populateFields();
    }
  }

  void populateFields() {
    if (editingPlan == null) return;

    nameController.text = editingPlan!.name;
    descriptionController.text = editingPlan!.description ?? '';
    priceController.text = editingPlan!.price.toString();
    selectedDuration.value = editingPlan!.duration;

    // Populate features
    for (var feature in editingPlan!.features) {
      switch (feature.name) {
        case 'min-spent':
          minSpentController.text = feature.value;
          break;
        case 'checkout-discount':
          checkoutDiscountController.text = feature.value;
          break;
        case 'bonus-amount':
          bonusAmountController.text = feature.value;
          break;
        case 'referrel-earnings':
          referralEarningsController.text = feature.value;
          break;
        case 'free-shipping':
          freeShipping.value = feature.value.toLowerCase() == 'true';
          break;
      }
    }
  }

  List<MembershipPlanFeature> getFeatures() {
    final List<MembershipPlanFeature> featureList = [];

    if (minSpentController.text.trim().isNotEmpty) {
      featureList.add(
        MembershipPlanFeature(
          name: 'min-spent',
          value: minSpentController.text.trim(),
          isAvailable: '1',
        ),
      );
    }

    if (checkoutDiscountController.text.trim().isNotEmpty) {
      featureList.add(
        MembershipPlanFeature(
          name: 'checkout-discount',
          value: checkoutDiscountController.text.trim(),
          isAvailable: '1',
        ),
      );
    }

    if (bonusAmountController.text.trim().isNotEmpty) {
      featureList.add(
        MembershipPlanFeature(
          name: 'bonus-amount',
          value: bonusAmountController.text.trim(),
          isAvailable: '1',
        ),
      );
    }

    if (referralEarningsController.text.trim().isNotEmpty) {
      featureList.add(
        MembershipPlanFeature(
          name: 'referrel-earnings',
          value: referralEarningsController.text.trim(),
          isAvailable: '1',
        ),
      );
    }

    if (freeShipping.value) {
      featureList.add(
        MembershipPlanFeature(
          name: 'free-shipping',
          value: 'true',
          isAvailable: '1',
        ),
      );
    }

    return featureList;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  String? validateFeatureValue(String? value, String fieldName) {
    if (value != null && value.trim().isNotEmpty) {
      final numValue = double.tryParse(value.trim());
      if (numValue == null) {
        return '$fieldName must be a valid number';
      }
      if (numValue < 0) {
        return '$fieldName cannot be negative';
      }
    }
    return null;
  }

  bool validateFeatures() {
    return minSpentController.text.trim().isNotEmpty ||
        checkoutDiscountController.text.trim().isNotEmpty ||
        bonusAmountController.text.trim().isNotEmpty ||
        referralEarningsController.text.trim().isNotEmpty ||
        freeShipping.value;
  }

  Future<void> savePlan() async {
    if (!formKey.currentState!.validate()) return;

    // Validate that at least one feature is provided
    if (!validateFeatures()) {
      Get.snackbar(
        'Validation Error',
        'Please provide at least one feature for the membership plan',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    isLoading.value = true;

    try {
      String? thumbnailId;

      // Upload thumbnail if selected
      if (selectedImages.isNotEmpty) {
        thumbnailId = await uploadMedia(selectedImages);
      }

      final plan = MembershipPlan(
        id: editingPlan?.id ?? '',
        slug: nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
        userType: 'reseller',
        name: nameController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0,
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        duration: selectedDuration.value,
        parentId: 'b8dc0167-73af-47b5-a87a-065d25120751',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        features: getFeatures(),
      );

      print(
        'Features being sent: ${plan.features.map((f) => f.toJson()).toList()}',
      );

      if (isEditing) {
        await ResellerService.updateMembershipPlan(
          editingPlan!.id,
          plan,
          thumbnailId,
        );
        Get.snackbar(
          'Success',
          'Membership plan updated successfully',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      } else {
        await ResellerService.createMembershipPlan(plan, thumbnailId);
        Get.snackbar(
          'Success',
          'Membership plan created successfully',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }

      // Refresh the main list
      if (Get.isRegistered<ResellerController>()) {
        Get.find<ResellerController>().loadMembershipPlans(refresh: true);
      }
      Get.back();
    } catch (e) {
      print('Error saving plan: $e');
      Get.snackbar(
        'Error',
        'Failed to save membership plan: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    minSpentController.dispose();
    checkoutDiscountController.dispose();
    bonusAmountController.dispose();
    referralEarningsController.dispose();
    super.onClose();
  }
}

class ResellerListPage extends StatelessWidget {
  const ResellerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResellerController());
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseller Levels'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const AddEditResellerPage()),
            tooltip: 'Add New Reseller Level',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by Title...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green[700]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: controller.onSearchChanged,
                    ),
                  ),

                  // Data Table
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.membershipPlans.isEmpty) {
                        return const Column(
                          children: [
                            LinearProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading membership plans...'),
                          ],
                        );
                      }

                      if (controller.membershipPlans.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No membership plans found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first reseller level',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed:
                                    () => Get.to(
                                      () => const AddEditResellerPage(),
                                    ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Reseller Level'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh:
                            () => controller.loadMembershipPlans(refresh: true),
                        child: SingleChildScrollView(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor: WidgetStateProperty.all(
                                const Color(0xff0D9488),
                              ),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              columns: const [
                                DataColumn(label: Text('Thumbnail')),
                                DataColumn(label: Text('Reseller Level Name')),
                                DataColumn(label: Text('Minimum Amount Spent')),
                                DataColumn(label: Text('Store Discount')),
                                DataColumn(label: Text('Bonus Amount')),
                                DataColumn(label: Text('Referral Earnings')),
                                DataColumn(label: Text('Free Shipping')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows:
                                  controller.membershipPlans.map((plan) {
                                    final bonus =
                                        plan.features
                                            .where(
                                              (f) => f.name == 'bonus-amount',
                                            )
                                            .firstOrNull
                                            ?.value ??
                                        '0';
                                    final referrelearnings =
                                        plan.features
                                            .where(
                                              (f) =>
                                                  f.name == 'referrel-earnings',
                                            )
                                            .firstOrNull
                                            ?.value ??
                                        '0';

                                    final freeShipping =
                                        plan.features
                                            .where(
                                              (f) => f.name == 'free-shipping',
                                            )
                                            .firstOrNull
                                            ?.value ??
                                        'false';
                                    final minSpent =
                                        plan.features
                                            .where((f) => f.name == 'min-spent')
                                            .firstOrNull
                                            ?.value ??
                                        '0';
                                    final discount =
                                        plan.features
                                            .where(
                                              (f) =>
                                                  f.name == 'checkout-discount',
                                            )
                                            .firstOrNull
                                            ?.value ??
                                        '0';

                                    return DataRow(
                                      cells: [
                                        const DataCell(
                                          CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            plan.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text('\$$minSpent.00')),
                                        DataCell(Text('$discount%')),
                                        DataCell(Text(bonus)),

                                        DataCell(Text(referrelearnings)),
                                        DataCell(
                                          Text(
                                            freeShipping.toLowerCase() == 'true'
                                                ? 'Yes'
                                                : 'No',
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  plan.status == 'active'
                                                      ? Colors.green[100]
                                                      : Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              plan.status,
                                              style: TextStyle(
                                                color:
                                                    plan.status == 'active'
                                                        ? Colors.green[700]
                                                        : Colors.red[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'edit':
                                                  Get.to(
                                                    () =>
                                                        const AddEditResellerPage(),
                                                    arguments: plan,
                                                  );
                                                  break;
                                                case 'delete':
                                                  controller
                                                      .showDeleteConfirmation(
                                                        plan,
                                                      );
                                                  break;
                                              }
                                            },
                                            itemBuilder:
                                                (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.edit,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete,
                                                          size: 16,
                                                          color: Colors.red,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Loading more indicator
                  Obx(() {
                    if (controller.isLoadingMore.value) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Loading more...'),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditResellerPage extends StatelessWidget {
  const AddEditResellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEditResellerController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          controller.isEditing
              ? 'Edit Reseller Level'
              : 'Add New Reseller Level',
        ),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reseller Level Information
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header (separate padded container inside card)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Reseller Level Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field (external label + themed input)
                          const Text(
                            'Reseller Level Name *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter the unique name of your membership Plan. Make it descriptive and easy to remember for customers.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              hintText: 'Reseller Level Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF97316),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: controller.validateName,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Features Section
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header (separate padded container inside card)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Reseller Level Features',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Min Spent
                          _buildFeatureField(
                            'Minimum Amount Spent',
                            'Amount required to maintain this level',
                            controller.minSpentController,
                            'Enter minimum spending amount',
                            controller.validateFeatureValue,
                          ),
                          const SizedBox(height: 16),

                          // Checkout Discount
                          _buildFeatureField(
                            'Checkout Discount (%)',
                            'Percentage discount at checkout',
                            controller.checkoutDiscountController,
                            'Enter discount percentage',
                            controller.validateFeatureValue,
                          ),
                          const SizedBox(height: 16),

                          // Bonus Amount
                          _buildFeatureField(
                            'Bonus Amount',
                            'Additional bonus for this level',
                            controller.bonusAmountController,
                            'Enter bonus amount',
                            controller.validateFeatureValue,
                          ),
                          const SizedBox(height: 16),

                          // Referral Earnings
                          _buildFeatureField(
                            'Referral Earnings (%)',
                            'Commission percentage for referrals',
                            controller.referralEarningsController,
                            'Enter referral percentage',
                            controller.validateFeatureValue,
                          ),
                          const SizedBox(height: 16),

                          // Free Shipping
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    controller.freeShipping.value
                                        ? Colors.green[50]
                                        : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      controller.freeShipping.value
                                          ? Colors.green[200]!
                                          : Colors.grey[300]!,
                                ),
                              ),
                              child: SwitchListTile(
                                title: const Text(
                                  'Free Shipping',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: const Text(
                                  'Enable free shipping for this level',
                                ),
                                value: controller.freeShipping.value,
                                onChanged: (value) {
                                  controller.freeShipping.value = value;
                                },
                                activeThumbColor: const Color(0xFFF97316),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF97316), Color(0xFFFACC15)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF97316,
                                  ).withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : controller.savePlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        controller.isEditing
                                            ? 'Update'
                                            : 'Create',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
      ),
    );
  }

  Widget _buildFeatureField(
    String label,
    String subtitle,
    TextEditingController controller,
    String hint,
    String? Function(String?, String) validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF97316)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) => validator(value, label),
        ),
      ],
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final List<File> selectedImages;
  final Function(List<File>) onImagesSelected;
  final String label;
  final bool allowMultiple;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.onImagesSelected,
    this.label = 'Select Images',
    this.allowMultiple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Selected Images Preview
        if (selectedImages.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            final List<File> newList = List.from(
                              selectedImages,
                            );
                            newList.removeAt(index);
                            onImagesSelected(newList);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Add Image Button
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Tap to add image',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImages(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImages(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      if (allowMultiple && source == ImageSource.gallery) {
        final List<XFile> images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          final List<File> newImages =
              images.map((image) => File(image.path)).toList();
          onImagesSelected([...selectedImages, ...newImages]);
        }
      } else {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          onImagesSelected([...selectedImages, File(image.path)]);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}

// Enhanced Widgets for better UX
class LoadingDialog {
  static void show({String message = 'Loading...'}) {
    Get.dialog(
      Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}

// Extensions for better code organization
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Validation utilities
class ValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value != null && value.isNotEmpty) {
      if (double.tryParse(value) == null) {
        return '$fieldName must be a valid number';
      }
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value != null && value.isNotEmpty) {
      final number = double.tryParse(value);
      if (number == null) {
        return '$fieldName must be a valid number';
      }
      if (number < 0) {
        return '$fieldName must be positive';
      }
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;

    return null;
  }
}

// Error handling utility
class ErrorHandler {
  static void handleError(dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      message = error;
    }

    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }
}

// Network utility for handling API responses
class NetworkUtils {
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static Map<String, dynamic> parseErrorResponse(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      return {'message': 'Invalid response format'};
    }
  }
}
