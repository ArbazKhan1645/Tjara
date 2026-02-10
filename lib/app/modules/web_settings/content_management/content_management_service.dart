import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ContentManagementService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'X-Request-From': 'Dashboard',
  };

  static Map<String, String> get _headersWithJson => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Dashboard',
  };

  /// Fetch content management settings
  static Future<SettingsResponse> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/settings?_t=${DateTime.now().microsecondsSinceEpoch}',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final options = data['options'] as Map<String, dynamic>? ?? {};

        return SettingsResponse(
          success: true,
          settings: ContentManagementSettings.fromJson(options),
        );
      } else {
        return SettingsResponse(
          success: false,
          error: 'Failed to fetch settings. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SettingsResponse(success: false, error: 'Network error: $e');
    }
  }

  /// Update settings
  static Future<UpdateResponse> updateSettings(
    Map<String, String> settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/settings/update'),
        headers: _headersWithJson,
        body: jsonEncode(settings),
      );

      final data = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        return UpdateResponse(
          success: true,
          message: data['message'] ?? 'Settings updated successfully',
        );
      } else {
        return UpdateResponse(
          success: false,
          message: data['message'] ?? 'Failed to update settings',
        );
      }
    } catch (e) {
      return UpdateResponse(success: false, message: 'Network error: $e');
    }
  }

  /// Fetch raw settings options as Map
  static Future<RawSettingsResponse> fetchRawSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/settings?_t=${DateTime.now().microsecondsSinceEpoch}',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final options = data['options'] as Map<String, dynamic>? ?? {};

        return RawSettingsResponse(success: true, options: options);
      } else {
        return RawSettingsResponse(
          success: false,
          error: 'Failed to fetch settings. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return RawSettingsResponse(success: false, error: 'Network error: $e');
    }
  }

  // ============================================
  // Categories
  // ============================================
  // Response structure:
  // {
  //   "product_attribute": {
  //     "attribute_items": {
  //       "product_attribute_items": [
  //         { "id": "...", "name": "Truck", "slug": "truck", ... },
  //         ...
  //       ]
  //     }
  //   }
  // }
  // ============================================

  static Future<CategoriesResponse> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product-attributes/categories?limit=all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Return raw body for isolate parsing
        return CategoriesResponse(
          success: true,
          categories: [],
          rawBody: response.body,
        );
      } else {
        return CategoriesResponse(
          success: false,
          error: 'Failed to fetch categories. Status: ${response.statusCode}',
          categories: [],
        );
      }
    } catch (e) {
      return CategoriesResponse(
        success: false,
        error: 'Network error: $e',
        categories: [],
      );
    }
  }

  /// Parse categories from raw JSON body - to be used with compute()
  static List<CategoryItem> parseCategoriesFromJson(String body) {
    try {
      final data = jsonDecode(body);

      // Navigate the nested structure
      final productAttribute =
          data['product_attribute'] as Map<String, dynamic>? ?? {};
      final attributeItems =
          productAttribute['attribute_items'] as Map<String, dynamic>? ?? {};
      final items = attributeItems['product_attribute_items'] as List? ?? [];

      return items.map((c) {
        return CategoryItem(
          id: c['id']?.toString() ?? '',
          name: c['name']?.toString() ?? '',
          slug: c['slug']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // Shops
  // ============================================
  // Search:  GET shops?search=<query>
  //   Response: { "shops": { "data": [ { "id": "...", "name": "..." }, ... ] } }
  //
  // By ID:   GET shops/<id>
  //   Response: { "shop": { "id": "...", "name": "...", ... } }
  // ============================================

  /// Search shops by query string
  static Future<ShopsResponse> searchShops(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/shops?search=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shopsMap = data['shops'] as Map<String, dynamic>? ?? {};
        final shopsData = shopsMap['data'] as List? ?? [];

        final shops =
            shopsData.map((s) {
              return ShopItem(
                id: s['id']?.toString() ?? '',
                name: s['name']?.toString() ?? '',
              );
            }).toList();

        return ShopsResponse(success: true, shops: shops);
      } else {
        return ShopsResponse(
          success: false,
          error: 'Failed to search shops. Status: ${response.statusCode}',
          shops: [],
        );
      }
    } catch (e) {
      return ShopsResponse(
        success: false,
        error: 'Network error: $e',
        shops: [],
      );
    }
  }

  /// Fetch a single shop by its ID
  static Future<ShopItem?> fetchShopById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/shops/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shopData = data['shop'] as Map<String, dynamic>? ?? {};

        return ShopItem(
          id: shopData['id']?.toString() ?? '',
          name: shopData['name']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // Products
  // ============================================

  /// Search products by query
  static Future<ProductsResponse> searchProducts(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/products?search=$query');
      final response = await http.get(uri, headers: _headers);
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productsMap = data['products'] as Map<String, dynamic>? ?? {};
        final productsData = productsMap['data'] as List? ?? [];

        final products =
            productsData.map((p) {
              return ProductItem(
                id: p['id']?.toString() ?? '',
                name: p['name']?.toString() ?? '',
                isFeatured: p['is_featured'],
                isDeal: p['is_deal'],
                salePrice: p['sale_price'],
                productGroup: p['product_group']?.toString() ?? '',
              );
            }).toList();

        return ProductsResponse(success: true, products: products);
      } else {
        return ProductsResponse(
          success: false,
          error: 'Failed to search products. Status: ${response.statusCode}',
          products: [],
        );
      }
    } catch (e) {
      return ProductsResponse(
        success: false,
        error: 'Network error: $e',
        products: [],
      );
    }
  }

  /// Fetch a single product by ID (returns name)
  static Future<ProductItem?> fetchProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final p = data['product'] as Map<String, dynamic>? ?? {};

        return ProductItem(
          id: p['id']?.toString() ?? '',
          name: p['name']?.toString() ?? '',
          isFeatured: p['is_featured'],
          isDeal: p['is_deal'],
          salePrice: p['sale_price'],
          productGroup: p['product_group']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Upload media and return URL
  static Future<MediaUploadResponse> uploadMediaAndGetUrl(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/media/insert');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'X-Request-From': 'Application',
        'Accept': 'application/json',
      });

      for (var file in files) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'media[]',
          stream,
          length,
          filename: path.basename(file.path),
        );

        request.files.add(multipartFile);
      }

      if (directory != null) {
        request.fields['directory'] = directory;
      }
      if (width != null) {
        request.fields['width'] = width.toString();
      }
      if (height != null) {
        request.fields['height'] = height.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final mediaList = jsonData['media'] as List?;

        if (mediaList != null && mediaList.isNotEmpty) {
          final mediaItem = mediaList[0] as Map<String, dynamic>;
          final url =
              mediaItem['url']?.toString() ??
              mediaItem['original_url']?.toString() ??
              '';
          final id = mediaItem['id']?.toString() ?? '';

          return MediaUploadResponse(success: true, url: url, id: id);
        }
        return MediaUploadResponse(
          success: false,
          error: 'No media returned from server',
        );
      } else {
        return MediaUploadResponse(
          success: false,
          error: 'Upload failed. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return MediaUploadResponse(success: false, error: 'Upload error: $e');
    }
  }
}

// ============================================
// Models
// ============================================

class ContentManagementSettings {
  final String allCategoriesImageUrl;
  final String allCategoriesImageId;
  final String websiteFeaturesPromo1;
  final String websiteFeaturesPromo2;
  final String websiteFeaturesPromo3;
  final String websiteFeaturesPromo4;
  final String websiteFeaturesPromoDir;
  final String allProductsNotice;
  final String allProductsNoticeDir;
  final String headerCategories;
  final String shopDiscounts;
  final String featuredProductsSortOrder;
  final String featuredCarsSortOrder;
  final String saleProductsSortOrder;
  final String superDealsProductsSortOrder;

  ContentManagementSettings({
    required this.allCategoriesImageUrl,
    required this.allCategoriesImageId,
    required this.websiteFeaturesPromo1,
    required this.websiteFeaturesPromo2,
    required this.websiteFeaturesPromo3,
    required this.websiteFeaturesPromo4,
    required this.websiteFeaturesPromoDir,
    required this.allProductsNotice,
    required this.allProductsNoticeDir,
    required this.headerCategories,
    required this.shopDiscounts,
    required this.featuredProductsSortOrder,
    required this.featuredCarsSortOrder,
    required this.saleProductsSortOrder,
    required this.superDealsProductsSortOrder,
  });

  factory ContentManagementSettings.fromJson(Map<String, dynamic> json) {
    return ContentManagementSettings(
      allCategoriesImageUrl: json['all_categories_image_url']?.toString() ?? '',
      allCategoriesImageId: json['all_categories_image_id']?.toString() ?? '',
      websiteFeaturesPromo1: json['website_features_promo1']?.toString() ?? '',
      websiteFeaturesPromo2: json['website_features_promo2']?.toString() ?? '',
      websiteFeaturesPromo3: json['website_features_promo3']?.toString() ?? '',
      websiteFeaturesPromo4: json['website_features_promo4']?.toString() ?? '',
      websiteFeaturesPromoDir:
          json['website_features_promo_dir']?.toString() ?? 'ltr',
      allProductsNotice: json['all_products_notice']?.toString() ?? '',
      allProductsNoticeDir:
          json['all_products_notice_dir']?.toString() ?? 'ltr',
      headerCategories: json['header_categories']?.toString() ?? '',
      shopDiscounts: json['shop_discounts']?.toString() ?? '[]',
      featuredProductsSortOrder:
          json['featured_products_sort_order']?.toString() ?? '',
      featuredCarsSortOrder: json['featured_cars_sort_order']?.toString() ?? '',
      saleProductsSortOrder: json['sale_products_sort_order']?.toString() ?? '',
      superDealsProductsSortOrder:
          json['super_deals_products_sort_order']?.toString() ?? '',
    );
  }
}

class CategoryItem {
  final String id;
  final String name;
  final String slug;

  CategoryItem({required this.id, required this.name, required this.slug});
}

class ShopItem {
  final String id;
  final String name;

  ShopItem({required this.id, required this.name});
}

class ProductItem {
  final String id;
  final String name;
  final dynamic isFeatured;
  final dynamic isDeal;
  final dynamic salePrice;
  final String productGroup;

  ProductItem({
    required this.id,
    required this.name,
    this.isFeatured,
    this.isDeal,
    this.salePrice,
    required this.productGroup,
  });
}

class ShopDiscount {
  String shopId;
  String categoryId;
  String discountRange;
  String tooltipText;
  String shippingText;

  ShopDiscount({
    required this.shopId,
    required this.categoryId,
    required this.discountRange,
    required this.tooltipText,
    required this.shippingText,
  });

  factory ShopDiscount.fromJson(Map<String, dynamic> json) {
    return ShopDiscount(
      shopId: json['shop_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      discountRange: json['discount_range']?.toString() ?? '5-10',
      tooltipText: json['tooltip_text']?.toString() ?? '',
      shippingText: json['shipping_text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'category_id': categoryId,
      'discount_range': discountRange,
      'tooltip_text': tooltipText,
      'shipping_text': shippingText,
    };
  }
}

// ============================================
// Response Models
// ============================================

class SettingsResponse {
  final bool success;
  final ContentManagementSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}

class CategoriesResponse {
  final bool success;
  final List<CategoryItem> categories;
  final String? error;
  final String? rawBody; // For isolate parsing

  CategoriesResponse({
    required this.success,
    required this.categories,
    this.error,
    this.rawBody,
  });
}

class ShopsResponse {
  final bool success;
  final List<ShopItem> shops;
  final String? error;

  ShopsResponse({required this.success, required this.shops, this.error});
}

class ProductsResponse {
  final bool success;
  final List<ProductItem> products;
  final String? error;

  ProductsResponse({required this.success, required this.products, this.error});
}

class MediaUploadResponse {
  final bool success;
  final String? url;
  final String? id;
  final String? error;

  MediaUploadResponse({required this.success, this.url, this.id, this.error});
}

class RawSettingsResponse {
  final bool success;
  final Map<String, dynamic>? options;
  final String? error;

  RawSettingsResponse({required this.success, this.options, this.error});
}
