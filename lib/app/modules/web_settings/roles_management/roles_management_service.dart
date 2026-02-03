import 'dart:convert';
import 'package:http/http.dart' as http;

class RolesManagementService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  /// Fetch roles overview statistics
  static Future<OverviewResponse> fetchOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/roles/statistics/overview'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OverviewResponse(
          success: true,
          statistics: RolesStatistics.fromJson(data['statistics']),
        );
      } else {
        return OverviewResponse(
          success: false,
          error: 'Failed to fetch overview. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return OverviewResponse(success: false, error: 'Network error: $e');
    }
  }

  /// Fetch roles list with pagination
  static Future<RolesListResponse> fetchRoles({
    int page = 1,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{'page': page.toString()};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        '$_baseUrl/roles',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rolesData = data['roles'];

        final roles =
            (rolesData['data'] as List).map((e) => Role.fromJson(e)).toList();

        return RolesListResponse(
          success: true,
          roles: roles,
          currentPage: rolesData['current_page'] ?? 1,
          lastPage: rolesData['last_page'] ?? 1,
          total: rolesData['total'] ?? 0,
        );
      } else {
        return RolesListResponse(
          success: false,
          error: 'Failed to fetch roles',
        );
      }
    } catch (e) {
      return RolesListResponse(success: false, error: 'Network error: $e');
    }
  }

  /// Fetch available permissions
  static Future<PermissionsResponse> fetchPermissions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/roles/permissions/available'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final permissionsMap = data['permissions'] as Map<String, dynamic>;

        final permissions =
            permissionsMap.entries
                .map((e) => Permission(key: e.key, label: e.value.toString()))
                .toList();

        return PermissionsResponse(success: true, permissions: permissions);
      } else {
        return PermissionsResponse(
          success: false,
          error: 'Failed to fetch permissions',
        );
      }
    } catch (e) {
      return PermissionsResponse(success: false, error: 'Network error: $e');
    }
  }

  /// Create a new role
  static Future<ApiResponse> createRole({
    required String name,
    required String description,
    required String status,
    required List<String> permissions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/roles'),
        headers: _headersWithJson,
        body: jsonEncode({
          'name': name,
          'description': description,
          'status': status,
          'permissions': permissions,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Role created successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to create role',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// Update an existing role
  static Future<ApiResponse> updateRole({
    required String id,
    required String name,
    required String description,
    required String status,
    required List<String> permissions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/roles/$id'),
        headers: _headersWithJson,
        body: jsonEncode({
          'name': name,
          'description': description,
          'status': status,
          'permissions': permissions,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Role updated successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to update role',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// Delete a role
  static Future<ApiResponse> deleteRole(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/roles/$id'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Role deleted successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to delete role',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'X-Request-From': 'Website',
  };

  static Map<String, String> get _headersWithJson => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Website',
  };
}

// ============================================
// Models
// ============================================

/// Role Statistics Model
class RolesStatistics {
  final int totalRoles;
  final int activeRoles;
  final int systemRoles;
  final int customRoles;
  final List<RoleAssignment> roleAssignments;

  RolesStatistics({
    required this.totalRoles,
    required this.activeRoles,
    required this.systemRoles,
    required this.customRoles,
    required this.roleAssignments,
  });

  factory RolesStatistics.fromJson(Map<String, dynamic> json) {
    final assignments =
        (json['role_assignments'] as List?)
            ?.map((e) => RoleAssignment.fromJson(e))
            .toList() ??
        [];

    return RolesStatistics(
      totalRoles: json['total_roles'] ?? 0,
      activeRoles: json['active_roles'] ?? 0,
      systemRoles: json['system_roles'] ?? 0,
      customRoles: json['custom_roles'] ?? 0,
      roleAssignments: assignments,
    );
  }
}

/// Role Assignment Model
class RoleAssignment {
  final String name;
  final String slug;
  final int userCount;

  RoleAssignment({
    required this.name,
    required this.slug,
    required this.userCount,
  });

  factory RoleAssignment.fromJson(Map<String, dynamic> json) {
    return RoleAssignment(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      userCount: json['user_count'] ?? 0,
    );
  }
}

/// Role Model
class Role {
  final String id;
  final String name;
  final String slug;
  final String description;
  final List<String> permissions;
  final bool isSystemRole;
  final String status;
  final String createdAt;
  final String updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.permissions,
    required this.isSystemRole,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      isSystemRole: json['is_system_role'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  int get userCount => 0; // Will be updated from statistics
}

/// Permission Model
class Permission {
  final String key;
  final String label;

  Permission({required this.key, required this.label});

  /// Get category from permission key (e.g., "users" from "users.view")
  String get category {
    final parts = key.split('.');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return 'other';
  }

  /// Get formatted category name
  String get categoryName {
    final cat = category;
    return '${cat[0].toUpperCase()}${cat.substring(1)} Management';
  }
}

// ============================================
// Response Models
// ============================================

class OverviewResponse {
  final bool success;
  final RolesStatistics? statistics;
  final String? error;

  OverviewResponse({required this.success, this.statistics, this.error});
}

class RolesListResponse {
  final bool success;
  final List<Role> roles;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? error;

  RolesListResponse({
    required this.success,
    this.roles = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.error,
  });
}

class PermissionsResponse {
  final bool success;
  final List<Permission> permissions;
  final String? error;

  PermissionsResponse({
    required this.success,
    this.permissions = const [],
    this.error,
  });
}

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});
}
