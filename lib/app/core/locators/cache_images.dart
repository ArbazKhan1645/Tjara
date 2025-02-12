// ignore_for_file: depend_on_referenced_packages

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

Future<void> prefetchMovieImages(List<String> posterPaths) async {
  final cacheManager = PersistentCacheManager();
  for (String path in posterPaths) {
    final imageUrl = 'https://image.tmdb.org/t/p/w500$path';
    final fileInfo = await cacheManager.getFileFromCache(imageUrl);
    if (fileInfo == null) {
      await cacheManager.downloadFile(imageUrl);
    }
  }
}

Future<void> prefetchMovieImage(String posterPaths) async {
  final cacheManager = PersistentCacheManager();
  final imageUrl = 'https://image.tmdb.org/t/p/w500$posterPaths';
  final fileInfo = await cacheManager.getFileFromCache(imageUrl);
  if (fileInfo == null) {
    await cacheManager.downloadFile(imageUrl);
  }
}
