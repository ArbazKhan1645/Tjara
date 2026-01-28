import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  final int currentLikes;
  final Function(int newLikes, bool isLiked)? onLikeUpdate; // Callback function

  const LikeButton({
    super.key,
    required this.postId,
    required this.currentLikes,
    this.onLikeUpdate,
  });

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late SharedPreferences prefs;
  bool isLiked = false;
  int likeCount = 0;
  bool _isUpdating = false; // Track if we're currently updating

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update like count when parent widget updates (from model changes)
    if (oldWidget.currentLikes != widget.currentLikes) {
      setState(() {
        likeCount = widget.currentLikes;
      });
    }
  }

  Future<void> _initPreferences() async {
    prefs = await SharedPreferences.getInstance();

    // Check if the post is already liked from local cache
    setState(() {
      isLiked = prefs.getBool(widget.postId) ?? false;
      likeCount = widget.currentLikes; // Initialize likes from API
    });
  }

  Future<void> handleLike() async {
    // Prevent multiple simultaneous updates
    if (_isUpdating) return;

    _isUpdating = true;

    // Store original values before optimistic update
    final originalLikes = likeCount;
    final originalIsLiked = isLiked;

    // Optimistic UI update - update immediately for faster feel
    final newLikes = isLiked ? likeCount - 1 : likeCount + 1;
    final newIsLiked = !isLiked;

    // Update UI immediately
    setState(() {
      isLiked = newIsLiked;
      likeCount = newLikes;
    });

    // Update cache immediately
    prefs.setBool(widget.postId, newIsLiked);

    // Call the callback to update the parent model immediately
    if (widget.onLikeUpdate != null) {
      widget.onLikeUpdate!(newLikes, newIsLiked);
    }

    // Make API call in background
    _updateLikeOnServer(newLikes, originalLikes, originalIsLiked);
  }

  Future<void> _updateLikeOnServer(
    int newLikes,
    int originalLikes,
    bool originalIsLiked,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          'https://api.libanbuy.com/api/posts/${widget.postId}/meta/update',
        ),
        headers: {
          'Content-Type': 'application/json',
          "X-Request-From": "Application",
        },
        body: jsonEncode({"key": "likes", "value": newLikes.toString()}),
      );

      if (response.statusCode == 200) {
        // Success - no need to update UI as it's already updated
        Get.find<HomeController>().fetchLatestPost();
      } else {
        // Revert on failure using original values
        _revertLike(originalLikes, originalIsLiked);
      }
    } catch (e) {
      print('Error updating like: $e');
      // Revert on error using original values
      _revertLike(originalLikes, originalIsLiked);
    } finally {
      _isUpdating = false;
    }
  }

  void _revertLike(int originalLikes, bool originalIsLiked) {
    // Revert the optimistic update if API call failed
    setState(() {
      isLiked = originalIsLiked;
      likeCount = originalLikes;
    });

    // Revert cache
    prefs.setBool(widget.postId, originalIsLiked);

    // Revert parent model
    if (widget.onLikeUpdate != null) {
      widget.onLikeUpdate!(originalLikes, originalIsLiked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
          onPressed: handleLike,
        ),
        Text(likeCount.toString(), style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
