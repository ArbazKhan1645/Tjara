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

Future<void> prefetchImage(String imageUrl) async {
  try {
    final cacheManager = PersistentCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(imageUrl);

    if (fileInfo == null) {
      await cacheManager.downloadFile(imageUrl);
    }
  } on Exception catch (e) {
    print(e);
  }
}
