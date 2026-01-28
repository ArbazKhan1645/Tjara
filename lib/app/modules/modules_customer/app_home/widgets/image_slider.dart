// ignore_for_file: library_private_types_in_public_api
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/core/widgets/image_viewer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final PageController controller;
  final String? videoUrl;
  final VoidCallback? onVideoStateChanged;
  /// Index position where video should appear in the slider.
  /// Default is 0 (video first). Set to 1 to show thumbnail first, then video.
  final int videoIndex;

  const ImageSlider({
    super.key,
    required this.imageUrls,
    required this.videoUrl,
    required this.controller,
    this.onVideoStateChanged,
    this.videoIndex = 0,
  });

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // Add disposal flag
  bool _isDisposed = false;

  // Use ValueNotifiers for smooth updates without setState
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isVideoInitializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isVideoErrorNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isVisibleNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _isVideoPlayingNotifier = ValueNotifier(false);

  VideoPlayerController? _videoController;

  // Computed properties for better performance
  bool get _hasVideo => widget.videoUrl?.isNotEmpty == true;
  int get _totalItems =>
      _hasVideo ? widget.imageUrls.length + 1 : widget.imageUrls.length;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_hasVideo) _initializeVideo();
    // Listen to video controller changes
    _setupVideoListener();
  }

  @override
  void dispose() {
    _isDisposed = true; // Set flag before disposing
    WidgetsBinding.instance.removeObserver(this);
    _disposeVideo();
    _selectedIndexNotifier.dispose();
    _isVideoInitializedNotifier.dispose();
    _isVideoErrorNotifier.dispose();
    _isVisibleNotifier.dispose();
    _isVideoPlayingNotifier.dispose();
    super.dispose();
  }

  void _setupVideoListener() {
    _videoController?.addListener(() {
      if (_videoController != null && !_isDisposed) {
        _isVideoPlayingNotifier.value = _videoController!.value.isPlaying;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseVideo();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Check if widget is disposed before updating state
    if (_isDisposed) return;

    final wasVisible = _isVisibleNotifier.value;
    _isVisibleNotifier.value = info.visibleFraction > 0.5;

    if (wasVisible != _isVisibleNotifier.value) {
      if (!_isVisibleNotifier.value) {
        _pauseVideo();
      } else if (_shouldAutoPlay()) {
        _playVideo();
      }
    }
  }

  bool _shouldAutoPlay() {
    final isVideoPage = _hasVideo && _selectedIndexNotifier.value == widget.videoIndex;
    return isVideoPage &&
        _isVideoInitializedNotifier.value &&
        _isVisibleNotifier.value &&
        _videoController != null;
  }

  void _pauseVideo() {
    if (_isDisposed) return;
    if (_videoController?.value.isPlaying == true) {
      _videoController!.pause();
      widget.onVideoStateChanged?.call();
    }
  }

  void _playVideo() {
    if (_isDisposed) return;
    if (_videoController != null && !_videoController!.value.isPlaying) {
      _videoController!.play();
      widget.onVideoStateChanged?.call();
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  void pauseVideoForNavigation() => _pauseVideo();

  Future<void> _initializeVideo() async {
    if (!_hasVideo) return;

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl ?? ''),
        httpHeaders: {
          'Accept': 'video/mp4',
          'Connection': 'keep-alive',
          'User-Agent': 'FlutterVideoPlayer',
        },
      );
      await _videoController!.initialize();
      if (_isDisposed) {
        _videoController?.dispose();
        return;
      }
      _isVideoInitializedNotifier.value = true;
      _setupVideoListener();
      if (_shouldAutoPlay()) _playVideo();
    } catch (e) {
      debugPrint("Video initialization error: $e");
      if (!_isDisposed) {
        _isVideoErrorNotifier.value = true;
      }
    }
  }

  void _onPageChanged(int index) {
    if (_isDisposed) return;
    _selectedIndexNotifier.value = index;

    // Handle video playback
    if (_shouldAutoPlay()) {
      _playVideo();
    } else {
      _pauseVideo();
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController == null || _isDisposed) return;

    if (_videoController!.value.isPlaying) {
      _pauseVideo();
    } else if (_isVisibleNotifier.value) {
      _playVideo();
    }
  }

  Widget _buildVideoPlayer() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isVideoErrorNotifier,
      builder: (context, isError, child) {
        if (isError) {
          return _buildErrorWidget();
        }
        return ValueListenableBuilder<bool>(
          valueListenable: _isVideoInitializedNotifier,
          builder: (context, isInitialized, child) {
            if (!isInitialized || _videoController == null) {
              return _buildVideoLoadingWidget();
            }
            return _buildVideoContent();
          },
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Unable to load video", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLoadingWidget() {
    return Stack(
      children: [
        // Background placeholder
        if (widget.imageUrls.isNotEmpty)
          Positioned.fill(
            child: CachedNetworkImage(
              cacheManager: PersistentCacheManager(),
              imageUrl: widget.imageUrls.first,
              fit: BoxFit.contain,
              memCacheWidth: MediaQuery.of(context).size.width.toInt(),
              fadeInDuration: Duration.zero,
              placeholder:
                  (_, __) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget: (_, __, ___) => _buildImageErrorWidget(),
            ),
          )
        else
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),
        // Video loading overlay
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            _buildVideoControls(),
            // Video indicator badge
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isVideoPlayingNotifier,
      builder: (context, isPlaying, child) {
        return GestureDetector(
          onTap: _toggleVideoPlayback,
          child: Container(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Center(
                child: AnimatedScale(
                  scale: isPlaying ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(color: Colors.grey[200]);
  }

  Widget _buildImageItem(int index) {
    // Calculate image index based on video position
    int imageIndex;
    if (_hasVideo) {
      if (index < widget.videoIndex) {
        // Images before video position
        imageIndex = index;
      } else {
        // Images after video position (subtract 1 for video slot)
        imageIndex = index - 1;
      }
    } else {
      imageIndex = index;
    }

    if (imageIndex < 0 || imageIndex >= widget.imageUrls.length ||
        widget.imageUrls[imageIndex].isEmpty) {
      return Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: const Center(child: Text("No image available")),
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _openImageViewer(imageIndex),
          child: Hero(
            tag: 'image_${widget.imageUrls[imageIndex]}',
            child: Container(
              color: Colors.transparent,
              child: CachedNetworkImage(
                height: 320,
                cacheManager: PersistentCacheManager(),
                imageUrl: widget.imageUrls[imageIndex],
                fit: BoxFit.contain,
                placeholder:
                    (context, url) => Container(
                      color: Colors.transparent,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.grey),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) =>
                        Container(color: Colors.grey.shade100),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(int imageIndex) {
    final imageUrl = widget.imageUrls[imageIndex];

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ImageViewer(imageUrls: [imageUrl], initialIndex: 0),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndexNotifier,
      builder: (context, selectedIndex, child) {
        final shouldShow =
            isLeft ? selectedIndex > 0 : selectedIndex < _totalItems - 1;

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: isLeft ? (shouldShow ? 10 : -50) : null,
          right: isLeft ? null : (shouldShow ? 10 : -50),
          child: AnimatedOpacity(
            opacity: shouldShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicators() {
    if (_totalItems <= 1) return const SizedBox.shrink();

    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndexNotifier,
      builder: (context, selectedIndex, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalItems, (index) {
              final isActive = selectedIndex == index;
              final isVideoIndex = _hasVideo && index == widget.videoIndex;

              if (isVideoIndex) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.play_circle_filled,
                    size: isActive ? 16 : 12,
                    color: isActive ? Colors.red : Colors.grey[400],
                  ),
                );
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? Colors.blue : Colors.grey[400],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: Key('image_slider_${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main slider container
          SizedBox(
            height: 310,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // PageView with smooth transitions
                PageView.builder(
                  controller: widget.controller,
                  itemCount: _totalItems,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _hasVideo && index == widget.videoIndex
                              ? Container(
                                key: ValueKey('video_$index'),
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _buildVideoPlayer(),
                              )
                              : Container(
                                key: ValueKey('image_$index'),
                                child: _buildImageItem(index),
                              ),
                    );
                  },
                ),
                // Navigation arrows
                if (_totalItems > 1) ...[
                  _buildNavigationButton(
                    icon: Icons.arrow_back,
                    isLeft: true,
                    onTap:
                        () => widget.controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                  ),
                  _buildNavigationButton(
                    icon: Icons.arrow_forward,
                    isLeft: false,
                    onTap:
                        () => widget.controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                  ),
                ],
              ],
            ),
          ),
          // Page indicators
          _buildPageIndicators(),
        ],
      ),
    );
  }
}
