import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer: ^3.0.0 to pubspec.yaml
import 'dart:convert';
import 'dart:async';

import 'package:tjara/app/models/transactions/transactions_model.dart';

class TransactionController extends GetxController {
  var transactions = <DataTransactions?>[].obs;
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var selectedFilter = 'All'.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = false.obs;

  final filterOptions = ['All', 'Successful', 'Failed', 'Pending'];
  Timer? _debounceTimer;

  @override
  void onInit() {
    fetchTransactions();
    super.onInit();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchTransactions({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
      } else if (!isRefresh && currentPage.value == 1) {
        isLoading.value = true;
      }

      final url = Uri.parse(
        'https://api.libanbuy.com/api/transactions?page=${currentPage.value}',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-Request-From': 'Application',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        final TransactionModel data = TransactionModel.fromJson(
          json.decode(response.body),
        );

        final newTransactions =
            (data.transactions?.data as List?)?.cast<DataTransactions?>() ?? [];

        if (isRefresh || currentPage.value == 1) {
          transactions.value = newTransactions;
        } else {
          transactions.addAll(newTransactions);
        }

        // Update pagination info (adjust based on your API response)
        hasMore.value = newTransactions.isNotEmpty;
        totalPages.value = data.transactions?.total ?? 1;
      } else {
        _showErrorSnackbar(
          "Failed to load transactions (${response.statusCode})",
        );
      }
    } on TimeoutException {
      _showErrorSnackbar("Request timeout. Please try again.");
    } catch (e) {
      _showErrorSnackbar("Network error: ${e.toString()}");
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMore.value || isLoading.value) return;

    currentPage.value++;
    await fetchTransactions();
  }

  Future<void> refreshTransactions() async {
    await fetchTransactions(isRefresh: true);
  }

  void updateFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      _debounceFilterUpdate();
    }
  }

  void _debounceFilterUpdate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // Reset pagination when filter changes
      currentPage.value = 1;
      fetchTransactions(isRefresh: true);
    });
  }

  List<DataTransactions?> get filteredTransactions {
    if (selectedFilter.value == 'All') {
      return transactions;
    }

    return transactions.where((txn) {
      if (txn == null) return false;
      final status = getTransactionStatus(txn).toLowerCase();
      return status.contains(selectedFilter.value.toLowerCase());
    }).toList();
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'successful':
      case 'completed':
      case 'paid':
      case 'success':
        return const Color(0xFF4CAF50);
      case 'failed':
      case 'cancelled':
      case 'error':
        return const Color(0xFFf44336);
      case 'pending':
      case 'processing':
      case 'waiting':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2196F3);
    }
  }

  String getTransactionStatus(DataTransactions? transaction) {
    // Customize this based on your actual data model
    if (transaction?.paymentStatus != null) {
      return transaction!.paymentStatus!;
    }

    // Fallback logic based on amount
    if (transaction?.amount != null && transaction!.amount! > 0) {
      return 'Successful';
    }
    return 'Pending';
  }

  String getPaymentMethod(DataTransactions? transaction) {
    // Customize based on your data model
    return transaction?.paymentMethod ?? 'PayPal';
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}

class TransactionPage extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());

  TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshTransactions,
        color: const Color(0xFFF97316),
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildFilterSection(),
            _buildTransactionsList(),
            _buildPaginationSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF97316),
      elevation: 0,
      actions: [const AdminAppBarActionsSimple()],
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Dashboard',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF97316), Color(0xFFFACC15)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  '${controller.transactions.length} total transactions',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    controller.filterOptions.map((filter) {
                      final isSelected =
                          controller.selectedFilter.value == filter;
                      return FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) => controller.updateFilter(filter),
                        selectedColor: const Color(0xFFF97316).withOpacity(0.2),
                        checkmarkColor: const Color(0xFFF97316),
                        backgroundColor: Colors.grey[100],
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? const Color(0xFFF97316)
                                  : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.transactions.isEmpty) {
                  return _buildShimmerLoading();
                }

                if (controller.filteredTransactions.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildTransactionsTable();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF97316),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Transaction History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(children: List.generate(5, (index) => _buildShimmerItem())),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 120, height: 14, color: Colors.white),
              ],
            ),
          ),
          Container(width: 80, height: 16, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: Get.width - 32, // Account for horizontal padding
        ),
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 60,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            fontSize: 14,
          ),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Customer Name')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Date')),
          ],
          rows:
              controller.filteredTransactions.map((txn) {
                if (txn == null) return const DataRow(cells: []);

                final status = controller.getTransactionStatus(txn);
                final statusColor = controller.getStatusColor(status);
                final paymentMethod = controller.getPaymentMethod(txn);

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '#${txn.id?.toString() ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${(txn.amount ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${txn.buyer?.user?.firstName ?? ''} ${txn.buyer?.user?.lastName ?? ''}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        paymentMethod,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(DateTime.parse(txn.createdAt.toString())),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaginationSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${controller.currentPage.value}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              if (controller.hasMore.value)
                ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.loadMoreTransactions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      controller.isLoading.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Load More'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
