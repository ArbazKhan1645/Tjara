import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/modules/modules_customer/tjara_videos/controllers/tjara_videos_controller.dart';
import 'package:tjara/app/modules/modules_customer/tjara_videos/service/tjara_videos_service.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/models/products/single_product_model.dart' as spm;
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/quick_buy_checkout_sheet.dart';

/// Normalizes shop JSON so that double-nested media (media.media) is flattened
/// to single nesting (media) for compatibility with ShopShop.fromJson → Video.fromJson.
Map<String, dynamic> _normalizeShopJson(Map<String, dynamic> shopData) {
  final normalized = Map<String, dynamic>.from(shopData);
  for (final key in ['thumbnail', 'banner', 'membership']) {
    final wrapper = normalized[key];
    if (wrapper is Map<String, dynamic>) {
      final innerMedia = wrapper['media'];
      if (innerMedia is Map<String, dynamic> && innerMedia['media'] is Map<String, dynamic>) {
        normalized[key] = {'media': innerMedia['media']};
      }
    }
  }
  return normalized;
}

class TjaraVideosView extends StatefulWidget {
  const TjaraVideosView({super.key});

  @override
  State<TjaraVideosView> createState() => _TjaraVideosViewState();
}

class _TjaraVideosViewState extends State<TjaraVideosView>
    with WidgetsBindingObserver {
  late final TjaraVideosController _controller;
  late final PageController _pageController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = Get.find<TjaraVideosController>();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    _controller.onAppLifecycleChanged(state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (_controller.videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'No videos available',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _controller.refresh(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Video PageView
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _controller.videos.length,
              onPageChanged: _controller.onPageChanged,
              itemBuilder: (context, index) {
                return _VideoItemWidget(
                  key: ValueKey(_controller.videos[index].product.id ?? index),
                  video: _controller.videos[index],
                  index: index,
                  controller: _controller,
                );
              },
            ),

            // Top bar: X button, counter, mute
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    // Video counter
                    Obx(() {
                      final current = _controller.currentIndex.value + 1;
                      final total = _controller.videos.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$current / $total +',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                    // Volume toggle
                    _VolumeToggleButton(controller: _controller),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// --- Volume Toggle ---
class _VolumeToggleButton extends StatefulWidget {
  final TjaraVideosController controller;
  const _VolumeToggleButton({required this.controller});

  @override
  State<_VolumeToggleButton> createState() => _VolumeToggleButtonState();
}

class _VolumeToggleButtonState extends State<_VolumeToggleButton> {
  bool _isMuted = false;

  void _toggle() {
    setState(() => _isMuted = !_isMuted);
    final vc = widget.controller.getControllerAt(
      widget.controller.currentIndex.value,
    );
    vc?.setVolume(_isMuted ? 0.0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          _isMuted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// --- Single Video Item ---
class _VideoItemWidget extends StatelessWidget {
  final VideoProduct video;
  final int index;
  final TjaraVideosController controller;

  const _VideoItemWidget({
    super.key,
    required this.video,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final product = video.product;
    final price = product.price ?? 0;
    final salePrice = product.salePrice;
    final stock = product.stock ?? 0;
    final hasSalePrice = salePrice != null && salePrice > 0;
    final displayPrice = hasSalePrice ? salePrice : price;
    final bool inStock = stock.toInt() > 0;

    return GestureDetector(
      onTap: controller.togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player or thumbnail fallback
          _VideoPlayerWidget(
            index: index,
            controller: controller,
            thumbnailUrl: video.thumbnailUrl,
          ),

          // Gradient overlay at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ),

          // Play/Pause indicator (center)
          Obx(() {
            final isCurrentIndex = controller.currentIndex.value == index;
            final isPlaying = controller.isCurrentVideoPlaying.value;
            if (!isCurrentIndex || isPlaying) return const SizedBox.shrink();
            return Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          }),

          // Right side action buttons
          Positioned(
            right: 12,
            bottom: 200,
            child: GetBuilder<TjaraVideosController>(
              builder:
                  (_) => _ActionButtons(video: video, controller: controller),
            ),
          ),

          // Bottom section: Stock badge, price, buy now, shop info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 12, right: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stock badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            inStock
                                ? const Color(0xFFFF6B35)
                                : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inStock ? 'Limited Stock' : 'Out of Stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price row + Cart + Buy Now
                    Row(
                      children: [
                        // Price badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'ONLY',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '\$${displayPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Cart icon button
                        _CartButton(video: video, inStock: inStock),
                        const SizedBox(width: 8),

                        // Buy Now button
                        _BuyNowButton(video: video, inStock: inStock),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Shop info row
                    InkWell(
                      onTap: () {
                        final rawShop = video.rawShopJson;
                        spm.ShopShop? storeShop;
                        if (rawShop != null) {
                          storeShop = spm.ShopShop.fromJson(
                            _normalizeShopJson(rawShop),
                          );
                        }
                        Get.toNamed(
                          Routes.STORE_PAGE,
                          arguments: {
                            'shopid': product.shop?.shop?.id,
                            'ShopShop': storeShop,
                          },
                        );
                      },
                      child: Row(
                        children: [
                          // Shop avatar
                          ClipOval(
                            child: Container(
                              width: 32,
                              height: 32,
                              color: Colors.teal,
                              child:
                                  video.shopThumbnailUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                        imageUrl: video.shopThumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (_, __, ___) => Center(
                                              child: Text(
                                                video.shopName.isNotEmpty
                                                    ? video.shopName[0]
                                                        .toUpperCase()
                                                    : 'S',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                      )
                                      : Center(
                                        child: Text(
                                          video.shopName.isNotEmpty
                                              ? video.shopName[0].toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.shopName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  product.name ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// --- Video Player Widget ---
class _VideoPlayerWidget extends StatelessWidget {
  final int index;
  final TjaraVideosController controller;
  final String thumbnailUrl;

  const _VideoPlayerWidget({
    required this.index,
    required this.controller,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read reactive values to trigger rebuild when video state changes
      controller.currentIndex.value;
      controller.videoInitCount.value;
      final vc = controller.getControllerAt(index);
      final isInit = vc != null && vc.value.isInitialized;

      if (isInit) {
        return Center(
          child: AspectRatio(
            aspectRatio: vc.value.aspectRatio,
            child: VideoPlayer(vc),
          ),
        );
      }

      // Show thumbnail as placeholder while video loads
      if (thumbnailUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: thumbnailUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorWidget: (_, __, ___) => Container(color: Colors.black),
        );
      }

      return Container(color: Colors.black);
    });
  }
}

// --- Right Side Action Buttons ---
class _ActionButtons extends StatelessWidget {
  final VideoProduct video;
  final TjaraVideosController controller;

  const _ActionButtons({required this.video, required this.controller});

  @override
  Widget build(BuildContext context) {
    final productId = video.product.id ?? '';
    final likesCount = controller.getLikesCount(video);
    final isLiked = controller.isLiked(productId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        _ActionItem(
          icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: _formatCount(likesCount),
          color: isLiked ? const Color(0xFF4FC3F7) : Colors.white,
          onTap: () => controller.toggleLike(video),
        ),
        const SizedBox(height: 20),

        // Views
        _ActionItem(
          icon: Icons.remove_red_eye_outlined,
          label: _formatCount(video.views),
          onTap: () {},
        ),
        const SizedBox(height: 20),

        // Comments
        _ActionItem(
          icon: Icons.chat_bubble_outline,
          label: '0',
          onTap: () => _showCommentsSheet(context, video),
        ),
        const SizedBox(height: 20),

        // Share
        _ActionItem(
          icon: Icons.reply,
          label: '',
          iconFlip: true,
          onTap: () {
            final link =
                'https://libanbuy.com/product/${video.product.slug ?? ''}';
            SharePlus.instance.share(ShareParams(text: link));
          },
        ),
        const SizedBox(height: 20),

        // Copy link
        _ActionItem(
          icon: Icons.link,
          label: '',
          onTap: () {
            final link =
                'https://libanbuy.com/product/${video.product.slug ?? ''}';
            Clipboard.setData(ClipboardData(text: link));
            if (context.mounted) {
              NotificationHelper.showSuccess(
                context,
                'Copied',
                'Link copied to clipboard',
              );
            }
          },
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool iconFlip;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.iconFlip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconFlip
              ? Transform.flip(
                flipX: true,
                child: Icon(icon, color: color, size: 28),
              )
              : Icon(icon, color: color, size: 28),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

// --- Comments Bottom Sheet ---
void _showCommentsSheet(BuildContext context, VideoProduct video) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CommentsSheet(video: video),
  );
}

class _CommentsSheet extends StatefulWidget {
  final VideoProduct video;
  const _CommentsSheet({required this.video});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<CommentData> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  int _page = 1;
  bool _hasMore = false;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final productId = widget.video.product.id ?? '';
    if (productId.isEmpty) return;

    setState(() => _isLoading = true);
    final response = await TjaraVideosService.fetchComments(
      productId: productId,
      page: _page,
    );
    if (!mounted) return;
    setState(() {
      _comments.addAll(response.comments);
      _total = response.total;
      _hasMore = response.hasMore;
      _isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Login Required',
          'Please login to comment',
        );
      }
      return;
    }

    setState(() => _isSending = true);
    final result = await TjaraVideosService.addComment(
      productId: widget.video.product.id ?? '',
      comment: text,
    );
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _comments.insert(0, result);
        _total++;
        _isSending = false;
      });
      _commentController.clear();
    } else {
      setState(() => _isSending = false);
      if (mounted) {
        NotificationHelper.showError(context, 'Error', 'Failed to add comment');
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final success = await TjaraVideosService.deleteComment(
      commentId: commentId,
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _comments.removeWhere((c) => c.id == commentId);
        _total--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comments ($_total)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          // Comments list
          Expanded(
            child:
                _isLoading && _comments.isEmpty
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : _comments.isEmpty
                    ? const Center(
                      child: Text(
                        'No comments yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                    : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification &&
                            notification.metrics.extentAfter < 100 &&
                            _hasMore &&
                            !_isLoading) {
                          _page++;
                          _loadComments();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _comments.length,
                        itemBuilder: (ctx, i) {
                          final c = _comments[i];
                          final currentUserId =
                              AuthService.instance.authCustomer?.user?.id;
                          final isOwn = c.userId == currentUserId;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.teal,
                                  backgroundImage:
                                      c.userThumbnail != null
                                          ? NetworkImage(c.userThumbnail!)
                                          : null,
                                  child:
                                      c.userThumbnail == null
                                          ? Text(
                                            c.userName.isNotEmpty
                                                ? c.userName[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.userName,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.comment,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwn)
                                  GestureDetector(
                                    onTap: () => _deleteComment(c.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
          const Divider(height: 1, color: Colors.white12),
          // Comment input
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: bottomInset + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : _sendComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:
                        _isSending
                            ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Cart Button ---
class _CartButton extends StatefulWidget {
  final VideoProduct video;
  final bool inStock;
  const _CartButton({required this.video, required this.inStock});

  @override
  State<_CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<_CartButton> {
  bool _isLoading = false;

  Future<void> _addToCart() async {
    if (_isLoading || !widget.inStock) return;

    final currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Login Required',
          'Please login to add to cart',
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = widget.video.product;
      final price =
          (product.salePrice != null && product.salePrice! > 0)
              ? product.salePrice!.toDouble()
              : (product.price?.toDouble() ?? 0.0);

      final result = await CartService.instance.updateCart(
        product.shopId ?? '',
        product.id ?? '',
        1,
        price,
      );

      if (!mounted) return;

      if (result is String) {
        NotificationHelper.showError(context, 'Failed', result);
      } else if (result is bool && result) {
        NotificationHelper.showSuccess(context, 'Success', 'Added to cart');
        try {
          (Get.isRegistered<DashboardController>()
                  ? Get.find<DashboardController>()
                  : Get.put(DashboardController()))
              .fetchCartCount();
        } catch (_) {}
      } else {
        NotificationHelper.showError(
          context,
          'Failed',
          'Failed to add to cart',
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Failed',
          'Failed to add to cart',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _addToCart,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              widget.inStock ? const Color(0xFF009688) : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _isLoading
                ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 22,
                ),
      ),
    );
  }
}

// --- Buy Now Button ---
class _BuyNowButton extends StatefulWidget {
  final VideoProduct video;
  final bool inStock;
  const _BuyNowButton({required this.video, required this.inStock});

  @override
  State<_BuyNowButton> createState() => _BuyNowButtonState();
}

class _BuyNowButtonState extends State<_BuyNowButton> {
  Future<void> _buyNow() async {
    if (!widget.inStock) return;

    final currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Login Required',
          'Please login to buy',
        );
      }
      return;
    }

    final product = widget.video.product;
    final price =
        (product.salePrice != null && product.salePrice! > 0)
            ? product.salePrice!.toDouble()
            : (product.price?.toDouble() ?? 0.0);

    final shippingFee =
        double.tryParse(product.meta?.shipping_fees ?? '0') ?? 0.0;

    await showQuickBuyCheckoutSheet(
      context: context,
      productId: product.id ?? '',
      shopId: product.shopId ?? '',
      productName: product.name ?? 'Product',
      productImageUrl: widget.video.thumbnailUrl,
      price: price,
      shippingFee: shippingFee,
      quantity: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _buyNow,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient:
              widget.inStock
                  ? const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFC62828)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                  : null,
          color: widget.inStock ? null : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              color: widget.inStock ? Colors.white : Colors.white60,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'BUY NOW',
              style: TextStyle(
                color: widget.inStock ? Colors.white : Colors.white60,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
