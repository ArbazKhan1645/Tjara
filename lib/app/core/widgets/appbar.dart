// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/categories/categories_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          widget.showWhitebackground != true
              ? const Color(0xFFfda730)
              : Colors.white,
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
            const SizedBox(width: 12),
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
                    // ← yeh change karo
                    return IconButton(
                      onPressed: () {
                        _appBarController.clearSearch();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 15,
                      ),
                    );
                  }
                  return Icon(Icons.search, color: Colors.grey[500], size: 15);
                }),
                contentPadding: const EdgeInsets.all(11),
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
                      Icons.search,
                      color: Colors.white,
                      size: 15,
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
          child: const NotificationIconButton(color: Colors.white),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: child ?? Icon(icon, color: Colors.white, size: 20),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chat_bubble_outline,
          size: 20,
          color: Colors.white,
        ),
      );
    }

    return Obx(() {
      final productChats = productChatsService.productChats.value;
      final chatDataList = productChats.data ?? [];
      final messageCount = chatDataList.length;

      return GestureDetector(
        onTap: () {
          // Navigate to messages
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: Colors.white,
              ),
              if (messageCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
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
