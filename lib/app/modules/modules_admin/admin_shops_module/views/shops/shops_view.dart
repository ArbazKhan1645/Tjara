import 'package:flutter/material.dart';

import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/admin/myshop/view.dart';

import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/shops/controllers/shop_controller.dart';

class ShopView extends StatefulWidget {
  const ShopView({super.key});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  final ShopController controller = Get.put(ShopController());

  String formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return "*";
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return 'S';
    final List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(gradient: expandedStackGradient),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchFilters(),
                    const SizedBox(height: 24),
                    _buildDataTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shops Overview',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search & Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildStyledSearchField(
                'Shop Name',
                Icons.store_outlined,
                controller.ShopNameController.value,
                (value) => _performSearch(),
              ),
              const SizedBox(height: 12),
              _buildStyledSearchField(
                'Owner Name',
                Icons.person_outline,
                controller.OwnerNameController.value,
                (value) => _performSearch(),
              ),
              const SizedBox(height: 12),
              _buildStyledSearchField(
                'Owner Email',
                Icons.email_outlined,
                controller.OwnerEmailController.value,
                (value) => _performSearch(),
              ),
              const SizedBox(height: 12),
              _buildStyledSearchField(
                'Owner Phone',
                Icons.phone_outlined,
                controller.OwnerPhoneController.value,
                (value) => _performSearch(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return _buildFilterDropdown(
                        label: 'Verification',
                        value: controller.verificationFilter.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Shops'),
                          ),
                          DropdownMenuItem(
                            value: 'verified',
                            child: Text('Verified'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setVerificationFilter(value);
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      return _buildFilterDropdown(
                        label: 'Status',
                        value: controller.statusFilter.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          controller.setStatusFilter(value!);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this new helper method to build filter dropdowns
  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF64748B),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(
    String hint,
    IconData icon,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  // Styled large search field like the provided image
  Widget _buildStyledSearchField(
    String hint,
    IconData icon,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left colored icon block
          Container(
            height: 56,
            width: 55,
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 22)),
          ),
          // Text field part
          Expanded(
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF5F6368),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Obx(() {
            if (controller.loading.value) {
              return const Center(
                child: LinearProgressIndicator(color: Color(0xFF3B82F6)),
              );
            }

            if ((controller.shopInfo.value.shops?.data ?? []).isEmpty) {
              return const Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    'No Shops Found of Search Filter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }

            return _buildShopsDataTable();
          }),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.store, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Shop Management',
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

  Widget _buildShopsDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: Get.width - 48, // Account for horizontal padding
        ),
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 80,
          columnSpacing: 20,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
          headingRowColor: WidgetStateProperty.all(Colors.teal),
          columns: const [
            DataColumn(label: SizedBox(width: 200, child: Text('Shop'))),
            DataColumn(label: SizedBox(width: 180, child: Text('Owner'))),
            DataColumn(label: SizedBox(width: 100, child: Text('Balance'))),
            DataColumn(label: SizedBox(width: 100, child: Text('Status'))),
            DataColumn(label: SizedBox(width: 120, child: Text('Created'))),
            DataColumn(label: SizedBox(width: 100, child: Text('Actions'))),
          ],
          rows:
              (controller.shopInfo.value.shops?.data ?? []).asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final shop = entry.value;
                final isEven = index % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.all(
                    isEven ? Colors.white : const Color(0xFFF8FAFC),
                  ),
                  cells: [
                    // Shop Cell
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.teal, Colors.teal],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  getInitials(shop.name ?? ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    shop.name ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (shop.isVerified == 1)
                                              ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1)
                                              : const Color(
                                                0xFFF59E0B,
                                              ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      (shop.isVerified == 1)
                                          ? 'Verified'
                                          : 'Pending',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            (shop.isVerified == 1)
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Owner Cell
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${shop.owner?.user?.firstName ?? ''} ${shop.owner?.user?.lastName ?? ''}'
                                  .trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              shop.owner?.user?.email ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              shop.owner?.user?.phone ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Balance Cell
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '\$${shop.balance ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF10B981),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    // Status Cell
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (shop.status?.toLowerCase() == 'active')
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            shop.status ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color:
                                  (shop.status?.toLowerCase() == 'active')
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    // Date Cell
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          formatDate(shop.createdAt ?? ''),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    // Actions Cell
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_outlined,
                                        size: 16,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      SizedBox(width: 8),
                                      Text("Edit Shop"),
                                    ],
                                  ),
                                ),
                                if (shop.isVerified != 1)
                                  const PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: Color(0xFF10B981),
                                        ),
                                        SizedBox(width: 8),
                                        Text("Verify Shop"),
                                      ],
                                    ),
                                  ),
                              ],
                          onSelected: (value) {
                            if (value == 1) {
                              Get.to(
                                () => const MyShopScreen(),
                                arguments: {'shopId': shop.id},
                                preventDuplicates: false,
                              );
                            } else if (value == 2) {
                              _verifyShop(shop);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Obx(() {
        final int currentPage = controller.currentPage.value;
        final int totalPages = controller.totalPages.value;
        final int startPage = controller.calculateStartPage();
        const int visibleButtons = 5;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(
                Icons.arrow_back_ios,
                controller.goToPreviousPage,
                currentPage > 1,
              ),
              const SizedBox(width: 16),
              ...List.generate(visibleButtons, (index) {
                final int page = startPage + index;
                if (page > totalPages) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildPageButton(page, currentPage),
                );
              }),
              const SizedBox(width: 16),
              _buildPaginationButton(
                Icons.arrow_forward_ios,
                controller.goToNextPage,
                currentPage < totalPages,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaginationButton(
    IconData icon,
    VoidCallback? onPressed,
    bool enabled,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          size: 16,
          color: enabled ? const Color(0xFF64748B) : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildPageButton(int page, int currentPage) {
    final isActive = page == currentPage;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF97316) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextButton(
        onPressed: () => controller.goToPage(page),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  void _performSearch() async {
    await controller.getShopData(
      controller.currentPage.toString(),
      controller.ShopNameController.value.text,
      controller.OwnerEmailController.value.text,
      controller.OwnerPhoneController.value.text,
      controller.OwnerNameController.value.text,
    );
  }

  void _editShop(dynamic shop) {
    controller.updateShop(shop?.id ?? "", false, context);
  }

  void _verifyShop(dynamic shop) {
    controller.updateShop(shop?.id ?? "", false, context);
  }
}
