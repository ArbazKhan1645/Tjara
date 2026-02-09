import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:tjara/app/modules/modules_customer/tjara_videos/service/tjara_videos_service.dart';

class TjaraVideosController extends GetxController {
  // --- Video Products ---
  final RxList<VideoProduct> videos = <VideoProduct>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  static const int _perPage = 10;
  static const int _preloadThreshold = 8;

  // --- Video Controllers Cache ---
  // Only keep 3 controllers alive at a time: prev, current, next
  final Map<int, VideoPlayerController> _videoControllers = {};
  final RxInt currentIndex = 0.obs;
  final RxBool isCurrentVideoPlaying = false.obs;
  final RxBool isCurrentVideoInitialized = false.obs;
  // Increments each time any video finishes initializing - used to trigger UI rebuilds
  final RxInt videoInitCount = 0.obs;
  bool _isDisposed = false;
  bool _isAppInBackground = false;

  // --- Likes tracking (local) ---
  final Map<String, int> _localLikes = {};
  final Set<String> _likedProducts = {};

  @override
  void onInit() {
    super.onInit();
    final preloaded = Get.arguments;
    if (preloaded is List<VideoProduct> && preloaded.isNotEmpty) {
      // Use preloaded videos - instant playback, no loading state
      videos.value = List<VideoProduct>.from(preloaded);
      isLoading.value = false;
      hasMore.value = true;
      _initializeVideoAt(0);
      // Fetch full first page in background to fill the list
      _loadFullFirstPage();
    } else {
      _loadInitialVideos();
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _disposeAllControllers();
    super.onClose();
  }

  // --- Data Loading ---

  Future<void> _loadInitialVideos() async {
    isLoading.value = true;
    _currentPage = 1;
    final response = await TjaraVideosService.fetchVideoProducts(
      page: _currentPage,
      perPage: _perPage,
    );
    if (_isDisposed) return;

    videos.value = response.videos;
    hasMore.value = response.hasMore;
    isLoading.value = false;

    if (videos.isNotEmpty) {
      _initializeVideoAt(0);
    }
  }

  /// Fetch full page 1 in background, merge new videos after preloaded ones
  Future<void> _loadFullFirstPage() async {
    final response = await TjaraVideosService.fetchVideoProducts(
      page: 1,
      perPage: _perPage,
    );
    if (_isDisposed) return;

    final existingIds = videos.map((v) => v.product.id).toSet();
    final newVideos = response.videos
        .where((v) => !existingIds.contains(v.product.id))
        .toList();

    if (newVideos.isNotEmpty) {
      videos.addAll(newVideos);
    }
    hasMore.value = response.hasMore;
    _currentPage = 1;
  }

  Future<void> loadMoreVideos() async {
    if (isLoadingMore.value || !hasMore.value || _isDisposed) return;
    isLoadingMore.value = true;
    _currentPage++;

    final response = await TjaraVideosService.fetchVideoProducts(
      page: _currentPage,
      perPage: _perPage,
    );
    if (_isDisposed) return;

    videos.addAll(response.videos);
    hasMore.value = response.hasMore;
    isLoadingMore.value = false;
  }

  @override
  Future<void> refresh() async {
    _disposeAllControllers();
    _localLikes.clear();
    _likedProducts.clear();
    _trackedViews.clear();
    await _loadInitialVideos();
  }

  // --- Video Lifecycle Management ---

  Future<void> _initializeVideoAt(int index) async {
    if (_isDisposed || index < 0 || index >= videos.length) return;
    if (_videoControllers.containsKey(index)) return;

    final videoUrl = videos[index].videoUrl;
    if (videoUrl.isEmpty) return;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: const {
          'Accept': 'video/mp4',
          'Connection': 'keep-alive',
          'User-Agent': 'FlutterVideoPlayer',
        },
      );

      _videoControllers[index] = controller;

      await controller.initialize();
      if (_isDisposed) {
        controller.dispose();
        _videoControllers.remove(index);
        return;
      }

      controller.setLooping(true);
      // Buffer a few seconds for low connectivity
      controller.setVolume(1.0);

      // Signal that a video finished initializing (triggers UI rebuild)
      videoInitCount.value++;

      // Auto-play if this is the current visible video
      if (index == currentIndex.value && !_isAppInBackground) {
        controller.play();
        isCurrentVideoPlaying.value = true;
        isCurrentVideoInitialized.value = true;
        _trackView(index);
      }
    } catch (e) {
      debugPrint('Error initializing video at $index: $e');
      _videoControllers.remove(index);
    }
  }

  void _disposeVideoAt(int index) {
    final controller = _videoControllers.remove(index);
    if (controller != null) {
      controller.pause();
      controller.dispose();
    }
  }

  void _disposeAllControllers() {
    for (final controller in _videoControllers.values) {
      try {
        controller.pause();
        controller.dispose();
      } catch (_) {}
    }
    _videoControllers.clear();
  }

  /// Called when the page changes - manages 3-controller window
  void onPageChanged(int index) {
    if (_isDisposed) return;

    final prevIndex = currentIndex.value;
    currentIndex.value = index;

    // Pause previous video
    _videoControllers[prevIndex]?.pause();

    // Reset state
    isCurrentVideoPlaying.value = false;
    isCurrentVideoInitialized.value = false;

    // Play current video if initialized
    final current = _videoControllers[index];
    if (current != null && current.value.isInitialized) {
      if (!_isAppInBackground) {
        current.seekTo(Duration.zero);
        current.play();
        isCurrentVideoPlaying.value = true;
      }
      isCurrentVideoInitialized.value = true;
      _trackView(index);
    } else {
      _initializeVideoAt(index);
    }

    // Pre-initialize next video
    if (index + 1 < videos.length) {
      _initializeVideoAt(index + 1);
    }

    // Dispose controllers far from current (keep window of 3: prev, current, next)
    final keysToDispose = _videoControllers.keys
        .where((k) => (k - index).abs() > 1)
        .toList();
    for (final k in keysToDispose) {
      _disposeVideoAt(k);
    }

    // Preload next page at threshold
    if (index >= videos.length - _preloadThreshold) {
      loadMoreVideos();
    }
  }

  /// Toggle play/pause on tap
  void togglePlayPause() {
    if (_isDisposed) return;
    final controller = _videoControllers[currentIndex.value];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      isCurrentVideoPlaying.value = false;
    } else {
      controller.play();
      isCurrentVideoPlaying.value = true;
    }
  }

  /// App lifecycle management
  void onAppLifecycleChanged(bool isResumed) {
    if (_isDisposed) return;
    _isAppInBackground = !isResumed;

    final controller = _videoControllers[currentIndex.value];
    if (controller == null || !controller.value.isInitialized) return;

    if (isResumed) {
      controller.play();
      isCurrentVideoPlaying.value = true;
    } else {
      controller.pause();
      isCurrentVideoPlaying.value = false;
    }
  }

  /// Get the video controller for an index
  VideoPlayerController? getControllerAt(int index) {
    return _videoControllers[index];
  }

  // --- Analytics ---

  final Set<String> _trackedViews = {};

  void _trackView(int index) {
    if (index < 0 || index >= videos.length) return;
    final product = videos[index].product;
    final id = product.id ?? '';
    if (id.isEmpty || _trackedViews.contains(id)) return;
    _trackedViews.add(id);

    TjaraVideosService.trackProductView(
      productId: id,
      productName: product.name ?? '',
      productSlug: product.slug ?? '',
    );
  }

  // --- Likes ---

  int getLikesCount(VideoProduct video) {
    final id = video.product.id ?? '';
    if (_localLikes.containsKey(id)) return _localLikes[id]!;
    return video.likes;
  }

  bool isLiked(String productId) => _likedProducts.contains(productId);

  Future<void> toggleLike(VideoProduct video) async {
    final id = video.product.id ?? '';
    if (id.isEmpty) return;

    final wasLiked = _likedProducts.contains(id);
    int current = getLikesCount(video);

    if (wasLiked) {
      _likedProducts.remove(id);
      current = (current - 1).clamp(0, 999999);
    } else {
      _likedProducts.add(id);
      current = current + 1;
    }
    _localLikes[id] = current;
    update();

    await TjaraVideosService.updateProductLike(
      productId: id,
      likesCount: current.toString(),
    );
  }
}
