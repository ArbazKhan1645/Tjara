import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/admin/products_attributes_group/model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class AttributeGroupService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  // Get all attribute groups
  Future<List<AttributeGroupModel>> getAttributeGroups() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/product-attribute-group?_t=${DateTime.now().microsecondsSinceEpoch}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => AttributeGroupModel.fromJson(json))
              .toList();
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception(
          'Failed to load attribute groups: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  // Get all product attributes
  Future<List<ProductAttribute>> getProductAttributes({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product-attributes?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['product_attributes'] != null) {
          return (data['product_attributes'] as List)
              .map((json) => ProductAttribute.fromJson(json))
              .toList();
        }
        return [];
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to load attributes: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  // Create new attribute group
  Future<bool> createAttributeGroup({
    required String name,
    required List<String> attributeItemIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/product-group/create'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'X-Request-From': 'Dashboard',
        },
        body: {
          'name': name,
          for (int i = 0; i < attributeItemIds.length; i++)
            'attribute_item_ids[$i]': attributeItemIds[i],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  // Update attribute group
  Future<bool> updateAttributeGroup({
    required String slug,
    required String name,
    required List<String> attributeItemIds,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/product-attribute-group/$slug/update'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'X-Request-From': 'Dashboard',
        },
        body: {
          'name': name,
          for (int i = 0; i < attributeItemIds.length; i++)
            'attribute_item_ids[$i]': attributeItemIds[i],
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (response.statusCode == 404) {
        throw Exception('Attribute group not found');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to update group: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  // Delete attribute group
  Future<bool> deleteAttributeGroup(String slug) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/product-attribute-group/$slug/delete'),
        headers: {
          'Content-Type': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 404) {
        throw Exception('Attribute group not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to delete group: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
