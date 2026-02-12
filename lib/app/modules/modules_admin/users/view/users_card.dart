import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/view.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/users/insert/insert_user.dart';
import 'package:tjara/app/services/dashbopard_services/users_service.dart';

class UsersItemCard extends StatefulWidget {
  final User product;
  final VoidCallback? onDelete;

  const UsersItemCard({super.key, required this.product, this.onDelete});

  @override
  State<UsersItemCard> createState() => _UsersItemCardState();
}

class _UsersItemCardState extends State<UsersItemCard>
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
            _buildUserAvatar(),
            const SizedBox(width: 10),
            Expanded(child: _buildUserInfo()),

            const SizedBox(width: 6),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final firstName = widget.product.firstName ?? '';
    final lastName = widget.product.lastName ?? '';
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}'
        '${lastName.isNotEmpty ? lastName[0] : ''}';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAvatarColor(initials),
            _getAvatarColor(initials).withOpacity(0.8),
          ],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildUserName(),
        const SizedBox(height: 6),
        _buildUserEmail(),
        const SizedBox(height: 12),
        _buildUserDetails(),
        const SizedBox(height: 8),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildUserName() {
    final fullName =
        '${widget.product.firstName ?? ''} ${widget.product.lastName ?? ''}'
            .trim();

    return Text(
      fullName.isNotEmpty ? fullName : 'Unknown User',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUserEmail() {
    final email = widget.product.email;

    if (email == null || email.isEmpty) {
      return Text(
        'No email provided',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      children: [
        Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildEmailVerificationBadge(),
      ],
    );
  }

  Widget _buildEmailVerificationBadge() {
    final isVerified = widget.product.emailVerifiedAt != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 12,
            color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color:
                  isVerified ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails() {
    final role = widget.product.role ?? 'No Role';
    final phone = widget.product.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role
        Row(
          children: [
            Icon(Icons.work_outline, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getRoleColor(role).withOpacity(0.3)),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getRoleColor(role),
                ),
              ),
            ),
          ],
        ),

        // Phone (if available)
        if (phone != null && phone.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(Icons.numbers_rounded, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              widget.product.meta?.userId ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    final createdAt = widget.product.createdAt;
    final formattedDate = _formatDate(createdAt);

    return Row(
      children: [
        Icon(Icons.person_add_outlined, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          'Joined $formattedDate',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    final status = widget.product.status ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
            if (widget.product.shop == null)
              PopupMenuItem<String>(
                value: 'Create Shop',
                child: _buildMenuItem(
                  icon: Icons.shop_two,
                  label: 'Create Shop',
                  color: Colors.red,
                ),
              ),
            PopupMenuItem<String>(
              value: 'Edit Customer',
              child: _buildMenuItem(
                icon: Icons.edit,
                label: 'Edit Customer',
                color: Colors.red,
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildMenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.red,
              ),
            ),
            PopupMenuItem<String>(
              value: 'reseller',
              child: _buildMenuItem(
                icon: Icons.edit_attributes,
                label: 'Edit Reseller',
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
      case 'reseller':
        Get.to(
          () => const ResellerProgramScreen(),
          arguments: {'userId': widget.product.id},
          preventDuplicates: false,
        );
        break;
      case 'Edit Customer':
        Get.to(
          () => InsertNewUser(existingUser: widget.product),

          preventDuplicates: false,
        )?.then((c) {
          Get.find<AdminUsersService>().refreshData();
        });
        break;
      case 'Create Shop':
        updateUserToVendor(widget.product.id.toString());
        break;
      case 'activity':
        // View activity log
        break;
      case 'suspend':
        // Suspend user logic
        break;
      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }

  Future<void> updateUserToVendor(String userId) async {
    final url = Uri.parse(
      'https://api.libanbuy.com/api/users/update-user-to-vendor/$userId',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-Request-From": "Application",
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User has been updated to vendor successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Update failed';
        Get.snackbar(
          'Error',
          message.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      Get.find<AdminUsersService>().refreshData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Color _getAvatarColor(String initials) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
    ];

    final hash = initials.hashCode.abs();
    return colors[hash % colors.length];
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'editor':
        return Colors.blue;
      case 'user':
      case 'customer':
        return Colors.green;
      case 'vendor':
      case 'seller':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'banned':
        return Colors.red.shade800;
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
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).round();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
