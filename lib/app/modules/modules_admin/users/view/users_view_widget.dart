import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/buttons/gardient_button_with_left_arrow_and_text.dart';
import 'package:tjara/app/modules/modules_admin/users/insert/insert_user.dart';
import 'package:tjara/app/modules/modules_admin/users/view/users_stastics.dart';
import 'package:tjara/app/modules/modules_admin/users/view/users_widget.dart';
import 'package:tjara/app/services/dashbopard_services/users_service.dart';

class UsersViewWidget extends StatelessWidget {
  final bool isAppBarExpanded;
  final AdminUsersService adminProductsService;

  const UsersViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminProductsService,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => adminProductsService.refreshData(),
      child: CustomScrollView(
        slivers: [
          AdminSliverAppBarWidget(
            title: 'Dashboard',
            isAppBarExpanded: isAppBarExpanded,
            actions: const [AdminAppBarActions()],
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                AdminHeaderAnimatedBackgroundWidget(
                  isAppBarExpanded: isAppBarExpanded,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const UserAnalyticsWidget(),
                      const SizedBox(height: 12),
                      _buildAdvancedSearchSection(context),
                      const SizedBox(height: 16),
                      UsersContextsList(
                        adminProductsService: adminProductsService,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            // ✅ FIXED: Separate Obx for observable variable
            Obx(
              () => Text(
                '${adminProductsService.totalItems.value} users',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradientButtonWithLeftArrowAndText(
                label: 'Add New User',
                icon: Icons.person_add_outlined,
                onPressed: () {
                  Get.to(
                    () => const InsertNewUser(),
                    preventDuplicates: false,
                  )?.then((c) {
                    Get.find<AdminUsersService>().refreshData();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAdvancedSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              Icon(Icons.tune, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Advanced Search & Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Basic Search Fields Row 1
          Row(
            children: [
              Expanded(child: _buildUserIdField()),
              const SizedBox(width: 12),
              Expanded(child: _buildBasicSearchField()),
            ],
          ),
          const SizedBox(height: 12),

          // Basic Search Fields Row 2
          Row(
            children: [
              Expanded(child: _buildEmailField()),
              const SizedBox(width: 12),
              Expanded(child: _buildPhoneField()),
            ],
          ),
          const SizedBox(height: 16),

          // Status and Role Dropdowns
          Row(
            children: [
              Expanded(child: _buildStatusDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildRoleDropdown()),
            ],
          ),
          const SizedBox(height: 12),

          // Email Verification and Acquisition Source
          Row(
            children: [
              Expanded(child: _buildEmailVerificationDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildAcquisitionSourceDropdown()),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range Section
          _buildDateRangeSection(),
          const SizedBox(height: 16),

          // Custom Filters Section
          _buildCustomFiltersSection(),
          const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons(),

          const SizedBox(height: 8),
          _buildSearchStatus(),
        ],
      ),
    );
  }

  Widget _buildUserIdField() {
    return _buildTextField(
      controller: adminProductsService.userIdController,
      hintText: 'User ID',
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildBasicSearchField() {
    return _buildTextField(
      controller: adminProductsService.searchController,
      hintText: 'Search by ...',
      prefixIcon: Icons.search_outlined,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: adminProductsService.emailController,
      hintText: 'Email addr...',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: adminProductsService.phoneController,
      hintText: 'Phone nu...',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey[500], size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // ✅ FIXED: Each dropdown has its own Obx
  Widget _buildStatusDropdown() {
    return Obx(
      () => _buildDropdown(
        value: adminProductsService.selectedStatus.value,
        items: const ['All Status', 'active', 'inactive', 'pending'],
        hint: 'Status',
        icon: Icons.check_circle_outline,
        onChanged:
            (value) =>
                adminProductsService.selectedStatus.value =
                    value ?? 'All Status',
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Obx(
      () => _buildDropdown(
        value: adminProductsService.selectedRole.value,
        items: const ['All Roles', 'customer', 'admin', 'vendor'],
        hint: 'Role',
        icon: Icons.people_outline,
        onChanged:
            (value) =>
                adminProductsService.selectedRole.value = value ?? 'All Roles',
      ),
    );
  }

  Widget _buildEmailVerificationDropdown() {
    return Obx(
      () => _buildDropdown(
        value: adminProductsService.selectedEmailVerification.value,
        items: const ['All Users', 'verified', 'unverified'],
        hint: 'Email Status',
        icon: Icons.verified_outlined,
        onChanged:
            (value) =>
                adminProductsService.selectedEmailVerification.value =
                    value ?? 'All Users',
      ),
    );
  }

  Widget _buildAcquisitionSourceDropdown() {
    return Obx(
      () => _buildDropdown(
        value: adminProductsService.selectedAcquisitionSource.value,
        items: const [
          'All Sources',
          'google',
          'fb',
          'organic',
          'linkedin',
          'referral',
          'direct',
        ],
        hint: 'Acquisition Source',
        icon: Icons.source_outlined,
        onChanged:
            (value) =>
                adminProductsService.selectedAcquisitionSource.value =
                    value ?? 'All Sources',
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        dropdownColor: Colors.white,
        menuMaxHeight: 200,
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                controller: adminProductsService.fromDateController,
                hintText: 'From Date',
                icon: Icons.date_range_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                controller: adminProductsService.toDateController,
                hintText: 'To Date',
                icon: Icons.date_range_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: Get.context!,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            controller.text =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildCustomFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Filters',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: adminProductsService.referralCodeController,
                hintText: 'Referral C...',
                prefixIcon: Icons.code_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildOrderByDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderByDropdown() {
    return Obx(
      () => _buildDropdown(
        value: adminProductsService.selectedOrderBy.value,
        items: const [
          'created_at',
          'updated_at',
          'first_name',
          'last_name',
          'email',
        ],
        hint: 'Order By',
        icon: Icons.sort_outlined,
        onChanged:
            (value) =>
                adminProductsService.selectedOrderBy.value =
                    value ?? 'created_at',
      ),
    );
  }

  // ✅ FIXED: Single Obx with proper observable access
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Obx(
            () => ElevatedButton(
              onPressed:
                  adminProductsService.isSearching.value
                      ? null
                      : () => adminProductsService.performAdvancedSearch(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child:
                  adminProductsService.isSearching.value
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
                      : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => adminProductsService.clearAdvancedFilters(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear, size: 16),
                SizedBox(width: 4),
                Text('Clear All', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Single Obx with all observables accessed properly
  Widget _buildSearchStatus() {
    return Obx(() {
      if (!adminProductsService.hasActiveAdvancedFilters) {
        return const SizedBox.shrink();
      }

      final activeFilters = adminProductsService.activeFiltersList;
      final filterCount = adminProductsService.activeFilterCount;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  '$filterCount Active Filter${filterCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => adminProductsService.clearAdvancedFilters(),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            if (activeFilters.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    activeFilters.take(3).map((filter) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              if (activeFilters.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '... and ${activeFilters.length - 3} more',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }
}
