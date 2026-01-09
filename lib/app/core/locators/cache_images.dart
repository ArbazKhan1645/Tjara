// ignore_for_file: depend_on_referenced_packages, avoid_print, unused_catch_stack

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

class PersistentCacheManager extends CacheManager {
  static final _instance = PersistentCacheManager._internal();
  factory PersistentCacheManager() {
    return _instance;
  }
  PersistentCacheManager._internal()
    : super(
        Config(
          'persistentMovieCache',
          stalePeriod: const Duration(days: 90),
          maxNrOfCacheObjects: 500,
        ),
      );
}

// Maintains your isolate-based approach
Future<void> prefetchImageIsolate(String imageUrl) async {
  if (imageUrl.isEmpty) return;
  try {
    final isCached = await compute(_checkImageCache, imageUrl);
    if (!isCached) {
      // Use compute to run the download in an isolate
      await compute(_downloadImageInIsolate, imageUrl);
    }
  } catch (e) {
    // Silently ignore any errors
  }
}

bool _checkImageCache(String imageUrl) {
  try {
    final cacheManager = PersistentCacheManager();
    cacheManager.getFileFromMemory(imageUrl);
    return true;
  } catch (e) {
    return false;
  }
}

// Function to be run in isolate
bool _downloadImageInIsolate(String imageUrl) {
  try {
    final cacheManager = PersistentCacheManager();
    cacheManager.downloadFile(imageUrl);
    return true;
  } catch (e) {
    // Silently ignore download errors
    return false;
  }
}

Future<ImageProvider> loadCachedImage(String imageUrl) async {
  final cacheManager = PersistentCacheManager();
  final fileInfo = await cacheManager.getFileFromCache(imageUrl);

  if (fileInfo != null && fileInfo.file.existsSync()) {
    return FileImage(fileInfo.file);
  } else {
    return NetworkImage(imageUrl);
  }
}
