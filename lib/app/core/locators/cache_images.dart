// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PersistentCacheManager extends CacheManager {
  static final _instance = PersistentCacheManager._internal();
  factory PersistentCacheManager() {
    return _instance;
  }
  PersistentCacheManager._internal()
      : super(Config('persistentMovieCache',
            stalePeriod: const Duration(days: 90), maxNrOfCacheObjects: 500));
}

Future<void> prefetchImage(String imageUrl) async {
  try {
    if (imageUrl.isEmpty) return;
    final cacheManager = PersistentCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(imageUrl);

    if (fileInfo == null) {
      await cacheManager.downloadFile(imageUrl);
    }
  } on Exception catch (e) {
    print(e);
  }
}

Future<ImageProvider> loadCachedImage(String imageUrl) async {
  final cacheManager = PersistentCacheManager();
  final fileInfo = await cacheManager.getFileFromCache(imageUrl);

  if (fileInfo != null) {
    // If the image is cached, load it directly from the file
    return FileImage(fileInfo.file);
  } else {
    // If the image is not cached, download it and return the network image
    await cacheManager.downloadFile(imageUrl);
    return NetworkImage(imageUrl);
  }
}
