import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/services/model/sevices_model.dart'
    show ServiceData;

class ServiceItemCard extends StatefulWidget {
  const ServiceItemCard({
    super.key,
    required this.product,
    this.onDelete,
    this.onedit,
  });
  final ServiceData product;
  final VoidCallback? onDelete;
  final VoidCallback? onedit;

  @override
  State<ServiceItemCard> createState() => _ServiceItemCardState();
}

class _ServiceItemCardState extends State<ServiceItemCard>
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceIcon(),
            const SizedBox(width: 10),
            Expanded(child: _buildContentSection()),
            _buildPriceSection(),

            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon() {
    final imageUrl = widget.product.thumbnail?.media?.url;

    return Container(
      width: 70,
      height: 70,
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
                  errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                )
                : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.blue.shade50,
      child: Icon(Icons.design_services, color: Colors.blue.shade400, size: 32),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildServiceTitle(),
        const SizedBox(height: 8),
        // _buildCategoryInfo(),
        const SizedBox(height: 12),
        _buildProviderInfo(),
        const SizedBox(height: 8),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildServiceTitle() {
    final title = widget.product.name ?? 'Untitled Service';

    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryInfo() {
    const categoryName = null;

    if (categoryName == null || categoryName.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No Category',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    const providerName = null;

    if (providerName == null || providerName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'by $providerName',
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
    final formattedDate = _formatDate(createdAt);
    final status = widget.product.status ?? 'Unknown';

    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        // _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: statusColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final price = widget.product.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (price != null) ...[
          Text(
            _formatPrice(price),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE53E3E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'price',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Contact for pricing',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
              value: 'edit',
              child: _buildMenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit Service',
                color: Colors.orange,
              ),
            ),

            // const PopupMenuDivider(),
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
      case 'edit':
        widget.onedit?.call();

        break;

      case 'delete':
        widget.onDelete?.call();

        break;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
        return Colors.green;
      case 'inactive':
      case 'unavailable':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.blue;
      case 'maintenance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';

    try {
      final numPrice = double.parse(price.toString());
      final formatter = NumberFormat.currency(
        symbol: '\$',
        decimalDigits: numPrice % 1 == 0 ? 0 : 2,
      );
      return formatter.format(numPrice);
    } catch (e) {
      return price.toString();
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
