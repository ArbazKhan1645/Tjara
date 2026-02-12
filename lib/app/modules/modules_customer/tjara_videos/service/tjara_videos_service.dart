import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class TjaraVideosService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  // --- Preload cache for instant video screen ---
  static List<VideoProduct> _preloadedCache = [];
  static bool _isPreloading = false;

  /// Preload first 3 videos in background (called from home section widget)
  static Future<void> preloadVideos() async {
    if (_isPreloading || _preloadedCache.isNotEmpty) return;
    _isPreloading = true;
    try {
      final response = await fetchVideoProducts(page: 1, perPage: 3);
      _preloadedCache = response.videos;
    } catch (e) {
      debugPrint('TjaraVideosService.preloadVideos error: $e');
    } finally {
      _isPreloading = false;
    }
  }

  static List<VideoProduct> get preloadedVideos => _preloadedCache;

  static Map<String, String> _headers({bool withUserId = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-From': 'Application',
    };
    if (withUserId) {
      final userId =
          AuthService.instance.authCustomer?.user?.id?.toString() ?? '';
      if (userId.isNotEmpty) {
        headers['user-id'] = userId;
      }
    }
    return headers;
  }

  /// Fetch video products with pagination
  static Future<VideoProductsResponse> fetchVideoProducts({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final NetworkRepository repository = NetworkRepository();
      final result = await repository
          .fetchData<VideoProductsResponse>(
            url: '$_baseUrl/products/videos?page=$page&per_page=$perPage',
            fromJson: (json) => VideoProductsResponse.fromJson(json),
            forceRefresh: true,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              return VideoProductsResponse.empty();
            },
          );

      if (result.videos.isEmpty) {
        return VideoProductsResponse.empty();
      } else {
        return result;
      }
    } catch (e) {
      debugPrint('TjaraVideosService.fetchVideoProducts error: $e');
      return VideoProductsResponse.empty();
    }
  }

  /// Like/update likes on a product
  static Future<bool> updateProductLike({
    required String productId,
    required String likesCount,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/$productId/meta/update');
      final response = await http
          .post(
            uri,
            headers: _headers(withUserId: true),
            body: json.encode({'key': 'likes', 'value': likesCount}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('TjaraVideosService.updateProductLike error: $e');
      return false;
    }
  }

  /// Add a comment to a product
  static Future<CommentData?> addComment({
    required String productId,
    required String comment,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/product-comments/insert');
      final response = await http
          .post(
            uri,
            headers: _headers(withUserId: true),
            body: json.encode({'product_id': productId, 'comment': comment}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['comment'] != null) {
          return CommentData.fromJson(data['comment']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('TjaraVideosService.addComment error: $e');
      return null;
    }
  }

  /// Fetch comments for a product
  static Future<CommentsResponse> fetchComments({
    required String productId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/product-comments/$productId?page=$page&per_page=$perPage',
      );
      final response = await http
          .get(uri, headers: _headers(withUserId: true))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CommentsResponse.fromJson(data);
      }
      return CommentsResponse.empty();
    } catch (e) {
      debugPrint('TjaraVideosService.fetchComments error: $e');
      return CommentsResponse.empty();
    }
  }

  /// Delete a comment
  static Future<bool> deleteComment({required String commentId}) async {
    try {
      final uri = Uri.parse('$_baseUrl/product-comments/$commentId/delete');
      final response = await http
          .delete(uri, headers: _headers(withUserId: true))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('TjaraVideosService.deleteComment error: $e');
      return false;
    }
  }

  /// Track product view analytics
  static Future<void> trackProductView({
    required String productId,
    required String productName,
    required String productSlug,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/product-analytics/create');
      await http
          .post(
            uri,
            headers: _headers(withUserId: true),
            body: json.encode({
              'product_id': productId,
              'event_key': 'views',
              'metadata': {
                'component': 'video_popup',
                'product_name': productName,
                'product_slug': productSlug,
                'referrer': 'direct',
                'timestamp': DateTime.now().toUtc().toIso8601String(),
                'url': 'https://libanbuy.com/',
                'user_agent': 'TjaraFlutterApp',
                'view_type': 'video_swipe',
              },
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('TjaraVideosService.trackProductView error: $e');
    }
  }
}

// --- Helper to safely extract nested media URL ---
String _extractMediaUrl(Map<String, dynamic>? mediaWrapper) {
  if (mediaWrapper == null) return '';
  // Handle nested media.media structure
  final innerMedia = mediaWrapper['media'];
  if (innerMedia is Map<String, dynamic>) {
    final deepMedia = innerMedia['media'];
    if (deepMedia is Map<String, dynamic>) {
      return (deepMedia['cdn_url'] as String?) ??
          (deepMedia['url'] as String?) ??
          (deepMedia['optimized_media_url'] as String?) ??
          '';
    }
    // Single nesting level
    return (innerMedia['cdn_url'] as String?) ??
        (innerMedia['url'] as String?) ??
        (innerMedia['optimized_media_url'] as String?) ??
        '';
  }
  return '';
}

// --- VideoProduct: wraps ProductDatum with extracted URLs ---
class VideoProduct {
  final ProductDatum product;
  final String videoUrl;
  final String thumbnailUrl;
  final String shopName;
  final String shopThumbnailUrl;
  final Map<String, dynamic>? rawShopJson;
  final int views;
  final int likes;
  final int comments;

  VideoProduct({
    required this.product,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.shopName,
    required this.shopThumbnailUrl,
    this.rawShopJson,
    required this.views,
    required this.likes,
    required this.comments,
  });

  factory VideoProduct.fromRawJson(Map<String, dynamic> json) {
    final product = ProductDatum.fromJson(json);

    // Extract video URL from raw JSON (handles nested media.media)
    final videoUrl = _extractMediaUrl(json['video']);

    // Extract thumbnail URL from raw JSON
    final thumbnailUrl = _extractMediaUrl(json['thumbnail']);

    // Extract shop info
    final shopData = json['shop']?['shop'];
    final shopName = shopData?['name']?.toString() ?? '';
    final shopThumbnailUrl = _extractMediaUrl(shopData?['thumbnail']);

    // Extract analytics
    final analytics = json['analytics'];
    final views =
        (analytics?['views'] is num) ? (analytics['views'] as num).toInt() : 0;

    // Extract likes from meta
    final meta = json['meta'];
    final likes = int.tryParse(meta?['likes']?.toString() ?? '0') ?? 0;

    return VideoProduct(
      product: product,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      shopName: shopName,
      shopThumbnailUrl: shopThumbnailUrl,
      rawShopJson: shopData is Map<String, dynamic> ? shopData : null,
      views: views,
      likes: likes,
      comments: 0,
    );
  }
}

// --- Response Models ---

class VideoProductsResponse {
  final List<VideoProduct> videos;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  VideoProductsResponse({
    required this.videos,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
  });

  factory VideoProductsResponse.fromJson(Map<String, dynamic> json) {
    final productsData = json['products'];
    List<VideoProduct> videosList = [];

    if (productsData is Map<String, dynamic> && productsData['data'] is List) {
      videosList =
          (productsData['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => VideoProduct.fromRawJson(e))
              .where(
                (v) => v.videoUrl.isNotEmpty,
              ) // Only include products with videos
              .toList();
    }

    final pagination = json['pagination'];
    return VideoProductsResponse(
      videos: videosList,
      currentPage: pagination?['current_page'] ?? 1,
      lastPage: pagination?['last_page'] ?? 1,
      total: pagination?['total'] ?? 0,
      hasMore: pagination?['has_more'] ?? false,
    );
  }

  factory VideoProductsResponse.empty() {
    return VideoProductsResponse(
      videos: [],
      currentPage: 1,
      lastPage: 1,
      total: 0,
      hasMore: false,
    );
  }
}

class CommentData {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userThumbnail;
  final String comment;
  final String? parentId;
  final String createdAt;
  final List<CommentData> replies;

  CommentData({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userThumbnail,
    required this.comment,
    this.parentId,
    required this.createdAt,
    required this.replies,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'User',
      userThumbnail: json['user_thumbnail']?.toString(),
      comment: json['comment']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      replies:
          json['replies'] is List
              ? (json['replies'] as List)
                  .map(
                    (e) =>
                        e is Map<String, dynamic>
                            ? CommentData.fromJson(e)
                            : CommentData(
                              id: '',
                              productId: '',
                              userId: '',
                              userName: '',
                              comment: '',
                              createdAt: '',
                              replies: [],
                            ),
                  )
                  .toList()
              : [],
    );
  }
}

class CommentsResponse {
  final List<CommentData> comments;
  final int total;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  CommentsResponse({
    required this.comments,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      comments:
          json['comments'] is List
              ? (json['comments'] as List)
                  .map(
                    (e) =>
                        e is Map<String, dynamic>
                            ? CommentData.fromJson(e)
                            : CommentData(
                              id: '',
                              productId: '',
                              userId: '',
                              userName: '',
                              comment: '',
                              createdAt: '',
                              replies: [],
                            ),
                  )
                  .toList()
              : [],
      total: json['total'] ?? 0,
      currentPage: json['pagination']?['current_page'] ?? 1,
      lastPage: json['pagination']?['last_page'] ?? 1,
      hasMore: json['pagination']?['has_more'] ?? false,
    );
  }

  factory CommentsResponse.empty() {
    return CommentsResponse(
      comments: [],
      total: 0,
      currentPage: 1,
      lastPage: 1,
      hasMore: false,
    );
  }
}
