import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/home/widgets/stories.dart';

class VideoThumbnailList extends StatefulWidget {
  final List<String> videoUrls;

  const VideoThumbnailList({super.key, required this.videoUrls});

  @override
  State<VideoThumbnailList> createState() => _VideoThumbnailListState();
}

class _VideoThumbnailListState extends State<VideoThumbnailList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 160,
        child: GetBuilder<HomeController>(
          builder: (controller) {
            if (controller.posts.value.posts.data.isEmpty) {
              return _buildEmptyState();
            }

            return _buildThumbnailList(controller);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No videos available'));
  }

  Widget _buildThumbnailList(HomeController controller) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: controller.posts.value.posts.data.length,

      physics: const BouncingScrollPhysics(),

      itemBuilder: (context, index) {
        final post = controller.posts.value.posts.data[index];
        return VideoThumbnailItem(
          post: post,
          onTap: () {
            showVideoFeedDialog(
              context,
              controller.posts.value.posts.data,
              post,
            ).then((_) async {
              print('objectsdddddddddddddddddddddddddddd');
              await controller.fetchLatestPost(forceRefresh: true);
              controller.update();
              setState(() {});
            });
          },
        );
      },
    );
  }
}

class VideoThumbnailItem extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const VideoThumbnailItem({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SizedBox(
        width: 110,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: CachedNetworkImage(
                        cacheManager: PersistentCacheManager(),
                        imageUrl:
                            post.thumbnail?.media?.optimizedMediaUrl ??
                            post.thumbnail?.media?.url ??
                            post.thumbnail?.media?.localUrl ??
                            '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget:
                            (context, url, error) => _buildErrorWidget(),
                        fadeInDuration: const Duration(milliseconds: 200),
                        memCacheWidth: 200,
                      ),
                    ),

                    // Play Button
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Image.asset('assets/icons/logo.png'),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.error, color: Colors.red),
    );
  }
}
