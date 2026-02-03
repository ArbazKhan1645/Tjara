import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/roles_management/roles_management_service.dart';

class RolesManagementController extends GetxController {
  // Loading states
  var isLoadingOverview = true.obs;
  var isLoadingRoles = true.obs;
  var isLoadingPermissions = true.obs;
  var isSaving = false.obs;
  var isDeleting = false.obs;

  // Error messages
  var overviewError = Rxn<String>();
  var rolesError = Rxn<String>();

  // Statistics
  var statistics = Rxn<RolesStatistics>();

  // Roles list
  var roles = <Role>[].obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var totalRoles = 0.obs;

  // Available permissions
  var availablePermissions = <Permission>[].obs;

  // Search and filter
  final searchController = TextEditingController();
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;

  // Role assignments map (slug -> user count)
  var roleUserCounts = <String, int>{}.obs;

  // Status options
  final statusOptions = ['all', 'active', 'inactive'];

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load all data on init
  Future<void> _loadAllData() async {
    await Future.wait([
      fetchOverview(),
      fetchRoles(),
      fetchPermissions(),
    ]);
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await _loadAllData();
  }

  /// Fetch overview statistics
  Future<void> fetchOverview() async {
    isLoadingOverview.value = true;
    overviewError.value = null;

    try {
      final response = await RolesManagementService.fetchOverview();

      if (response.success && response.statistics != null) {
        statistics.value = response.statistics;

        // Build user counts map
        roleUserCounts.clear();
        for (var assignment in response.statistics!.roleAssignments) {
          roleUserCounts[assignment.slug] = assignment.userCount;
        }
      } else {
        overviewError.value = response.error;
      }
    } catch (e) {
      overviewError.value = 'Error: $e';
    } finally {
      isLoadingOverview.value = false;
    }
  }

  /// Fetch roles list
  Future<void> fetchRoles({int page = 1}) async {
    isLoadingRoles.value = true;
    rolesError.value = null;

    try {
      final response = await RolesManagementService.fetchRoles(
        page: page,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value,
      );

      if (response.success) {
        roles.value = response.roles;
        currentPage.value = response.currentPage;
        lastPage.value = response.lastPage;
        totalRoles.value = response.total;
      } else {
        rolesError.value = response.error;
      }
    } catch (e) {
      rolesError.value = 'Error: $e';
    } finally {
      isLoadingRoles.value = false;
    }
  }

  /// Fetch available permissions
  Future<void> fetchPermissions() async {
    isLoadingPermissions.value = true;

    try {
      final response = await RolesManagementService.fetchPermissions();

      if (response.success) {
        availablePermissions.value = response.permissions;
      }
    } catch (e) {
      // Silent fail for permissions
    } finally {
      isLoadingPermissions.value = false;
    }
  }

  /// Search roles
  void searchRoles(String query) {
    searchQuery.value = query;
    fetchRoles();
  }

  /// Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchRoles();
  }

  /// Go to page
  void goToPage(int page) {
    if (page >= 1 && page <= lastPage.value) {
      fetchRoles(page: page);
    }
  }

  /// Create role
  Future<bool> createRole({
    required String name,
    required String description,
    required String status,
    required List<String> permissions,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final response = await RolesManagementService.createRole(
        name: name,
        description: description,
        status: status,
        permissions: permissions,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await refreshData();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create role: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update role
  Future<bool> updateRole({
    required String id,
    required String name,
    required String description,
    required String status,
    required List<String> permissions,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final response = await RolesManagementService.updateRole(
        id: id,
        name: name,
        description: description,
        status: status,
        permissions: permissions,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await refreshData();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update role: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete role
  Future<bool> deleteRole(String id) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;

    try {
      final response = await RolesManagementService.deleteRole(id);

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await refreshData();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete role: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Get user count for a role
  int getUserCount(String slug) {
    return roleUserCounts[slug] ?? 0;
  }

  /// Get permissions grouped by category
  Map<String, List<Permission>> get groupedPermissions {
    final grouped = <String, List<Permission>>{};

    for (var permission in availablePermissions) {
      final category = permission.categoryName;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(permission);
    }

    return grouped;
  }
}
