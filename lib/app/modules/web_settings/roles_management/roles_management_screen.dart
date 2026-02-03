import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/roles_management/roles_management_controller.dart';
import 'package:tjara/app/modules/web_settings/roles_management/roles_management_service.dart';

class RolesManagementScreen extends StatelessWidget {
  const RolesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RolesManagementController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: const WebSettingsAppBar(title: 'Roles Management'),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: WebSettingsTheme.primaryColor,
        child: Obx(() {
          if (controller.isLoadingOverview.value && controller.roles.isEmpty) {
            return const _ShimmerLoading();
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                const WebSettingsHeaderCard(
                  title: 'Roles Management',
                  description:
                      'Manage user roles and permissions. Create, edit, and delete roles to control access.',
                  icon: Icons.admin_panel_settings_rounded,
                  badge: 'Admin',
                ),

                // Overview Cards
                _OverviewSection(controller: controller),

                const SizedBox(height: 12),

                // Search & Filter
                _SearchFilterSection(controller: controller),

                const SizedBox(height: 12),

                // Roles List
                _RolesListSection(controller: controller),

                const SizedBox(height: 12),

                // Pagination
                _PaginationSection(controller: controller),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoleDialog(context, controller),
        backgroundColor: WebSettingsTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Role', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showRoleDialog(
    BuildContext context,
    RolesManagementController controller, {
    Role? role,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoleFormSheet(controller: controller, role: role),
    );
  }
}

// ============================================
// Overview Section
// ============================================
class _OverviewSection extends StatelessWidget {
  final RolesManagementController controller;

  const _OverviewSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOverview.value &&
          controller.statistics.value == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final stats = controller.statistics.value;
      if (stats == null) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                value: stats.totalRoles.toString(),
                label: 'Total Roles',
                icon: Icons.badge_rounded,
                color: WebSettingsTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: stats.activeRoles.toString(),
                label: 'Active',
                icon: Icons.check_circle_rounded,
                color: WebSettingsTheme.successColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: stats.systemRoles.toString(),
                label: 'System',
                icon: Icons.security_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: stats.customRoles.toString(),
                label: 'Custom',
                icon: Icons.edit_rounded,
                color: WebSettingsTheme.accentColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

// ============================================
// Search & Filter Section
// ============================================
class _SearchFilterSection extends StatelessWidget {
  final RolesManagementController controller;

  const _SearchFilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search roles...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: WebSettingsTheme.textSecondary,
              ),
              filled: true,
              fillColor: WebSettingsTheme.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: WebSettingsTheme.dividerColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: WebSettingsTheme.dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: WebSettingsTheme.primaryColor,
                ),
              ),
            ),
            onSubmitted: controller.searchRoles,
          ),

          const SizedBox(height: 12),

          // Status Filter Dropdown
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: WebSettingsTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: WebSettingsTheme.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedStatus.value,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: WebSettingsTheme.textSecondary,
                  ),
                  items:
                      controller.statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status == 'all'
                                ? 'All Status'
                                : status.capitalizeFirst!,
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.filterByStatus(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Roles List Section
// ============================================
class _RolesListSection extends StatelessWidget {
  final RolesManagementController controller;

  const _RolesListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRoles.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (controller.rolesError.value != null) {
        return WebSettingsErrorState(
          message: controller.rolesError.value!,
          onRetry: controller.fetchRoles,
        );
      }

      if (controller.roles.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: Column(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 48,
                  color: WebSettingsTheme.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No roles found',
                  style: TextStyle(
                    color: WebSettingsTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return WebSettingsSectionCard(
        padding: EdgeInsets.zero,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.roles.length,
          separatorBuilder:
              (_, __) => const Divider(
                height: 1,
                color: WebSettingsTheme.dividerColor,
              ),
          itemBuilder: (context, index) {
            final role = controller.roles[index];
            return _RoleListTile(
              role: role,
              userCount: controller.getUserCount(role.slug),
              onEdit: () => _showRoleDialog(context, controller, role: role),
              onDelete:
                  () => _showDeleteConfirmation(context, controller, role),
            );
          },
        ),
      );
    });
  }

  void _showRoleDialog(
    BuildContext context,
    RolesManagementController controller, {
    Role? role,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoleFormSheet(controller: controller, role: role),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    RolesManagementController controller,
    Role role,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: WebSettingsTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: WebSettingsTheme.errorColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Delete Role', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: Text('Are you sure you want to delete "${role.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isDeleting.value
                          ? null
                          : () async {
                            final success = await controller.deleteRole(
                              role.id,
                            );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WebSettingsTheme.errorColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      controller.isDeleting.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Delete'),
                ),
              ),
            ],
          ),
    );
  }
}

class _RoleListTile extends StatelessWidget {
  final Role role;
  final int userCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleListTile({
    required this.role,
    required this.userCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & Slug Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.slug,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WebSettingsTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      role.isSystemRole
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                          : WebSettingsTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role.isSystemRole ? 'System' : 'Custom',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        role.isSystemRole
                            ? const Color(0xFF8B5CF6)
                            : WebSettingsTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            role.description,
            style: const TextStyle(
              fontSize: 13,
              color: WebSettingsTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Bottom Row: Permissions, Status, Users, Actions
          Row(
            children: [
              // Permissions Count
              _InfoChip(
                label: '${role.permissions.length} permissions',
                icon: Icons.security_rounded,
                color: WebSettingsTheme.primaryColor,
              ),

              const SizedBox(width: 8),

              // Status
              _InfoChip(
                label: role.status,
                icon:
                    role.status == 'active'
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                color:
                    role.status == 'active'
                        ? WebSettingsTheme.successColor
                        : WebSettingsTheme.textSecondary,
              ),

              const SizedBox(width: 8),

              // Users Count
              _InfoChip(
                label: '$userCount users',
                icon: Icons.people_rounded,
                color: const Color(0xFF8B5CF6),
              ),

              const Spacer(),

              // Actions
              Container(
                decoration: BoxDecoration(
                  color: WebSettingsTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      iconSize: 18,
                      color: WebSettingsTheme.primaryColor,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 18,
                      color: WebSettingsTheme.errorColor,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Pagination Section
// ============================================
class _PaginationSection extends StatelessWidget {
  final RolesManagementController controller;

  const _PaginationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.lastPage.value <= 1) return const SizedBox();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: WebSettingsTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: WebSettingsTheme.dividerColor),
              ),
              child: IconButton(
                onPressed:
                    controller.currentPage.value > 1
                        ? () => controller.goToPage(
                          controller.currentPage.value - 1,
                        )
                        : null,
                icon: const Icon(Icons.chevron_left_rounded),
                color: WebSettingsTheme.textPrimary,
                disabledColor: WebSettingsTheme.textSecondary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Page ${controller.currentPage.value} of ${controller.lastPage.value}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: WebSettingsTheme.textPrimary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: WebSettingsTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: WebSettingsTheme.dividerColor),
              ),
              child: IconButton(
                onPressed:
                    controller.currentPage.value < controller.lastPage.value
                        ? () => controller.goToPage(
                          controller.currentPage.value + 1,
                        )
                        : null,
                icon: const Icon(Icons.chevron_right_rounded),
                color: WebSettingsTheme.textPrimary,
                disabledColor: WebSettingsTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ============================================
// Role Form Sheet (Create/Edit)
// ============================================
class _RoleFormSheet extends StatefulWidget {
  final RolesManagementController controller;
  final Role? role;

  const _RoleFormSheet({required this.controller, this.role});

  @override
  State<_RoleFormSheet> createState() => _RoleFormSheetState();
}

class _RoleFormSheetState extends State<_RoleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'active';
  final Set<String> _selectedPermissions = {};

  bool get isEditMode => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _descriptionController.text = widget.role!.description;
      _status = widget.role!.status;
      _selectedPermissions.addAll(widget.role!.permissions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: WebSettingsTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: WebSettingsTheme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: WebSettingsTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isEditMode ? Icons.edit_rounded : Icons.add_rounded,
                    color: WebSettingsTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isEditMode ? 'Edit Role' : 'Create New Role',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: WebSettingsTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: WebSettingsTheme.textSecondary,
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Name
                    WebSettingsTextField(
                      label: 'Role Name *',
                      controller: _nameController,
                      hint: 'Enter role name',
                    ),

                    const SizedBox(height: 16),

                    // Description
                    WebSettingsTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      hint: 'Enter role description',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Status
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: WebSettingsTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: WebSettingsTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: WebSettingsTheme.dividerColor,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _status,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: WebSettingsTheme.textSecondary,
                          ),
                          items: const [
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
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Permissions
                    Row(
                      children: [
                        const Text(
                          'Permissions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WebSettingsTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: WebSettingsTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Selected: ${_selectedPermissions.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: WebSettingsTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Permissions List
                    _buildPermissionsList(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: WebSettingsTheme.dividerColor),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: WebSettingsOutlinedButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => WebSettingsPrimaryButton(
                      label: isEditMode ? 'Update Role' : 'Create Role',
                      isLoading: widget.controller.isSaving.value,
                      onPressed: _submit,
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

  Widget _buildPermissionsList() {
    return Obx(() {
      if (widget.controller.isLoadingPermissions.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(
              color: WebSettingsTheme.primaryColor,
            ),
          ),
        );
      }

      final grouped = widget.controller.groupedPermissions;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: WebSettingsTheme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grouped.length,
          separatorBuilder:
              (_, __) => const Divider(
                height: 1,
                color: WebSettingsTheme.dividerColor,
              ),
          itemBuilder: (context, index) {
            final category = grouped.keys.elementAt(index);
            final permissions = grouped[category]!;

            return Theme(
              data: ThemeData().copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: WebSettingsTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        size: 16,
                        color: WebSettingsTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                initiallyExpanded: false,
                children:
                    permissions.map((permission) {
                      final isSelected = _selectedPermissions.contains(
                        permission.key,
                      );
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedPermissions.remove(permission.key);
                            } else {
                              _selectedPermissions.add(permission.key);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? WebSettingsTheme.primaryColor
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? WebSettingsTheme.primaryColor
                                            : WebSettingsTheme.dividerColor,
                                    width: 2,
                                  ),
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  permission.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: WebSettingsTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      );
    });
  }

  void _submit() async {
    if (_nameController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter role name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: WebSettingsTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    bool success;
    if (isEditMode) {
      success = await widget.controller.updateRole(
        id: widget.role!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _status,
        permissions: _selectedPermissions.toList(),
      );
    } else {
      success = await widget.controller.createRole(
        name: _nameController.text,
        description: _descriptionController.text,
        status: _status,
        permissions: _selectedPermissions.toList(),
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

/// Shimmer Loading Widget
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
