// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'package:tjara/app/models/notifications/notification_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

// Updated Notification Service with Pagination
class NotificationService extends GetxService {
  final StreamController<List<NotificationModel>>
  _notificationStreamController =
      StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationStreamController.stream;

  List<NotificationModel> _cachedNotifications = [];

  // Updated method with pagination parameters
  Future<Map<String, dynamic>> fetchNotifications(
    String? userid, {
    int page = 1,
    int perPage = 15,
  }) async {
    if (userid == null) return {'notifications': [], 'hasMore': false};

    final url = Uri.parse(
      'https://api.libanbuy.com/api/notifications?page=$page&per_page=$perPage',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'dashboard-view':
              AuthService.instance.authCustomer?.user?.meta?.dashboardView ??
              '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> notificationsData = data['notifications'];
        final List<dynamic> notificationsJson = notificationsData['data'];

        final List<NotificationModel> notifications =
            notificationsJson
                .map((json) => NotificationModel.fromJson(json))
                .toList();

        // For pagination, only cache the current page data (don't append)
        _cachedNotifications = notifications;

        _notificationStreamController.add(_cachedNotifications);

        return {
          'notifications': notifications,
          'currentPage': notificationsData['current_page'] ?? page,
          'totalPages': notificationsData['last_page'] ?? 1,
          'totalCount': notificationsData['total'] ?? notifications.length,
          'hasMore':
              (notificationsData['current_page'] ?? page) <
              (notificationsData['last_page'] ?? 1),
        };
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print(e);
      _notificationStreamController.add(_cachedNotifications);
      return {'notifications': [], 'hasMore': false, 'error': e.toString()};
    }
  }

  @override
  void onClose() {
    _notificationStreamController.close();
    super.onClose();
  }

  Future<NotificationService> init() async {
    // initCall();
    return this;
  }

  Future<void> initCall() async {
    final LoginResponse? userCurrent = AuthService.instance.authCustomer;
    if (userCurrent?.user?.id == null) {
      _notificationStreamController.add([]);
    } else {
      fetchNotifications(userCurrent?.user?.id.toString() ?? '');
    }
  }
}

// Updated IconButton with notification dialog
class NotificationIconButton extends StatefulWidget {
  const NotificationIconButton({super.key, this.color = Colors.white});
  final Color color;

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Iconsax.notification, color: widget.color, size: 22),
          onPressed: () {
            _showNotificationDialog(context);
          },
        ),
      ],
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NotificationDialog();
      },
    );
  }
}

// Notification Dialog with Pagination
class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  List<NotificationModel> notifications = [];
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  bool hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({
    int page = 1,
    bool isRefresh = false,
  }) async {
    setState(() {
      isLoading = true;
      hasError = false;
      if (isRefresh) {
        notifications.clear();
        currentPage = 1;
      }
    });

    try {
      final LoginResponse? userCurrent = AuthService.instance.authCustomer;
      if (userCurrent?.user?.id == null) {
        setState(() {
          hasError = true;
          errorMessage = 'User not authenticated';
          isLoading = false;
        });
        return;
      }

      final response = await _notificationService.fetchNotifications(
        userCurrent!.user!.id.toString(),
        page: isRefresh ? 1 : page,
        perPage: 15,
      );

      if (response.containsKey('error')) {
        setState(() {
          hasError = true;
          errorMessage = response['error'];
          isLoading = false;
        });
        return;
      }

      final List<NotificationModel> newNotifications =
          response['notifications'] as List<NotificationModel>;

      setState(() {
        // For pagination, always replace the data (don't append for any page)
        notifications = newNotifications;
        currentPage = response['currentPage'] ?? page;
        totalPages = response['totalPages'] ?? 1;
        totalCount = response['totalCount'] ?? 0;
        hasMore = response['hasMore'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 20,
                vertical: MediaQuery.of(context).size.width < 400 ? 12 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      'Notifications ($totalCount)',
                      style: defaultTextStyle.copyWith(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width < 400
                                      ? 36
                                      : 48,
                              minHeight:
                                  MediaQuery.of(context).size.width < 400
                                      ? 36
                                      : 48,
                            ),
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width < 400 ? 6 : 8,
                            ),
                            onPressed: () {
                              _loadNotifications(isRefresh: true);
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size:
                                  MediaQuery.of(context).size.width < 400
                                      ? 18
                                      : 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width < 400
                                      ? 36
                                      : 48,
                              minHeight:
                                  MediaQuery.of(context).size.width < 400
                                      ? 36
                                      : 48,
                            ),
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width < 400 ? 6 : 8,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.black87,
                              size:
                                  MediaQuery.of(context).size.width < 400
                                      ? 18
                                      : 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildContent()),

            // Pagination
            if (!isLoading && !hasError && totalPages > 1)
              _buildPagination()
            else
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pagination: isLoading=$isLoading, hasError=$hasError, totalPages=$totalPages',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: defaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (hasError && notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: defaultTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: defaultTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loadNotifications(isRefresh: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Retry',
                  style: defaultTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No notifications yet',
                style: defaultTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll see your notifications here when they arrive',
                style: defaultTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(notification);
                },
              ),
              // Show loading overlay when switching pages
              if (isLoading && notifications.isNotEmpty)
                Container(
                  color: Colors.white.withOpacity(0.9),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0D9488),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Loading...',
                            style: defaultTextStyle.copyWith(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          notification.title,
          style: defaultTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              notification.description,
              style: defaultTextStyle.copyWith(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDateTime(notification.createdAt),
                    style: defaultTextStyle.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF0D9488),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
          // You can add navigation or mark as read functionality here
        },
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Page $currentPage of $totalPages',
            style: defaultTextStyle.copyWith(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Use Wrap to prevent overflow instead of Flexible
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              // Previous button
              Container(
                decoration: BoxDecoration(
                  color:
                      currentPage > 1
                          ? const Color(0xFF0D9488)
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed:
                      currentPage > 1
                          ? () => _loadNotifications(page: currentPage - 1)
                          : null,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 8),

              // Page numbers - limit to 3 visible pages to prevent overflow
              ..._buildPageNumbers(),

              const SizedBox(width: 8),
              // Next button
              Container(
                decoration: BoxDecoration(
                  color:
                      currentPage < totalPages
                          ? const Color(0xFF0D9488)
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed:
                      currentPage < totalPages
                          ? () => _loadNotifications(page: currentPage + 1)
                          : null,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pageNumbers = [];

    // Show maximum 3 page numbers to prevent overflow
    int startPage = currentPage;
    int endPage = currentPage;

    if (currentPage == 1) {
      startPage = 1;
      endPage = (totalPages >= 3) ? 3 : totalPages;
    } else if (currentPage == totalPages) {
      startPage = (totalPages >= 3) ? totalPages - 2 : 1;
      endPage = totalPages;
    } else {
      startPage = currentPage - 1;
      endPage = currentPage + 1;
    }

    for (int i = startPage; i <= endPage; i++) {
      final isSelected = i == currentPage;
      pageNumbers.add(
        GestureDetector(
          onTap: () => _loadNotifications(page: i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D9488) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF0D9488) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Text(
              i.toString(),
              style: defaultTextStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    }

    return pageNumbers;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
