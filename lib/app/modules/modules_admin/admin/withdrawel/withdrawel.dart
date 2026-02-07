// models/withdrawal_model.dart
// services/withdrawal_service.dart
// screens/all_withdrawals_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/admin/withdrawel/widgets/withdrawal_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/withdrawel/widgets/withdrawal_shimmer.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

/// API Response wrapper for better error handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, {int statusCode = 200, String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

class Withdrawal {
  final String id;
  final String shopId;
  final String amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Shop? shop;

  Withdrawal({
    required this.id,
    required this.shopId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.shop,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] ?? '',
      shopId: json['shop_id'] ?? '',
      amount: json['amount'] ?? '0',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      shop: json['shop'] != null ? Shop.fromJson(json['shop']['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Shop {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int balance;

  Shop({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.balance,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      balance: json['balance'] ?? 0,
    );
  }
}

// Service with proper error handling
class WithdrawalService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Request-From': 'Application',
  };

  /// Extract error message from API response
  static String _extractErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      // Check common error message fields
      if (body is Map) {
        if (body['message'] != null) return body['message'].toString();
        if (body['error'] != null) return body['error'].toString();
        if (body['errors'] != null) {
          if (body['errors'] is Map) {
            final errors = body['errors'] as Map;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            return firstError.toString();
          }
          return body['errors'].toString();
        }
      }
      return _getStatusCodeMessage(response.statusCode);
    } catch (_) {
      return _getStatusCodeMessage(response.statusCode);
    }
  }

  /// Get user-friendly message for status codes
  static String _getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'You don\'t have permission for this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getAllWithdrawals({
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/withdrawls?page=$page'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          _extractErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (_) {
      return ApiResponse.error(
        'Network error. Please check your connection.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred.', statusCode: 0);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> createWithdrawal({
    required String shopId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/withdrawls/insert/'),
        headers: _headers,
        body: json.encode({'shop_id': shopId, 'amount': amount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final message =
            data['message']?.toString() ??
            'Withdrawal request created successfully';
        return ApiResponse.success(
          data,
          statusCode: response.statusCode,
          message: message,
        );
      } else {
        return ApiResponse.error(
          _extractErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (_) {
      return ApiResponse.error(
        'Network error. Please check your connection.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred.', statusCode: 0);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateWithdrawal({
    required String id,
    required String shopId,
    required String status,
    required double amount,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/withdrawls/$id/update'),
        headers: _headers,
        body: json.encode({
          'shop_id': shopId,
          'status': status,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message =
            data['message']?.toString() ?? 'Withdrawal $status successfully';
        return ApiResponse.success(
          data,
          statusCode: response.statusCode,
          message: message,
        );
      } else {
        return ApiResponse.error(
          _extractErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (_) {
      return ApiResponse.error(
        'Network error. Please check your connection.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred.', statusCode: 0);
    }
  }

  static Future<ApiResponse<void>> deleteWithdrawal(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/withdrawls/$id/delete'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        String message = 'Withdrawal deleted successfully';
        try {
          final data = json.decode(response.body);
          message = data['message']?.toString() ?? message;
        } catch (_) {}
        return ApiResponse.success(
          null,
          statusCode: response.statusCode,
          message: message,
        );
      } else {
        return ApiResponse.error(
          _extractErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (_) {
      return ApiResponse.error(
        'Network error. Please check your connection.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred.', statusCode: 0);
    }
  }
}

// Controller with proper loading states
class WithdrawalController extends GetxController {
  static String staticShopId =
      AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '';

  // Separate loading states
  var isInitialLoading = false.obs; // For shimmer loading on initial/refresh
  var isSubmitting = false.obs; // For form submission button

  var withdrawals = <Withdrawal>[].obs;
  var userWithdrawals = <Withdrawal>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var selectedStatus = 'all'.obs;
  var searchQuery = ''.obs;

  final amountController = TextEditingController();
  final searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadAllWithdrawals();
  }

  @override
  void onClose() {
    amountController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Show loading dialog for actions
  void _showLoadingDialog({String message = 'Please wait...'}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: WithdrawalTheme.surface,
              borderRadius: BorderRadius.circular(WithdrawalTheme.radiusLg),
              boxShadow: WithdrawalTheme.shadowLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: WithdrawalTheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: WithdrawalTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog safely
  void _hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Show success snackbar
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: WithdrawalTheme.approvedLight,
      colorText: WithdrawalTheme.approved,
      icon: const Icon(
        Icons.check_circle_rounded,
        color: WithdrawalTheme.approved,
      ),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: WithdrawalTheme.rejectedLight,
      colorText: WithdrawalTheme.rejected,
      icon: const Icon(Icons.error_rounded, color: WithdrawalTheme.rejected),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> loadAllWithdrawals({
    int page = 1,
    bool showShimmer = true,
  }) async {
    try {
      if (showShimmer) {
        isInitialLoading.value = true;
      }

      final response = await WithdrawalService.getAllWithdrawals(page: page);

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['withdrawals'] != null) {
          final List<dynamic> withdrawalData = data['withdrawals']['data'];
          withdrawals.value =
              withdrawalData.map((json) => Withdrawal.fromJson(json)).toList();
          currentPage.value = data['withdrawals']['current_page'] ?? 1;
          totalPages.value = data['withdrawals']['last_page'] ?? 1;
          filterUserWithdrawals();
        }
      } else {
        _showError(response.message ?? 'Failed to load withdrawals');
      }
    } catch (e) {
      _showError('Failed to load withdrawals');
    } finally {
      isInitialLoading.value = false;
    }
  }

  void filterUserWithdrawals() {
    userWithdrawals.value =
        withdrawals
            .where((withdrawal) => withdrawal.shopId == staticShopId)
            .toList();
  }

  Future<void> createWithdrawal() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;
      final amount = double.parse(amountController.text);

      final response = await WithdrawalService.createWithdrawal(
        shopId: staticShopId,
        amount: amount,
      );

      if (response.success) {
        amountController.clear();
        _showSuccess(
          response.message ?? 'Withdrawal request created successfully',
        );
        await loadAllWithdrawals(showShimmer: false);
      } else {
        _showError(response.message ?? 'Failed to create withdrawal request');
      }
    } catch (e) {
      _showError('Failed to create withdrawal');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateWithdrawalStatus(
    Withdrawal withdrawal,
    String status,
  ) async {
    _showLoadingDialog(
      message: status == 'approved' ? 'Approving...' : 'Rejecting...',
    );

    try {
      final response = await WithdrawalService.updateWithdrawal(
        id: withdrawal.id,
        shopId: withdrawal.shopId,
        status: status,
        amount: double.parse(withdrawal.amount),
      );

      _hideLoadingDialog();

      if (response.success) {
        _showSuccess(response.message ?? 'Withdrawal $status successfully');
        await loadAllWithdrawals(showShimmer: false);
      } else {
        _showError(response.message ?? 'Failed to update withdrawal status');
      }
    } catch (e) {
      _hideLoadingDialog();
      _showError('Failed to update withdrawal');
    }
  }

  Future<void> deleteWithdrawal(String id) async {
    final confirm = await Get.dialog<bool>(_PremiumDeleteDialog());

    if (confirm != true) return;

    _showLoadingDialog(message: 'Deleting...');

    try {
      final response = await WithdrawalService.deleteWithdrawal(id);

      _hideLoadingDialog();

      if (response.success) {
        _showSuccess(response.message ?? 'Withdrawal deleted successfully');
        await loadAllWithdrawals(showShimmer: false);
      } else {
        _showError(response.message ?? 'Failed to delete withdrawal');
      }
    } catch (e) {
      _hideLoadingDialog();
      _showError('Failed to delete withdrawal');
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Withdrawal> get filteredWithdrawals {
    var filtered = withdrawals.toList();

    if (selectedStatus.value != 'all') {
      filtered =
          filtered.where((w) => w.status == selectedStatus.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (w) =>
                    w.shop?.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false ||
                        w.amount.contains(searchQuery.value) ||
                        w.status.toLowerCase().contains(
                          searchQuery.value.toLowerCase(),
                        ),
              )
              .toList();
    }

    return filtered;
  }

  List<Withdrawal> get filteredUserWithdrawals {
    var filtered = userWithdrawals.toList();

    if (selectedStatus.value != 'all') {
      filtered =
          filtered.where((w) => w.status == selectedStatus.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (w) =>
                    w.amount.contains(searchQuery.value) ||
                    w.status.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Premium Delete Dialog
class _PremiumDeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(WithdrawalTheme.spacingXl),
        decoration: BoxDecoration(
          color: WithdrawalTheme.surface,
          borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
          boxShadow: WithdrawalTheme.shadowXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: WithdrawalTheme.dangerGradient,
                shape: BoxShape.circle,
                boxShadow: WithdrawalTheme.shadowColored(
                  WithdrawalTheme.rejected,
                ),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: WithdrawalTheme.spacingLg),
            const Text(
              'Delete Withdrawal',
              style: WithdrawalTheme.headingMedium,
            ),
            const SizedBox(height: WithdrawalTheme.spacingSm),
            const Text(
              'Are you sure you want to delete this withdrawal request? This action cannot be undone.',
              style: WithdrawalTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WithdrawalTheme.spacingXl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(result: false),
                    style: WithdrawalTheme.outlineButtonStyle,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: WithdrawalTheme.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: WithdrawalTheme.dangerButtonStyle,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Super Elegant All Withdrawals Screen - Admin View
class AllWithdrawalsScreen extends StatelessWidget {
  final WithdrawalController controller = Get.put(WithdrawalController());

  AllWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WithdrawalTheme.background,
      appBar: _buildPremiumAppBar(),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllWithdrawals(),
        color: WithdrawalTheme.primary,
        backgroundColor: WithdrawalTheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: WithdrawalTheme.spacingLg),
              _buildStatsRow(),
              const SizedBox(height: WithdrawalTheme.spacingLg),
              _buildFilterSection(),
              const SizedBox(height: WithdrawalTheme.spacingLg),
              _buildWithdrawalsList(),
              const SizedBox(height: WithdrawalTheme.spacingLg),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: WithdrawalTheme.headerGradient,
        ),
      ),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: const [AdminAppBarActionsSimple()],
      title: const Row(
        children: [
          Text(
            'Withdrawals',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingXl),
      decoration: BoxDecoration(
        gradient: WithdrawalTheme.headerGradient,
        borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
        boxShadow: WithdrawalTheme.shadowLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdrawal Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and manage all withdrawal requests',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: WithdrawalTheme.spacingMd,
                vertical: WithdrawalTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.withdrawals.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final pending =
          controller.withdrawals.where((w) => w.status == 'pending').length;
      final approved =
          controller.withdrawals.where((w) => w.status == 'approved').length;
      final rejected =
          controller.withdrawals.where((w) => w.status == 'rejected').length;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              pending,
              WithdrawalTheme.pending,
              Icons.schedule_rounded,
            ),
          ),

          Expanded(
            child: _buildStatCard(
              'Approved',
              approved,
              WithdrawalTheme.approved,
              Icons.check_circle_rounded,
            ),
          ),

          Expanded(
            child: _buildStatCard(
              'Rejected',
              rejected,
              WithdrawalTheme.rejected,
              Icons.cancel_rounded,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
      decoration: WithdrawalTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(WithdrawalTheme.spacingSm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: WithdrawalTheme.spacingSm,
                  vertical: WithdrawalTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WithdrawalTheme.spacingMd),
          Text(label, style: WithdrawalTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
      decoration: WithdrawalTheme.cardDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.filter_list_rounded,
            color: WithdrawalTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: WithdrawalTheme.spacingMd),
          const Text('Filter:', style: WithdrawalTheme.labelLarge),
          const SizedBox(width: WithdrawalTheme.spacingMd),
          Expanded(
            child: Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: WithdrawalTheme.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: WithdrawalTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusMd),
                  border: Border.all(
                    color: WithdrawalTheme.border.withValues(alpha: 0.5),
                  ),
                ),
                child: DropdownButton<String>(
                  value: controller.selectedStatus.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: WithdrawalTheme.textSecondary,
                  ),
                  style: WithdrawalTheme.bodyLarge,
                  dropdownColor: WithdrawalTheme.surface,
                  items:
                      ['all', 'pending', 'approved', 'rejected']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          status == 'all'
                                              ? WithdrawalTheme.textTertiary
                                              : WithdrawalTheme.getStatusColor(
                                                status,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: WithdrawalTheme.spacingSm,
                                  ),
                                  Text(status.toUpperCase()),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => controller.filterByStatus(value!),
                ),
              ),
            ),
          ),
          const SizedBox(width: WithdrawalTheme.spacingMd),
          Material(
            color: WithdrawalTheme.primary,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusMd),
            child: InkWell(
              onTap: () => controller.loadAllWithdrawals(),
              borderRadius: BorderRadius.circular(WithdrawalTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(WithdrawalTheme.spacingMd),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalsList() {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return Column(
          children: List.generate(4, (index) => const WithdrawalCardShimmer()),
        );
      }

      final withdrawals = controller.filteredWithdrawals;

      if (withdrawals.isEmpty) {
        return const WithdrawalEmptyState();
      }

      return Column(
        children: withdrawals.map((w) => _buildPremiumCard(w)).toList(),
      );
    });
  }

  Widget _buildPremiumCard(Withdrawal withdrawal) {
    final statusColor = WithdrawalTheme.getStatusColor(withdrawal.status);
    final statusLightColor = WithdrawalTheme.getStatusLightColor(
      withdrawal.status,
    );
    final statusIcon = WithdrawalTheme.getStatusIcon(withdrawal.status);

    return Container(
      margin: const EdgeInsets.only(bottom: WithdrawalTheme.spacingMd),
      decoration: WithdrawalTheme.premiumCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Shop Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: WithdrawalTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusMd,
                    ),
                    boxShadow: WithdrawalTheme.shadowColored(
                      WithdrawalTheme.primary,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (withdrawal.shop?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: WithdrawalTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        withdrawal.shop?.name ?? 'Unknown Shop',
                        style: WithdrawalTheme.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.formatDate(withdrawal.createdAt),
                        style: WithdrawalTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WithdrawalTheme.spacingMd,
                    vertical: WithdrawalTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: statusLightColor,
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusXl,
                    ),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        withdrawal.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WithdrawalTheme.spacingLg),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WithdrawalTheme.border.withValues(alpha: 0),
                    WithdrawalTheme.border.withValues(alpha: 0.5),
                    WithdrawalTheme.border.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: WithdrawalTheme.spacingLg),
            // Amount and Actions Row
            Row(
              children: [
                // Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AMOUNT', style: WithdrawalTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        '\$${withdrawal.amount}',
                        style: WithdrawalTheme.amountLarge.copyWith(
                          color: WithdrawalTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date

                // Actions
                if (withdrawal.status == 'pending') ...[
                  _buildActionButton(
                    onTap:
                        () => controller.updateWithdrawalStatus(
                          withdrawal,
                          'approved',
                        ),
                    icon: Icons.check_rounded,
                    color: WithdrawalTheme.approved,
                    tooltip: 'Approve',
                  ),
                  const SizedBox(width: WithdrawalTheme.spacingSm),
                  _buildActionButton(
                    onTap:
                        () => controller.updateWithdrawalStatus(
                          withdrawal,
                          'rejected',
                        ),
                    icon: Icons.close_rounded,
                    color: WithdrawalTheme.rejected,
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(WithdrawalTheme.spacingMd),
        decoration: WithdrawalTheme.cardDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPaginationButton(
              icon: Icons.chevron_left_rounded,
              enabled: controller.currentPage.value > 1,
              onTap:
                  () => controller.loadAllWithdrawals(
                    page: controller.currentPage.value - 1,
                  ),
            ),
            const SizedBox(width: WithdrawalTheme.spacingMd),
            ...List.generate(
              controller.totalPages.value > 5 ? 5 : controller.totalPages.value,
              (index) {
                final page = index + 1;
                final isActive = page == controller.currentPage.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildPageNumber(page, isActive),
                );
              },
            ),
            const SizedBox(width: WithdrawalTheme.spacingMd),
            _buildPaginationButton(
              icon: Icons.chevron_right_rounded,
              enabled:
                  controller.currentPage.value < controller.totalPages.value,
              onTap:
                  () => controller.loadAllWithdrawals(
                    page: controller.currentPage.value + 1,
                  ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          enabled
              ? WithdrawalTheme.primary.withValues(alpha: 0.1)
              : WithdrawalTheme.surfaceSecondary,
      borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color:
                enabled
                    ? WithdrawalTheme.primary
                    : WithdrawalTheme.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumber(int page, bool isActive) {
    return Material(
      color: isActive ? WithdrawalTheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
      child: InkWell(
        onTap: () => controller.loadAllWithdrawals(page: page),
        borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Text(
            '$page',
            style: TextStyle(
              color: isActive ? Colors.white : WithdrawalTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Super Elegant User Withdrawals Screen
class UserWithdrawalsScreen extends StatelessWidget {
  final WithdrawalController controller = Get.put(WithdrawalController());

  UserWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WithdrawalTheme.background,
      appBar: _buildPremiumAppBar(),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllWithdrawals(),
        color: WithdrawalTheme.primary,
        backgroundColor: WithdrawalTheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: WithdrawalTheme.spacingXl),
              _buildWithdrawalForm(),
              const SizedBox(height: WithdrawalTheme.spacingXl),
              _buildSectionHeader(),
              const SizedBox(height: WithdrawalTheme.spacingMd),
              _buildWithdrawalsTable(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: WithdrawalTheme.headerGradient,
        ),
      ),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: const [AdminAppBarActionsSimple()],
      title: const Row(
        children: [
          Text(
            'My Withdrawals',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingXl),
      decoration: BoxDecoration(
        gradient: WithdrawalTheme.headerGradient,
        borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
        boxShadow: WithdrawalTheme.shadowLg,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(WithdrawalTheme.radiusLg),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: WithdrawalTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdraw Funds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Request withdrawals from your shop balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingXl),
      decoration: WithdrawalTheme.glassDecoration,
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(WithdrawalTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: WithdrawalTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: WithdrawalTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: WithdrawalTheme.spacingMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Withdrawal Request',
                      style: WithdrawalTheme.headingSmall.copyWith(
                        color: WithdrawalTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Enter the amount you wish to withdraw',
                      style: WithdrawalTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: WithdrawalTheme.spacingXl),
            TextFormField(
              controller: controller.amountController,
              decoration: WithdrawalTheme.inputDecoration(
                hintText: 'Enter amount',
                labelText: 'Amount',
                prefixIcon: Icons.attach_money_rounded,
              ),
              keyboardType: TextInputType.number,
              validator: controller.validateAmount,
              style: WithdrawalTheme.bodyLarge,
            ),
            const SizedBox(height: WithdrawalTheme.spacingLg),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient:
                        controller.isSubmitting.value
                            ? null
                            : WithdrawalTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusMd,
                    ),
                    boxShadow:
                        controller.isSubmitting.value
                            ? null
                            : WithdrawalTheme.shadowColored(
                              WithdrawalTheme.primary,
                            ),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        controller.isSubmitting.value
                            ? null
                            : controller.createWithdrawal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: WithdrawalTheme.spacingLg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusMd,
                        ),
                      ),
                    ),
                    child:
                        controller.isSubmitting.value
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: WithdrawalTheme.primary,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 20),
                                SizedBox(width: WithdrawalTheme.spacingSm),
                                Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(WithdrawalTheme.spacingSm),
          decoration: BoxDecoration(
            color: WithdrawalTheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: WithdrawalTheme.secondary,
            size: 20,
          ),
        ),
        const SizedBox(width: WithdrawalTheme.spacingMd),
        const Text('Transaction History', style: WithdrawalTheme.headingMedium),
        const Spacer(),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: WithdrawalTheme.spacingMd,
              vertical: WithdrawalTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: WithdrawalTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
            ),
            child: Text(
              '${controller.filteredUserWithdrawals.length} records',
              style: const TextStyle(
                color: WithdrawalTheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalsTable() {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const WithdrawalTableShimmer(rowCount: 4);
      }

      final withdrawals = controller.filteredUserWithdrawals;

      if (withdrawals.isEmpty) {
        return const WithdrawalEmptyState(
          title: 'No transactions yet',
          subtitle: 'Your withdrawal history will appear here',
          icon: Icons.receipt_long_outlined,
        );
      }

      return Container(
        decoration: WithdrawalTheme.premiumCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: WithdrawalTheme.spacingLg,
                vertical: WithdrawalTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WithdrawalTheme.primary.withValues(alpha: 0.08),
                    WithdrawalTheme.primary.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('AMOUNT', style: WithdrawalTheme.labelMedium),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('STATUS', style: WithdrawalTheme.labelMedium),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('DATE', style: WithdrawalTheme.labelMedium),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
            // Table Rows
            ...withdrawals.asMap().entries.map(
              (entry) => _buildTableRow(entry.value, entry.key),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableRow(Withdrawal withdrawal, int index) {
    final statusColor = WithdrawalTheme.getStatusColor(withdrawal.status);
    final statusLightColor = WithdrawalTheme.getStatusLightColor(
      withdrawal.status,
    );
    final statusIcon = WithdrawalTheme.getStatusIcon(withdrawal.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WithdrawalTheme.spacingLg,
        vertical: WithdrawalTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color:
            index % 2 == 0
                ? WithdrawalTheme.surface
                : WithdrawalTheme.surfaceSecondary.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: WithdrawalTheme.border.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Amount
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(WithdrawalTheme.spacingXs),
                  decoration: BoxDecoration(
                    color: WithdrawalTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusXs,
                    ),
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: WithdrawalTheme.secondary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: WithdrawalTheme.spacingSm),
                Text(
                  '\$${withdrawal.amount}',
                  style: WithdrawalTheme.headingSmall.copyWith(
                    color: WithdrawalTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: WithdrawalTheme.spacingMd,
                vertical: WithdrawalTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: statusLightColor,
                borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    withdrawal.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: WithdrawalTheme.textTertiary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.formatDate(withdrawal.createdAt),
                  style: WithdrawalTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Delete Action
          Material(
            color: WithdrawalTheme.rejected.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
            child: InkWell(
              onTap: () => controller.deleteWithdrawal(withdrawal.id),
              borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: WithdrawalTheme.rejected,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
