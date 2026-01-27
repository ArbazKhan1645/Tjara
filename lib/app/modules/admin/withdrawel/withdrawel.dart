// models/withdrawal_model.dart
// services/withdrawal_service.dart
// screens/all_withdrawals_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';

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

// Service
class WithdrawalService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  static Future<Map<String, dynamic>> getAllWithdrawals({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/withdrawls?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load withdrawals');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> createWithdrawal({
    required String shopId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/withdrawls/insert/'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
        body: json.encode({'shop_id': shopId, 'amount': amount}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating withdrawal: $e');
    }
  }

  static Future<bool> updateWithdrawal({
    required String id,
    required String shopId,
    required String status,
    required double amount,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/withdrawls/$id/update'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
        body: json.encode({
          'shop_id': shopId,
          'status': status,
          'amount': amount,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating withdrawal: $e');
    }
  }

  static Future<bool> deleteWithdrawal(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/withdrawls/$id/delete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting withdrawal: $e');
    }
  }
}

// Controller
class WithdrawalController extends GetxController {
  static const String staticShopId = '0000c539-9857-3456-bc53-2bbdc1474f1a';

  var isLoading = false.obs;
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

  Future<void> loadAllWithdrawals({int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await WithdrawalService.getAllWithdrawals(page: page);

      if (response['withdrawals'] != null) {
        final List<dynamic> data = response['withdrawals']['data'];
        withdrawals.value =
            data.map((json) => Withdrawal.fromJson(json)).toList();
        currentPage.value = response['withdrawals']['current_page'] ?? 1;
        totalPages.value = response['withdrawals']['last_page'] ?? 1;
        filterUserWithdrawals();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load withdrawals: $e');
    } finally {
      isLoading.value = false;
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
      isLoading.value = true;
      final amount = double.parse(amountController.text);

      final success = await WithdrawalService.createWithdrawal(
        shopId: staticShopId,
        amount: amount,
      );

      if (success) {
        amountController.clear();
        Get.snackbar('Success', 'Withdrawal request created successfully');
        await loadAllWithdrawals();
      } else {
        Get.snackbar('Error', 'Failed to create withdrawal request');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create withdrawal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWithdrawalStatus(
    Withdrawal withdrawal,
    String status,
  ) async {
    try {
      isLoading.value = true;
      final success = await WithdrawalService.updateWithdrawal(
        id: withdrawal.id,
        shopId: withdrawal.shopId,
        status: status,
        amount: double.parse(withdrawal.amount),
      );

      if (success) {
        Get.snackbar('Success', 'Withdrawal $status successfully');
        await loadAllWithdrawals();
      } else {
        Get.snackbar('Error', 'Failed to update withdrawal status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update withdrawal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteWithdrawal(String id) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Withdrawal'),
          content: const Text(
            'Are you sure you want to delete this withdrawal?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;
        final success = await WithdrawalService.deleteWithdrawal(id);

        if (success) {
          Get.snackbar('Success', 'Withdrawal deleted successfully');
          await loadAllWithdrawals();
        } else {
          Get.snackbar('Error', 'Failed to delete withdrawal');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete withdrawal: $e');
    } finally {
      isLoading.value = false;
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

class AllWithdrawalsScreen extends StatelessWidget {
  final WithdrawalController controller = Get.put(WithdrawalController());

  AllWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Withdrawals'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => controller.loadAllWithdrawals(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final withdrawals = controller.filteredWithdrawals;

              if (withdrawals.isEmpty) {
                return const Center(child: Text('No withdrawals found'));
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadAllWithdrawals(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: withdrawals.length,
                  itemBuilder: (context, index) {
                    final withdrawal = withdrawals[index];
                    return _buildWithdrawalCard(withdrawal);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => DropdownButton<String>(
                value: controller.selectedStatus.value,
                isExpanded: true,
                items:
                    ['all', 'pending', 'approved', 'rejected']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          ),
                        )
                        .toList(),
                onChanged: (value) => controller.filterByStatus(value!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(Withdrawal withdrawal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  withdrawal.shop?.name ?? 'Unknown Shop',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(withdrawal.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Amount: \$${withdrawal.amount}'),
            Text('Date: ${_formatDate(withdrawal.createdAt)}'),
            const SizedBox(height: 12),
            if (withdrawal.status == 'pending') _buildActionButtons(withdrawal),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Withdrawal withdrawal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed:
              () => controller.updateWithdrawalStatus(withdrawal, 'approved'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0D9488),
            foregroundColor: Colors.white,
          ),
          child: const Text('Approve'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed:
              () => controller.updateWithdrawalStatus(withdrawal, 'rejected'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// User Screen - User Withdrawals
class UserWithdrawalsScreen extends StatelessWidget {
  final WithdrawalController controller = Get.put(WithdrawalController());

  UserWithdrawalsScreen({super.key});

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
                _buildWithdrawalForm(),
                Expanded(child: _buildDataTable()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PLACE WITHDRAW REQUEST',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff0D9488),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller.amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFF97316),
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: controller.validateAmount,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.createWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Submit',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              labelText: 'Search transactions...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFF97316),
                  width: 2,
                ),
              ),
            ),
            onChanged: controller.updateSearchQuery,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.selectedStatus.value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFF97316),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items:
                        ['all', 'pending', 'approved', 'rejected']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.toUpperCase()),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => controller.filterByStatus(value!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final withdrawals = controller.filteredUserWithdrawals;

      if (withdrawals.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'No withdrawals found',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 70,
            horizontalMargin: 20,
            columns: const [
              DataColumn(
                label: Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Action',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows:
                withdrawals
                    .map((withdrawal) => _buildUserDataRow(withdrawal))
                    .toList(),
          ),
        ),
      );
    });
  }

  DataRow _buildUserDataRow(Withdrawal withdrawal) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            '\$${withdrawal.amount}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ),
        DataCell(_buildStatusChip(withdrawal.status)),
        DataCell(Text(controller.formatDate(withdrawal.createdAt))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => controller.deleteWithdrawal(withdrawal.id),
            tooltip: 'Delete',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
