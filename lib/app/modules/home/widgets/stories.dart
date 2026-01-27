// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/like_button.dart';
import 'package:tjara/app/core/widgets/view_icon.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:video_player/video_player.dart';
import 'package:tjara/app/models/posts/posts_model.dart';

class VideoFeedDialog extends StatefulWidget {
  final List<PostModel> posts;
  final PostModel? initialPost;

  const VideoFeedDialog({super.key, required this.posts, this.initialPost});

  @override
  _VideoFeedDialogState createState() => _VideoFeedDialogState();
}

class _VideoFeedDialogState extends State<VideoFeedDialog> {
  late PageController _pageController;
  List<VideoPlayerController?> _controllers = [];
  int _currentIndex = 0;
  bool _isDisposed = false;
  bool _isMuted = false;
  bool _showControls = true;
  Timer? _controlsTimer;
  final Set<String> _viewedPosts = {}; // Track which posts have been viewed

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialPost != null
            ? widget.posts.indexWhere(
              (post) => post.id == widget.initialPost!.id,
            )
            : 0;

    if (_currentIndex < 0 || _currentIndex >= widget.posts.length) {
      _currentIndex = 0;
    }

    _pageController = PageController(initialPage: _currentIndex);
    _initializeControllers();
    _pageController.addListener(_onPageChanged);
    _startControlsTimer();

    // Track view for initial post
    _trackView(_currentIndex);
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _initializeControllers() async {
    _controllers = List.generate(widget.posts.length, (index) => null);

    if (_currentIndex >= 0 && _currentIndex < widget.posts.length) {
      _initializeController(_currentIndex);
    }

    if (_currentIndex + 1 < widget.posts.length) {
      _initializeController(_currentIndex + 1);
    }
  }

  void _initializeController(int index) async {
    if (_isDisposed) return;
    if (index < 0 || index >= widget.posts.length) return;
    if (_controllers.length > index && _controllers[index] != null) return;

    while (_controllers.length <= index) {
      _controllers.add(null);
    }

    // 🎥 VIDEO URL FOR STORIES - This is where the video URL is retrieved
    final url = widget.posts[index].video?.media?.url ?? '';

    if (url.isNotEmpty) {
      try {
        final controller = VideoPlayerController.network(url);
        _controllers[index] = controller;

        await controller.initialize();

        if (_isDisposed) {
          controller.dispose();
          return;
        }

        if (mounted) {
          setState(() {
            if (_isMuted) {
              controller.setVolume(0);
            }
          });
          if (index == _currentIndex) {
            controller.play();
          }
        }
      } catch (e) {
        print('Error initializing video controller for index $index: $e');
        if (!_isDisposed && index < _controllers.length) {
          _controllers[index] = null;
        }
      }
    }
  }

  void _onPageChanged() {
    if (_isDisposed || !mounted) return;

    final int newIndex = _pageController.page!.round();

    if (newIndex < 0 || newIndex >= widget.posts.length) {
      return;
    }

    if (_currentIndex != newIndex) {
      if (_currentIndex >= 0 &&
          _currentIndex < _controllers.length &&
          _controllers[_currentIndex] != null) {
        _controllers[_currentIndex]?.pause();
      }

      _currentIndex = newIndex;

      if (_currentIndex >= 0 &&
          _currentIndex < _controllers.length &&
          _controllers[_currentIndex] != null) {
        _controllers[_currentIndex]?.play();
      }

      if (newIndex + 1 < widget.posts.length) {
        _initializeController(newIndex + 1);
      }
      if (newIndex - 1 >= 0) {
        _initializeController(newIndex - 1);
      }

      setState(() {
        _showControls = true;
        _startControlsTimer();
      });

      // Track view for new post
      _trackView(newIndex);
    }
  }

  void _trackView(int index) {
    if (index >= 0 && index < widget.posts.length) {
      final postId = widget.posts[index].id;
      if (!_viewedPosts.contains(postId)) {
        _viewedPosts.add(postId);
        _updateViews(index);
      }
    }
  }

  void _updateViews(int index) async {
    if (index < 0 || index >= widget.posts.length) return;

    final post = widget.posts[index];
    final currentViews = int.tryParse((post.meta?.views ?? 0).toString()) ?? 0;
    final newViews = currentViews + 1;

    try {
      final response = await http.put(
        Uri.parse('https://api.libanbuy.com/api/posts/${post.id}/meta/update'),
        headers: {
          'Content-Type': 'application/json',
          "X-Request-From": "Application",
        },
        body: jsonEncode({"key": "views", "value": newViews.toString()}),
      );

      if (response.statusCode == 200) {
        // Update the model directly
        if (post.meta != null) {
          post.meta!.views = newViews.toString();
        }

        if (mounted) {
          setState(() {}); // Trigger rebuild to show updated views
        }
      }
    } catch (e) {
      print('Error updating views: $e');
    }
  }

  // Callback function to update likes in the model
  void _updateLikesInModel(int index, int newLikes, bool isLiked) {
    if (index >= 0 && index < widget.posts.length) {
      final post = widget.posts[index];
      if (post.meta != null) {
        post.meta!.likes = newLikes.toString();
      }

      if (mounted) {
        setState(() {}); // Trigger rebuild to show updated likes
      }
    }
  }

  void _disposeControllers() {
    for (var controller in _controllers) {
      if (controller != null) {
        controller.pause();
        controller.dispose();
      }
    }
    _controllers.clear();
  }

  void _togglePlayPause() {
    if (_currentIndex >= 0 &&
        _currentIndex < _controllers.length &&
        _controllers[_currentIndex] != null) {
      if (_controllers[_currentIndex]!.value.isPlaying) {
        _controllers[_currentIndex]?.pause();
      } else {
        _controllers[_currentIndex]?.play();
      }
      setState(() {
        _showControls = true;
        _startControlsTimer();
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _showControls = true;
      _startControlsTimer();
    });

    for (var controller in _controllers) {
      if (controller != null) {
        controller.setVolume(_isMuted ? 0 : 1);
      }
    }
  }

  @override
  void didUpdateWidget(VideoFeedDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.posts != widget.posts) {
      _disposeControllers();

      if (widget.initialPost != null) {
        _currentIndex = widget.posts.indexWhere(
          (post) => post.id == widget.initialPost!.id,
        );
        if (_currentIndex < 0 || _currentIndex >= widget.posts.length) {
          _currentIndex = 0;
        }
      } else {
        _currentIndex = 0;
      }

      _pageController.removeListener(_onPageChanged);
      _pageController.dispose();
      _pageController = PageController(initialPage: _currentIndex);
      _pageController.addListener(_onPageChanged);

      _initializeControllers();
      _trackView(_currentIndex);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controlsTimer?.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          // FIX 2: Toggle play/pause when tapping anywhere on the video
          _togglePlayPause();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red, width: 4),
          ),
          width: MediaQuery.of(context).size.width - 40,
          height: MediaQuery.of(context).size.height - 100,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.posts.length,
                itemBuilder: (context, index) {
                  if (index < 0 || index >= widget.posts.length) {
                    return const Center(
                      child: Text(
                        'Invalid post index',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final PostModel post = widget.posts[index];
                  return Stack(
                    children: [
                      Center(
                        child:
                            (index < _controllers.length &&
                                    _controllers[index] != null &&
                                    _controllers[index]!.value.isInitialized)
                                ? AspectRatio(
                                  aspectRatio:
                                      _controllers[index]!.value.aspectRatio,
                                  child: VideoPlayer(_controllers[index]!),
                                )
                                : const CircularProgressIndicator(),
                      ),
                      Positioned(
                        right: 16,
                        left: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            // FIX 1: Make both avatar and shop info clickable
                            GestureDetector(
                              onTap: () {
                                Get.back();
                                Get.toNamed(
                                  Routes.STORE_PAGE,
                                  arguments: {
                                    'shopid':
                                        widget.posts[index].shop?.shop?.id ??
                                        '',
                                    'ShopShop': widget.posts[index].shop?.shop,
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      widget
                                              .posts[index]
                                              .shop
                                              ?.shop
                                              ?.banner
                                              ?.media
                                              .optimizedMediaUrl ??
                                          '',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.posts[index].name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        widget.posts[index].shop?.shop?.name ??
                                            's',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          decoration:
                                              TextDecoration
                                                  .underline, // Visual indicator it's clickable
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(), // Better than fixed width
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LikeButton(
                              postId: post.id,
                              currentLikes: int.parse(
                                (post.meta?.likes ?? 0).toString(),
                              ),
                              onLikeUpdate: (newLikes, isLiked) {
                                _updateLikesInModel(index, newLikes, isLiked);
                              },
                            ),
                            const SizedBox(height: 8),
                            ViewCounter(
                              postId: post.id,
                              currentViews:
                                  int.tryParse(
                                    (post.meta?.views ?? 0).toString(),
                                  ) ??
                                  0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Play/Pause controls - show only when controls are visible
              if (_showControls)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _currentIndex < _controllers.length &&
                                  _controllers[_currentIndex] != null &&
                                  _controllers[_currentIndex]!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                  ),
                ),

              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future showVideoFeedDialog(
  BuildContext context,
  List<PostModel> posts,
  PostModel post,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => VideoFeedDialog(posts: posts, initialPost: post),
  );
}
