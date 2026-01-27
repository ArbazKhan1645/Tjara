import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/modules/admin/stories/insert/insert_service.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/services/dashbopard_services/stories_service.dart';

class StoriesItemCard extends StatefulWidget {
  final PostModel product;
  final VoidCallback? onDelete;

  const StoriesItemCard({super.key, required this.product, this.onDelete});

  @override
  State<StoriesItemCard> createState() => _StoriesItemCardState();
}

class _StoriesItemCardState extends State<StoriesItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                boxShadow:
                    _isHovered
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                border: Border.all(
                  color:
                      _isHovered ? Colors.blue.shade200 : Colors.grey.shade200,
                  width: _isHovered ? 1.5 : 1,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            ),
          );
        },
        child: _buildCardContent(),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildCardContent() {
    final imageUrl = widget.product.thumbnail?.media?.url;
    final title = widget.product.name ?? 'Untitled';
    final shopName = widget.product.shop?.shop?.name ?? '-';
    final createdAt = _formatDate(widget.product.createdAt.toString());
    final isActive = widget.product.status == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Thumbnail
          SizedBox(
            width: 120,
            child: Container(
              width: 40,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    imageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget:
                              (context, url, error) => const Icon(
                                Icons.image_not_supported,
                                size: 20,
                              ),
                        )
                        : const Icon(Icons.image, size: 20, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Name
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 20),

          // Status
          SizedBox(
            width: 80,
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green : Colors.red,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 60,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[700]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: _handleMenuSelection,
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      value: 'status',
                      child: _buildMenuItem(
                        icon: Icons.visibility_outlined,
                        label: isActive ? 'Pause' : 'Play',
                        color: Colors.blue,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: _buildMenuItem(
                        icon: Icons.edit_outlined,
                        label: 'Edit Story',
                        color: Colors.orange,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: _buildMenuItem(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: Colors.red,
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final imageUrl = widget.product.thumbnail?.media?.url;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child:
            imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => _buildPlaceholderImage(),
                )
                : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.article_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildShopInfo(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildTitle() {
    final title = widget.product.name ?? 'Untitled Story';

    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildShopInfo() {
    final shopName = widget.product.shop?.shop?.name;

    if (shopName == null || shopName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.store_outlined, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            shopName,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    final createdAt = widget.product.createdAt;
    final formattedDate = _formatDate(createdAt.toString());

    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          'Created $formattedDate',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert,
          size: 20,
          color: _isHovered ? Colors.grey[700] : Colors.grey[500],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      offset: const Offset(-50, 0),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'status',
              child: _buildMenuItem(
                icon: Icons.visibility_outlined,
                label: widget.product.status == 'active' ? 'Pause' : 'Play',
                color: Colors.blue,
              ),
            ),
            PopupMenuItem<String>(
              value: 'edit',
              child: _buildMenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit Story',
                color: Colors.orange,
              ),
            ),

            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildMenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.red,
              ),
            ),
          ],
      onSelected: _handleMenuSelection,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'status':
        widget.product.status == 'active' ? pauseStory() : playStory();
        break;
      case 'edit':
        Get.to(
          () =>
              InsertStoryScreen(existingPost: widget.product, isEditMode: true),
        )?.then((val) {
          Get.find<StoriesService>().refreshData();
        });
        break;

      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }

  playStory() async {
    final response = await http.put(
      Uri.parse(
        'https://api.libanbuy.com/api/posts/${widget.product.id}/update',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
        'X-Request-From': 'Application',
      },
      body: jsonEncode({'post_type': 'shop_stories', 'status': 'active'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await Get.find<StoriesService>().refreshData();
      Get.snackbar(
        'Success',
        'Story updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(microseconds: 500),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(microseconds: 500),
      );
    }
  }

  pauseStory() async {
    final response = await http.put(
      Uri.parse(
        'https://api.libanbuy.com/api/posts/${widget.product.id}/update',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
        'X-Request-From': 'Application',
      },
      body: jsonEncode({'post_type': 'shop_stories', 'status': 'inactive'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await Get.find<StoriesService>().refreshData();
      Get.snackbar(
        'Success',
        'Story updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(microseconds: 500),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(microseconds: 500),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown';
    }

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'today';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).round();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
