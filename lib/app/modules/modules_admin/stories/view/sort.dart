import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class HeaderStoriesSortWidget extends StatefulWidget {
  final String headerStoriesSortOrder;

  const HeaderStoriesSortWidget({
    super.key,
    required this.headerStoriesSortOrder,
  });

  @override
  State<HeaderStoriesSortWidget> createState() =>
      _HeaderStoriesSortWidgetState();
}

class _HeaderStoriesSortWidgetState extends State<HeaderStoriesSortWidget> {
  List<String> storyIds = [];
  List<PostModel> sortedStories = [];
  bool isSaving = false;
  bool _hasReordered = false;
  late Future<List<PostModel>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    storyIds =
        widget.headerStoriesSortOrder
            .split(',')
            .where((id) => id.trim().isNotEmpty)
            .map((id) => id.trim())
            .toList();
    _storiesFuture = fetchPostsByIds(storyIds);
  }

  Future<List<PostModel>> fetchPostsByIds(List<String> ids) async {
    final List<PostModel> posts = [];

    for (String id in ids) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://api.libanbuy.com/api/posts?with=thumbnail&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=post_type&filterByColumns[columns][0][value]=shop_stories&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=id&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=$id&orderBy=created_at&order=desc&per_page=100',
          ),
          headers: {
            'X-Request-From': 'Dashboard',
            'Content-Type': 'application/json',
            'shop-id':
                AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
            'user-id':
                AuthService.instance.authCustomer!.user!.id.toString(),
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          posts.add(PostModel.fromJson(data['posts']['data'][0]));
        }
      } catch (e) {
        debugPrint('Error fetching post $id: $e');
      }
    }

    return posts;
  }

  Future<void> updateSortOrder() async {
    setState(() {
      isSaving = true;
    });

    try {
      final sortOrderString = storyIds.join(',');

      final response = await http.post(
        Uri.parse('https://api.libanbuy.com/api/settings/update'),
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
        body: json.encode({'header_stories_sort_order': sortOrderString}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasReordered = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Sort order updated successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF0D9488),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        throw Exception('Failed to update sort order');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer for header info bar
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Shimmer for story cards
        ...List.generate(
          storyIds.length.clamp(0, 6),
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 10,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (storyIds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sort,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort Header Stories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Drag to reorder stories display order',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (_hasReordered)
                _buildSaveButton(),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          FutureBuilder<List<PostModel>>(
            future: _storiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerLoading();
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error);
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              if (sortedStories.isEmpty) {
                sortedStories = List.from(snapshot.data!);
              }

              return _buildReorderableList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        height: 36,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : updateSortOrder,
          icon: isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save_outlined, size: 16),
          label: Text(
            isSaving ? 'Saving...' : 'Save Order',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Failed to load stories',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _storiesFuture = fetchPostsByIds(storyIds);
                });
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No stories found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedStories.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final animValue = Curves.easeInOut.transform(animation.value);
            final elevation = animValue * 8;
            final scale = 1.0 + (animValue * 0.02);
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(14),
                shadowColor: const Color(0xFF0D9488).withOpacity(0.3),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final String item = storyIds.removeAt(oldIndex);
          storyIds.insert(newIndex, item);

          final PostModel story = sortedStories.removeAt(oldIndex);
          sortedStories.insert(newIndex, story);
          _hasReordered = true;
        });
      },
      itemBuilder: (context, index) {
        final story = sortedStories[index];
        final imageUrl = story.thumbnail?.media?.url;

        return Container(
          key: Key('story_${story.id}_$index'),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Drag handle
                Icon(
                  Icons.drag_indicator_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
                const SizedBox(width: 14),
                // Position number
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Thumbnail
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.grey.shade50,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.auto_stories_outlined,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.name ?? 'Untitled Story',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${story.id}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
