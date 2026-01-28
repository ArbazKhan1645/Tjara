import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';

class ViewCounter extends StatefulWidget {
  final String postId;
  final int currentViews;

  const ViewCounter({
    super.key,
    required this.postId,
    required this.currentViews,
  });

  @override
  _ViewCounterState createState() => _ViewCounterState();
}

class _ViewCounterState extends State<ViewCounter> {
  late SharedPreferences prefs;
  bool hasViewed = false;
  int viewCount = 0;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    prefs = await SharedPreferences.getInstance();

    // Check if the user has already viewed this post
    final viewKey = "view_${widget.postId}";
    hasViewed = prefs.getBool(viewKey) ?? false;
    viewCount = widget.currentViews;

    // If this is the first view, increment the counter
    if (!hasViewed) {
      _incrementView();
    }
  }

  Future<void> _incrementView() async {
    final viewKey = "view_${widget.postId}";
    final newViews = viewCount + 1;

    try {
      final response = await http.put(
        Uri.parse(
          'https://api.libanbuy.com/api/posts/${widget.postId}/meta/update',
        ),
        headers: {
          'Content-Type': 'application/json',
          "X-Request-From": "Application",
        },
        body: jsonEncode({"key": "views", "value": newViews.toString()}),
      );

      if (response.statusCode == 200) {
        // Mark this post as viewed
        prefs.setBool(viewKey, true);

        // Update the state
        setState(() {
          hasViewed = true;
          viewCount = newViews;
        });

        // Refresh the home screen data
        Get.find<HomeController>().fetchLatestPost();
      } else {
        print('Failed to update view count: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.visibility, color: Colors.grey),
        Text(viewCount.toString(), style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
