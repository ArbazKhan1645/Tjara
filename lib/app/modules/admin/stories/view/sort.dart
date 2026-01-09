import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tjara/app/models/posts/posts_model.dart';
// Import your PostModel here
// import 'your_post_model.dart';

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
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Split the comma-separated string into list
    storyIds =
        widget.headerStoriesSortOrder
            .split(',')
            .map((id) => id.trim())
            .toList();
    print(storyIds);
  }

  Future<List<PostModel>> fetchPostsByIds(List<String> ids) async {
    final List<PostModel> posts = [];

    for (String id in ids) {
      try {
        // Replace with your actual API endpoint for fetching individual posts
        final response = await http.get(
          Uri.parse(
            'https://api.libanbuy.com/api/posts?with=thumbnail&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=post_type&filterByColumns[columns][0][value]=shop_stories&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=id&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=$id&orderBy=created_at&order=desc&per_page=100',
          ),
          headers: {
            'X-Request-From': 'Application',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          posts.add(PostModel.fromJson(data['posts']['data'][0]));
        }
      } catch (e) {
        print('Error fetching post $id: $e');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sort order updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update sort order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating sort order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<PostModel>>(
        future: fetchPostsByIds(storyIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading stories: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No stories found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          sortedStories = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drag and drop stories to reorder them. Don\'t forget to save your changes!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 800,
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedStories.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final String item = storyIds.removeAt(oldIndex);
                      storyIds.insert(newIndex, item);

                      final PostModel story = sortedStories.removeAt(oldIndex);
                      sortedStories.insert(newIndex, story);
                    });
                  },
                  itemBuilder: (context, index) {
                    final story = sortedStories[index];
                    print(
                      'Story at index $index: ${story.name}',
                    ); // Debug print
                    return Card(
                      key: Key('story_${story.id}_$index'),
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          story.name ?? 'Untitled Story',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
