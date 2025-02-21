// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/utils/helpers/api_exceptions.dart';
import 'package:tjara/app/models/products/products_model.dart';

import 'dart:async';

import 'package:tjara/app/repo/network_repository.dart';

void login() async {
  loginUser('user@example.com', 'password123');
  // final NetworkRepository _repository = NetworkRepository();
  // final result = await _repository.postData(
  //     url: 'https://api.tjara.com/api/login',
  //     queryParameters: {
  //       'email': 'user@example.com',
  //       'password': 'password123'
  //     });
}

Future<void> loginUser(String email, String password) async {
  const String url = 'https://api.tjara.com/api/login';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Login Successful: $data");
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}

class ProductService {
  final NetworkRepository _networkRepository;

  ProductService({required NetworkRepository networkRepository})
      : _networkRepository = networkRepository;

  Future<ProductModel> fetchProducts({
    required int currentPage,
    required String orderBy,
    required String order,
    String? filterByColumn,
    String? searchTerm,
    String? categoryFilter,
    String? brandFilter,
    String? modelFilter,
    String? yearFilter,
    String? countryFilter,
    String? stateFilter,
    String? cityFilter,
    double? minPriceFilter,
    double? maxPriceFilter,
    String? slug,
    String? category,
  }) async {
    try {
      // Base API parameters
      final Map<String, dynamic> apiParams = {
        'with': 'thumbnail,shop',
        'filterJoin': 'OR',
        'orderBy': orderBy,
        'order': order,
        'page': currentPage,
        'per_page': 16,
      };

      final List<Map<String, dynamic>> columns = [];
      final List<Map<String, dynamic>> attributes = [];
      final List<Map<String, dynamic>> fields = [];

      // Column Filters Based On URL Parameters
      if (filterByColumn != null) {
        switch (filterByColumn) {
          case 'sale':
            columns.add({'column': 'sale_price', 'value': 1, 'operator': '>'});
            break;
          case 'hot_deals':
            columns.add({'column': 'is_deal', 'value': 1, 'operator': '='});
            break;

          case 'discount':
            columns.add({'column': 'sale_price', 'value': 1, 'operator': '>'});
            columns.add({
              'column': 'product_type',
              'value': 'auction',
              'operator': '!='
            });
            break;
          case 'featured':
            apiParams['orderBy'] = 'is_featured';
            apiParams['order'] = 'desc';
            break;
          case 'auction':
            columns.add({
              'column': 'product_type',
              'value': 'auction',
              'operator': '='
            });
            break;
          case 'featured_cars':
            apiParams['orderBy'] = 'is_featured';
            apiParams['order'] = 'desc';
            break;
        }
      }

      // Price Filters
      if (minPriceFilter != null) {
        columns.add(
            {'column': 'price', 'value': minPriceFilter, 'operator': '>='});
        if (minPriceFilter > 0) {
          columns.add({'column': 'price', 'value': '1', 'operator': '>'});
        }
      }
      if (maxPriceFilter != null) {
        columns.add(
            {'column': 'price', 'value': maxPriceFilter, 'operator': '<='});
        if (maxPriceFilter < 100000) {
          columns.add({'column': 'price', 'value': '1', 'operator': '>'});
        }
      }

      // Slug Based Filters
      if (slug != null) {
        switch (slug) {
          case 'cars':
            columns.add(
                {'column': 'product_group', 'value': 'car', 'operator': '='});
            apiParams['product_group'] = 'car';
            break;
          case 'shop':
            columns.add(
                {'column': 'product_group', 'value': 'car', 'operator': '!='});
            break;
        }
      }

      // Status Filter
      columns.add({'column': 'status', 'value': 'active', 'operator': '='});

      // Add Column Filters to API Parameters
      if (columns.isNotEmpty) {
        apiParams['filterByColumns'] = {
          'filterJoin': 'AND',
          'columns': columns,
        };
      }

      // Attribute Filters
      if (categoryFilter != null && categoryFilter != 'products') {
        attributes.add(
            {'key': 'categories', 'value': categoryFilter, 'operator': '='});
      }
      if (brandFilter != null) {
        attributes
            .add({'key': 'brands', 'value': brandFilter, 'operator': '='});
      }
      if (modelFilter != null) {
        attributes
            .add({'key': 'models', 'value': modelFilter, 'operator': '='});
      }
      if (yearFilter != null) {
        attributes.add({'key': 'years', 'value': yearFilter, 'operator': '='});
      }

      // Add Attribute Filters to API Parameters
      if (attributes.isNotEmpty) {
        apiParams['filterByAttributes'] = {
          'filterJoin': 'AND',
          'attributes': attributes,
        };
      }

      // Location Based Filters for Cars
      if (slug == 'cars') {
        if (countryFilter != null) {
          fields.add(
              {'key': 'country_id', 'value': countryFilter, 'operator': '='});
        }
        if (stateFilter != null) {
          fields
              .add({'key': 'state_id', 'value': stateFilter, 'operator': '='});
        }
        if (cityFilter != null) {
          fields.add({'key': 'city_id', 'value': cityFilter, 'operator': '='});
        }
      }

      // Add Field Filters to API Parameters
      if (fields.isNotEmpty) {
        apiParams['filterByMetaFields'] = {
          'filterJoin': 'AND',
          'fields': fields,
        };
      }

      // Search Term
      if (searchTerm != null) {
        apiParams['search'] = searchTerm;
      }

      // Make API call using NetworkRepository
      final response = await _networkRepository.fetchData<ProductModel>(
        url: 'https://api.tjara.com/api/products',
        queryParameters: apiParams,
        fromJson: (json) => ProductModel.fromJson(json),
      );

      return response;
    } catch (e) {
      throw ApiException('Failed to fetch products: $e');
    }
  }
}
