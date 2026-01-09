// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/wishlists/wishlist_model.dart';

class WishlistService {
  final String baseUrl =
      'https://api.libanbuy.com/api/wishlist?with=shop,variations,rating&_t=${DateTime.now().millisecondsSinceEpoch}';
  // final String userId = '61f75d53-fbdd-41d5-a262-2f5214936b20';
  final String cacheKey = 'wishlist_caches';

  Future<WishlistResponse?> fetchWishlist(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'user-id': userId, 'X-Request-From': 'Website'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final wishlistResponse = WishlistResponse.fromJson(jsonMap);

        await _saveDataToCache(jsonResponse);
        return wishlistResponse;
      } else {
        final cachedData = await _getCachedData();
        return cachedData;
      }
    } catch (e) {
      print(e);
      final cachedData = await _getCachedData();
      return cachedData;
    }
  }

  Future<WishlistResponse?> _getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);

    if (cachedJson != null) {
      final Map<String, dynamic> jsonResponse = json.decode(cachedJson);
      return WishlistResponse.fromJson(jsonResponse);
    }
    return null;
  }

  Future<void> _saveDataToCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(data);
    await prefs.setString(cacheKey, jsonString);
  }
}
