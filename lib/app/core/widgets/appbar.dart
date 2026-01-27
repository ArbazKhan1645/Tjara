// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tjara/app/core/widgets/overlay.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/chat_messages/insert_chat.dart';

import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';

import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/chat_messages/chat_messages_service.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';

/// Temu-style AppBar with full-width search
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.showSearch = true,
    this.showActions = true,
    this.showWhitebackground = false,
  });

  final bool showSearch;
  final bool showActions;
  final bool showWhitebackground;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with WidgetsBindingObserver {
  final AppBarController _appBarController = Get.put(AppBarController());

  late ProductChatsService productChatsService;
  bool _isServiceInitialized = false;
  bool _wasKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeService();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;
    if (_wasKeyboardVisible && !isKeyboardVisible) {
      _appBarController.unfocusSearch();
    }
    _wasKeyboardVisible = isKeyboardVisible;
  }

  Future<void> _initializeService() async {
    try {
      if (Get.isRegistered<ProductChatsService>()) {
        productChatsService = Get.find<ProductChatsService>();
      } else {
        productChatsService = Get.put(ProductChatsService());
      }
      await productChatsService.init();
      if (mounted) {
        setState(() => _isServiceInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isServiceInitialized = true);
      }
    }
  }

  // Theme colors based on background
  Color get _backgroundColor =>
      widget.showWhitebackground ? Colors.white : const Color(0xFFfda730);

  Color get _iconColor =>
      widget.showWhitebackground ? const Color(0xFF333333) : Colors.white;

  Color get _iconBgColor =>
      widget.showWhitebackground
          ? Colors.grey.shade100
          : Colors.white.withOpacity(0.2);

  Color get _badgeColor =>
      widget.showWhitebackground ? const Color(0xFFfda730) : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      height: widget.preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Full-width Search Bar
          if (widget.showSearch)
            Expanded(child: _buildSearchBar())
          else
            const Spacer(),

          // Action Icons
          if (widget.showActions && AuthService.instance.islogin) ...[
            const SizedBox(width: 10),
            _buildActionIcons(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            widget.showWhitebackground
                ? Border.all(color: Colors.grey.shade300)
                : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: TextField(
              controller: _appBarController.searchController,

              autofocus: false,
              onChanged: (value) => _appBarController._searchText.value = value,
              onSubmitted: (value) {
                if (_appBarController.searchController.text.isNotEmpty) {
                  _performSearch();
                }
              },
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                prefixIcon: Obx(() {
                  if (_appBarController._searchText.value.isNotEmpty) {
                    return IconButton(
                      onPressed: () {
                        _appBarController.clearSearch();
                      },
                      icon: Icon(
                        Iconsax.close_circle,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                    );
                  }
                  return Icon(
                    Iconsax.search_normal_1,
                    color: Colors.grey[500],
                    size: 18,
                  );
                }),
                contentPadding: EdgeInsets.only(
                  top: widget.showWhitebackground ? 7 : 10,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: Container(
                  width: 20,
                  height: 40,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    color: Color.fromARGB(255, 251, 148, 30),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (_appBarController.searchController.text.isNotEmpty) {
                        _performSearch();
                      }
                    },
                    icon: const Icon(
                      Iconsax.search_normal_1,
                      color: Colors.white,
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                hintText: "Search Tjara...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),

          // Camera/Search Button
        ],
      ),
    );
  }

  Widget _buildActionIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: Icons.notifications_outlined,
          onTap: () {},
          child: NotificationIconButton(color: _iconColor),
        ),
        const SizedBox(width: 8),
        _buildMessagesIcon(),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _iconBgColor,
          shape: BoxShape.circle,
          border:
              widget.showWhitebackground
                  ? Border.all(color: Colors.grey.shade200, width: 1)
                  : null,
        ),
        child: child ?? Icon(icon, color: _iconColor, size: 20),
      ),
    );
  }

  void _performSearch() {
    _appBarController.searchFocusNode.unfocus();
    DashboardController.instance.reset();
    final controller = Get.put(HomeController());
    controller.searchProducts(_appBarController.searchController.text);
    controller.setSelectedCategory(ProductAttributeItems());
  }

  Widget _buildMessagesIcon() {
    if (!_isServiceInitialized) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _iconBgColor,
          shape: BoxShape.circle,
          border:
              widget.showWhitebackground
                  ? Border.all(color: Colors.grey.shade200, width: 1)
                  : null,
        ),
        child: Icon(Iconsax.message, size: 20, color: _iconColor),
      );
    }

    return Obx(() {
      final productChats = productChatsService.productChats.value;
      final chatDataList = productChats.data ?? [];
      final messageCount = chatDataList.length;

      return OverlayMenu(
        menuWidth: 280,
        children:
            (closeOverlay) => [
              const SizedBox(height: 10),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon:
                            productChatsService.isLoading.value
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  Iconsax.refresh,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                        onPressed:
                            productChatsService.isLoading.value
                                ? null
                                : () async {
                                  await productChatsService.refreshData();
                                },
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.grey.shade200),
              Obx(() {
                final currentProductChats =
                    productChatsService.productChats.value;
                final currentChatDataList = currentProductChats.data ?? [];

                if (productChatsService.isLoading.value &&
                    currentChatDataList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading messages...'),
                        ],
                      ),
                    ),
                  );
                } else if (productChatsService.hasError.value &&
                    currentChatDataList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Iconsax.warning_2, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Error loading messages',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await productChatsService.refreshData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (currentChatDataList.isNotEmpty) {
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: currentChatDataList.take(20).length,
                      itemBuilder: (context, index) {
                        final messages = currentChatDataList[index];
                        final firstName = messages.user?.firstName ?? 'Unknown';
                        final lastName = messages.user?.lastName ?? '';
                        final lastMessage =
                            messages.lastMessage ?? 'No message';

                        return ListTile(
                          onTap: () {
                            closeOverlay();
                            startChatWithProduct(
                              messages.productId.toString(),
                              context,
                              productChats: messages,
                              uid: messages.id.toString(),
                            );
                          },
                          dense: true,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(
                              0xFFfda730,
                            ).withOpacity(0.15),
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Color(0xFFfda730),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '$firstName $lastName'.trim().isNotEmpty
                                ? '$firstName $lastName'.trim()
                                : 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing:
                              messages.createdAt != null
                                  ? Text(
                                    _formatDate(messages.createdAt!),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 10,
                                    ),
                                  )
                                  : null,
                        );
                      },
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.message,
                          color: Colors.grey.shade400,
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No Messages',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start a conversation to see messages here',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
              }),
              const SizedBox(height: 10),
            ],
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _iconBgColor,
            shape: BoxShape.circle,
            border:
                widget.showWhitebackground
                    ? Border.all(color: Colors.grey.shade200, width: 1)
                    : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Iconsax.message, size: 20, color: _iconColor),
              if (messageCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _backgroundColor, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return '';
    }
  }
}

class AppBarController extends GetxController {
  static AppBarController get instance => Get.find<AppBarController>();

  final RxString _searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String get searchText => _searchText.value;
  bool get hasSearchText => _searchText.value.isNotEmpty;

  void setSearchText(String text) {
    searchController.text = text;
    _searchText.value = text;
  }

  void clearSearch() {
    searchController.clear();
    _searchText.value = '';
    // searchFocusNode.unfocus();
  }

  void focusSearch() {
    searchFocusNode.requestFocus();
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }
}
