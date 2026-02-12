// models/membership_plan.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/main.dart';

// ==========================================
// THEME COLORS
// ==========================================
class ResellerTheme {
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color lightTeal = Color(0xFF14B8A6);
  static const Color darkTeal = Color(0xFF0F766E);
  static const Color accentOrange = Colors.teal;
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTeal, primaryTeal, lightTeal],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryTeal, lightTeal],
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryTeal.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ==========================================
// SHIMMER LOADING WIDGET
// ==========================================
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerTableRow extends StatelessWidget {
  const ShimmerTableRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MODELS
// ==========================================
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
      'is_available': isAvailable,
      if (planId != null) 'plan_id': planId,
    };
  }
}

// ==========================================
// SERVICE
// ==========================================
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

  static Future<void> createMembershipPlan(
    MembershipPlan plan,
    String? thumbnailId,
  ) async {
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

      for (int i = 0; i < plan.features.length; i++) {
        final feature = plan.features[i];
        body['features[$i]'] = jsonEncode({
          'name': feature.name,
          'value': feature.value,
          'is_available': 1,
        });
      }

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

  static Future<void> updateMembershipPlan(
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

// ==========================================
// CONTROLLER
// ==========================================
class ResellerController extends GetxController {
  final RxList<MembershipPlan> membershipPlans = <MembershipPlan>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt totalItems = 0.obs;

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
      totalItems.value = response['membership_plans']['total'] ?? 0;
      hasMoreData.value = currentPage.value < totalPages.value;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load membership plans',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
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
        'Failed to load more plans',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
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
      totalItems.value = totalItems.value - 1;
      Get.snackbar(
        'Success',
        'Reseller level deleted successfully',
        backgroundColor: ResellerTheme.lightTeal.withOpacity(0.1),
        colorText: ResellerTheme.darkTeal,
        icon: const Icon(Icons.check_circle, color: ResellerTheme.primaryTeal),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete membership plan',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void showDeleteConfirmation(MembershipPlan plan) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${plan.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deletePlan(plan.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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

// ==========================================
// ADD/EDIT CONTROLLER
// ==========================================
class AddEditResellerController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxString selectedDuration = 'monthly'.obs;
  final RxBool isLoading = false.obs;
  final RxList<File> selectedImages = <File>[].obs;

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

    if (!validateFeatures()) {
      Get.snackbar(
        'Validation Error',
        'Please provide at least one feature for the membership plan',
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[800],
        icon: const Icon(Icons.warning_amber, color: Colors.orange),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;

    try {
      String? thumbnailId;

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

      if (isEditing) {
        await ResellerService.updateMembershipPlan(
          editingPlan!.id,
          plan,
          thumbnailId,
        );
        Get.snackbar(
          'Success',
          'Reseller level updated successfully',
          backgroundColor: ResellerTheme.lightTeal.withOpacity(0.1),
          colorText: ResellerTheme.darkTeal,
          icon: const Icon(
            Icons.check_circle,
            color: ResellerTheme.primaryTeal,
          ),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        await ResellerService.createMembershipPlan(plan, thumbnailId);
        Get.snackbar(
          'Success',
          'Reseller level created successfully',
          backgroundColor: ResellerTheme.lightTeal.withOpacity(0.1),
          colorText: ResellerTheme.darkTeal,
          icon: const Icon(
            Icons.check_circle,
            color: ResellerTheme.primaryTeal,
          ),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }

      if (Get.isRegistered<ResellerController>()) {
        Get.find<ResellerController>().loadMembershipPlans(refresh: true);
      }
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save membership plan',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
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

// ==========================================
// RESELLER LIST PAGE
// ==========================================
class ResellerListPage extends StatelessWidget {
  const ResellerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResellerController());

    return Scaffold(
      backgroundColor: ResellerTheme.surfaceColor,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                backgroundColor: ResellerTheme.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: ResellerTheme.headerGradient,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reseller Levels',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your reseller membership tiers',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => Row(
                                children: [
                                  _buildStatChip(
                                    Icons.layers_outlined,
                                    '${controller.membershipPlans.length}',
                                    'Levels',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatChip(
                                    Icons.check_circle_outline,
                                    '${controller.membershipPlans.where((p) => p.status == 'active').length}',
                                    'Active',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed:
                          () => Get.to(() => const AddEditResellerPage()),
                      tooltip: 'Add New Reseller Level',
                    ),
                  ),
                ],
              ),
            ],
        body: RefreshIndicator(
          onRefresh: () async => controller.loadMembershipPlans(refresh: true),
          color: ResellerTheme.primaryTeal,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ResellerTheme.primaryTeal.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search reseller levels...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      suffixIcon: Obx(
                        () =>
                            controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.onSearchChanged('');
                                  },
                                )
                                : const SizedBox.shrink(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: controller.onSearchChanged,
                  ),
                ),

                const SizedBox(height: 20),

                // Content
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.membershipPlans.isEmpty) {
                    return Column(
                      children: List.generate(
                        3,
                        (index) => const ShimmerCard(),
                      ),
                    );
                  }

                  if (controller.membershipPlans.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      // Plans List
                      ...controller.membershipPlans.map(
                        (plan) => _buildPlanCard(plan, controller),
                      ),

                      // Loading more indicator
                      if (controller.isLoadingMore.value)
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ResellerTheme.primaryTeal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading more...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ResellerTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.layers_outlined,
              size: 64,
              color: ResellerTheme.primaryTeal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reseller Levels Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first reseller level to start\nmanaging membership tiers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddEditResellerPage()),
            icon: const Icon(Icons.add),
            label: const Text('Create Reseller Level'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ResellerTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MembershipPlan plan, ResellerController controller) {
    final minSpent =
        plan.features.where((f) => f.name == 'min-spent').firstOrNull?.value ??
        '0';
    final discount =
        plan.features
            .where((f) => f.name == 'checkout-discount')
            .firstOrNull
            ?.value ??
        '0';
    final bonus =
        plan.features
            .where((f) => f.name == 'bonus-amount')
            .firstOrNull
            ?.value ??
        '0';
    final referral =
        plan.features
            .where((f) => f.name == 'referrel-earnings')
            .firstOrNull
            ?.value ??
        '0';
    final freeShipping =
        plan.features
            .where((f) => f.name == 'free-shipping')
            .firstOrNull
            ?.value ??
        'false';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ResellerTheme.cardDecoration,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: ResellerTheme.cardGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  plan.status == 'active'
                                      ? Colors.white.withOpacity(0.25)
                                      : Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              plan.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plan.duration.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.to(
                          () => const AddEditResellerPage(),
                          arguments: plan,
                        );
                        break;
                      case 'delete':
                        controller.showDeleteConfirmation(plan);
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
                                Icons.edit_outlined,
                                size: 18,
                                color: ResellerTheme.primaryTeal,
                              ),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.monetization_on_outlined,
                        'Min Spent',
                        '\$$minSpent',
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.discount_outlined,
                        'Discount',
                        '$discount%',
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.card_giftcard,
                        'Bonus',
                        '\$$bonus',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.people_outline,
                        'Referral',
                        '$referral%',
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.local_shipping_outlined,
                        'Free Ship',
                        freeShipping.toLowerCase() == 'true' ? 'Yes' : 'No',
                        isActive: freeShipping.toLowerCase() == 'true',
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String label,
    String value, {
    bool isActive = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:
            isActive
                ? ResellerTheme.primaryTeal.withOpacity(0.08)
                : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? ResellerTheme.primaryTeal : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? ResellerTheme.darkTeal : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ==========================================
// ADD/EDIT RESELLER PAGE
// ==========================================
class AddEditResellerPage extends StatelessWidget {
  const AddEditResellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEditResellerController());

    return Scaffold(
      backgroundColor: ResellerTheme.surfaceColor,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: ResellerTheme.accentOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(color: Colors.teal),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.isEditing
                                  ? 'Edit Reseller Level'
                                  : 'Create Reseller Level',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.isEditing
                                  ? 'Update membership tier settings'
                                  : 'Set up a new membership tier',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information Card
                _buildSectionCard(
                  title: 'Basic Information',
                  icon: Icons.info_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Reseller Level Name', true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.nameController,
                        decoration: _buildInputDecoration(
                          'Enter level name (e.g., Gold, Platinum)',
                          Icons.badge_outlined,
                        ),
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: 20),
                      _buildFieldLabel('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        decoration: _buildInputDecoration(
                          'Brief description of this level',
                          Icons.description_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Features Card
                _buildSectionCard(
                  title: 'Level Features',
                  icon: Icons.star_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Minimum Spent
                      _buildFeatureInputField(
                        controller: controller.minSpentController,
                        label: 'Minimum Amount Spent',
                        hint: 'Amount required to reach this level',
                        icon: Icons.monetization_on_outlined,
                        prefix: '\$',
                        validator:
                            (v) => controller.validateFeatureValue(
                              v,
                              'Minimum Amount',
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Checkout Discount
                      _buildFeatureInputField(
                        controller: controller.checkoutDiscountController,
                        label: 'Checkout Discount',
                        hint: 'Percentage discount at checkout',
                        icon: Icons.discount_outlined,
                        suffix: '%',
                        validator:
                            (v) => controller.validateFeatureValue(
                              v,
                              'Checkout Discount',
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Bonus Amount
                      _buildFeatureInputField(
                        controller: controller.bonusAmountController,
                        label: 'Bonus Amount',
                        hint: 'Additional bonus for this level',
                        icon: Icons.card_giftcard,
                        prefix: '\$',
                        validator:
                            (v) => controller.validateFeatureValue(
                              v,
                              'Bonus Amount',
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Referral Earnings
                      _buildFeatureInputField(
                        controller: controller.referralEarningsController,
                        label: 'Referral Earnings',
                        hint: 'Commission percentage for referrals',
                        icon: Icons.people_outline,
                        suffix: '%',
                        validator:
                            (v) => controller.validateFeatureValue(
                              v,
                              'Referral Earnings',
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Free Shipping Toggle
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                controller.freeShipping.value
                                    ? ResellerTheme.primaryTeal.withOpacity(
                                      0.08,
                                    )
                                    : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  controller.freeShipping.value
                                      ? ResellerTheme.primaryTeal.withOpacity(
                                        0.3,
                                      )
                                      : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      controller.freeShipping.value
                                          ? ResellerTheme.primaryTeal
                                              .withOpacity(0.15)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.local_shipping_outlined,
                                  color:
                                      controller.freeShipping.value
                                          ? ResellerTheme.primaryTeal
                                          : Colors.grey,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Free Shipping',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Enable free shipping for this level',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: controller.freeShipping.value,
                                onChanged:
                                    (value) =>
                                        controller.freeShipping.value = value,
                                activeThumbColor: ResellerTheme.primaryTeal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.savePlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ResellerTheme.accentOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              controller.isLoading.value
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        controller.isEditing
                                            ? Icons.save_outlined
                                            : Icons.add_circle_outline,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        controller.isEditing
                                            ? 'Update Level'
                                            : 'Create Level',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: ResellerTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ResellerTheme.accentOrange.withOpacity(0.1),
                  ResellerTheme.accentOrange.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ResellerTheme.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: ResellerTheme.accentOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, [bool required = false]) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ResellerTheme.accentOrange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildFeatureInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ResellerTheme.accentOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// ==========================================
// IMAGE PICKER WIDGET
// ==========================================
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
                        borderRadius: BorderRadius.circular(12),
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

        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: ResellerTheme.primaryTeal.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: ResellerTheme.primaryTeal.withOpacity(0.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: ResellerTheme.primaryTeal.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to add image',
                  style: TextStyle(
                    color: ResellerTheme.primaryTeal.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context,
                      Icons.photo_library_outlined,
                      'Gallery',
                      () {
                        Navigator.of(context).pop();
                        _pickImages(ImageSource.gallery);
                      },
                    ),
                    _buildSourceOption(
                      context,
                      Icons.camera_alt_outlined,
                      'Camera',
                      () {
                        Navigator.of(context).pop();
                        _pickImages(ImageSource.camera);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: ResellerTheme.primaryTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: ResellerTheme.primaryTeal),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ResellerTheme.darkTeal,
              ),
            ),
          ],
        ),
      ),
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
        'Failed to pick image',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}

// ==========================================
// UTILITY CLASSES
// ==========================================
class LoadingDialog {
  static void show({String message = 'Loading...'}) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ResellerTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
}

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
      backgroundColor: Colors.red[50],
      colorText: Colors.red[700],
      icon: const Icon(Icons.error_outline, color: Colors.red),
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: ResellerTheme.lightTeal.withOpacity(0.1),
      colorText: ResellerTheme.darkTeal,
      icon: const Icon(Icons.check_circle, color: ResellerTheme.primaryTeal),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

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
