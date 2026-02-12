import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/overlay.dart';
import 'package:tjara/app/models/chat_messages/chat_messages_model.dart';
import 'package:tjara/app/models/chat_messages/insert_chat.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/authentication_module/screens/contact_us.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/chat_messages/chat_messages_service.dart';
import 'package:tjara/app/modules/authentication_module/screens/login.dart';

class ChatsScreenView extends StatefulWidget {
  const ChatsScreenView({super.key});

  @override
  State<ChatsScreenView> createState() => _ChatsScreenViewState();
}

class _ChatsScreenViewState extends State<ChatsScreenView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final ScrollController _dataTableScrollController;
  late final ScrollController _inboxScrollController;
  late final ProductChatsService _productChatsService;
  late final OrdersDashboardController _controller;
  late final OrderService _orderService;
  late final TextEditingController _searchController;
  late final TextEditingController _inboxSearchController;
  late TabController _tabController;

  bool _isAppBarExpanded = true;
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<String> _inboxSearchQuery = ValueNotifier('');
  final ValueNotifier<int> _selectedFilter = ValueNotifier(0);

  // Check if user is customer (only sees Sent tab)
  bool get _isCustomer =>
      AuthService.instance.authCustomer?.user?.role == 'customer';

  // Debounce timer for search
  Timer? _debounceTimer;
  Timer? _inboxDebounceTimer;

  // Pre-defined gradients to avoid recalculation
  static const LinearGradient _expandedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.teal, Colors.teal],
  );

  static const LinearGradient _collapsedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.teal, Colors.teal],
  );

  static const LinearGradient _expandedStackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.teal, Colors.teal],
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _dataTableScrollController =
        ScrollController()..addListener(_onDataTableScroll);
    _inboxScrollController = ScrollController();
    _searchController = TextEditingController();
    _inboxSearchController = TextEditingController();

    // Tab controller - 1 tab for customer, 2 tabs for admin/vendor
    _tabController = TabController(length: _isCustomer ? 1 : 2, vsync: this);

    _productChatsService = Get.put(ProductChatsService());
    _controller = Get.put(OrdersDashboardController());
    _orderService = Get.find<OrderService>();

    // Initialize services
    _productChatsService.init();

    // Fetch inbox data if not customer
    if (!_isCustomer) {
      _productChatsService.fetchInboxData(refresh: true);
    }

    // Listen to search changes
    _searchQuery.addListener(_onSearchChanged);
    _inboxSearchQuery.addListener(_onInboxSearchChanged);
    _selectedFilter.addListener(_onFilterChanged);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final shouldBeExpanded = _scrollController.offset < 30;
    if (_isAppBarExpanded != shouldBeExpanded) {
      setState(() => _isAppBarExpanded = shouldBeExpanded);
    }
  }

  void _onDataTableScroll() {
    // Remove auto-loading logic since we're using page-based pagination
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _productChatsService.searchChats(_searchQuery.value);
    });
  }

  void _onInboxSearchChanged() {
    _inboxDebounceTimer?.cancel();
    _inboxDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _productChatsService.fetchInboxData(
        refresh: true,
        search: _inboxSearchQuery.value,
      );
    });
  }

  void _onFilterChanged() {
    _productChatsService.filterChats(_selectedFilter.value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dataTableScrollController.dispose();
    _inboxScrollController.dispose();
    _searchController.dispose();
    _inboxSearchController.dispose();
    _searchQuery.dispose();
    _inboxSearchQuery.dispose();
    _selectedFilter.dispose();
    _debounceTimer?.cancel();
    _inboxDebounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: 80,
      backgroundColor: Colors.teal,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient:
                _isAppBarExpanded ? _expandedGradient : _collapsedGradient,
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      title: const Text(
        'Dashboard',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [AdminAppBarActions()];
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: _isAppBarExpanded ? _expandedStackGradient : null,
          ),
          height: MediaQuery.of(context).size.height / 2.6,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildChatDataTable(),
        ),
      ],
    );
  }

  Widget _buildChatDataTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildDataTable(),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inquiry Chats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!_isCustomer) const SizedBox(height: 16),
        // Tab Bar - only show if not customer
        if (!_isCustomer)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Chat Inbox'), Tab(text: 'Sent')],
            ),
          ),
      ],
    );
  }

  Widget _buildDataTable() {
    // Customer only sees Sent tab content
    if (_isCustomer) {
      return Container(
        width: double.infinity,
        height: 1050,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(child: _buildDataContent()),
          ],
        ),
      );
    }

    // Admin/Vendor sees both tabs
    return Container(
      width: double.infinity,
      height: 1050,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Chat Inbox (Receive)
          Column(
            children: [
              _buildInboxSearchAndFilters(),
              Expanded(child: _buildInboxDataContent()),
            ],
          ),
          // Tab 2: Sent
          Column(
            children: [
              _buildSearchAndFilters(),
              Expanded(child: _buildDataContent()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (value) => _searchQuery.value = value.toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Search users, shops, or messages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, value, child) {
                    return value.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery.value = '';
                          },
                        )
                        : const SizedBox.shrink();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips
            // ValueListenableBuilder<int>(
            //   valueListenable: _selectedFilter,
            //   builder: (context, selectedIndex, child) {
            //     return Row(
            //       children: [
            //         _buildFilterChip('All', 0, selectedIndex),
            //         const SizedBox(width: 8),
            //         _buildFilterChip('Active', 1, selectedIndex),
            //         const SizedBox(width: 8),
            //         _buildFilterChip('Inactive', 2, selectedIndex),
            //         const Spacer(),
            //         Obx(() => _buildRefreshButton()),
            //       ],
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _selectedFilter.value = index,
      selectedColor: const Color(0xFF1F8C3B).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1F8C3B),
    );
  }

  // ==========================================
  // INBOX TAB WIDGETS
  // ==========================================
  Widget _buildInboxSearchAndFilters() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inboxSearchController,
              onChanged:
                  (value) => _inboxSearchQuery.value = value.toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Search inbox messages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<String>(
                  valueListenable: _inboxSearchQuery,
                  builder: (context, value, child) {
                    return value.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _inboxSearchController.clear();
                            _inboxSearchQuery.value = '';
                          },
                        )
                        : const SizedBox.shrink();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInboxDataContent() {
    return Obx(() {
      if (_productChatsService.isLoadingInbox.value &&
          _productChatsService.inboxMessageCount == 0) {
        return _buildLoadingState();
      }

      final inboxList = _productChatsService.inboxChatsList;

      if (inboxList.isEmpty) {
        return _buildEmptyState();
      }

      return _buildInboxDataList(inboxList);
    });
  }

  Widget _buildInboxDataList(List<ChatData> chatDataList) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _inboxScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF0D9488),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFFFFFF),
                ),
                columnSpacing: 20,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    chatDataList
                        .map((chatData) => _buildDataRow(chatData))
                        .toList(),
              ),
            ),
          ),
        ),
        _buildInboxPaginationControls(),
      ],
    );
  }

  Widget _buildInboxPaginationControls() {
    return Obx(() {
      final totalPages = _productChatsService.inboxTotalPages.value;
      if (totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          children: [
            Text(
              _productChatsService.inboxPaginationInfo,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        _productChatsService.canGoPreviousInbox &&
                                !_productChatsService.isLoadingInbox.value
                            ? () => _productChatsService.previousInboxPage()
                            : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous page',
                  ),
                  const SizedBox(width: 8),
                  ..._buildInboxPageNumbers(),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        _productChatsService.canGoNextInbox &&
                                !_productChatsService.isLoadingInbox.value
                            ? () => _productChatsService.nextInboxPage()
                            : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next page',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildInboxPageNumbers() {
    final currentPage = _productChatsService.inboxCurrentPage.value;
    final visiblePages = _productChatsService.inboxVisiblePages;
    final isLoading = _productChatsService.isLoadingInbox.value;

    return visiblePages.map((page) {
      if (page == -1) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey)),
        );
      }

      final isCurrentPage = page == currentPage;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                isLoading || isCurrentPage
                    ? null
                    : () => _productChatsService.goToInboxPage(page),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isCurrentPage
                        ? const Color(0xFF0D9488)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isCurrentPage
                          ? const Color(0xFF0D9488)
                          : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child:
                    isLoading && isCurrentPage
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          page.toString(),
                          style: TextStyle(
                            color:
                                isCurrentPage ? Colors.white : Colors.grey[700],
                            fontWeight:
                                isCurrentPage
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon:
          _productChatsService.isLoading.value
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.refresh),
      onPressed:
          _productChatsService.isLoading.value
              ? null
              : () => _productChatsService.refreshData(),
      tooltip: 'Refresh',
    );
  }

  Widget _buildDataContent() {
    return Obx(() {
      if (_productChatsService.isLoading.value &&
          _productChatsService.messageCount == 0) {
        return _buildLoadingState();
      }

      if (_productChatsService.hasError.value &&
          _productChatsService.messageCount == 0) {
        return _buildErrorState();
      }

      final chatDataList = _productChatsService.filteredChats;

      if (chatDataList.isEmpty) {
        return _buildEmptyState();
      }

      return _buildDataList(chatDataList);
    });
  }

  Widget _buildDataList(List<ChatData> chatDataList) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _dataTableScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF0D9488),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFFFFFF),
                ),
                columnSpacing: 20,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    chatDataList
                        .map((chatData) => _buildDataRow(chatData))
                        .toList(),
              ),
            ),
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Obx(() {
      final totalPages = _productChatsService.totalPages.value;
      if (totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          children: [
            // Pagination info
            Text(
              _productChatsService.paginationInfo,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            // Pagination controls (scrollable to avoid overflow)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  IconButton(
                    onPressed:
                        _productChatsService.canGoPrevious &&
                                !_productChatsService.isLoading.value
                            ? () => _productChatsService.previousPage()
                            : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous page',
                  ),
                  const SizedBox(width: 8),

                  // Page numbers
                  ..._buildPageNumbers(),

                  const SizedBox(width: 8),
                  // Next button
                  IconButton(
                    onPressed:
                        _productChatsService.canGoNext &&
                                !_productChatsService.isLoading.value
                            ? () => _productChatsService.nextPage()
                            : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next page',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPageNumbers() {
    final currentPage = _productChatsService.currentPage.value;
    final visiblePages = _productChatsService.visiblePages;
    final isLoading = _productChatsService.isLoading.value;

    return visiblePages.map((page) {
      if (page == -1) {
        // Ellipsis
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey)),
        );
      }

      final isCurrentPage = page == currentPage;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                isLoading || isCurrentPage
                    ? null
                    : () => _productChatsService.goToPage(page),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isCurrentPage
                        ? const Color(0xFF0D9488)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isCurrentPage
                          ? const Color(0xFF0D9488)
                          : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child:
                    isLoading && isCurrentPage
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          page.toString(),
                          style: TextStyle(
                            color:
                                isCurrentPage ? Colors.white : Colors.grey[700],
                            fontWeight:
                                isCurrentPage
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading chats...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Obx(
      () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading chats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _productChatsService.errorMessage.value,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _productChatsService.refreshData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No chats found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation to see it here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatIsoDate(String? isoString) {
    if (isoString == null) return "N/A";

    try {
      final DateTime dateTime = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return "Invalid date";
    }
  }

  DataRow _buildDataRow(ChatData chatData) {
    final user = chatData.user ?? AuthService.instance.authCustomer?.user;
    final firstName = chatData.user?.firstName ?? '';
    final lastName = chatData.user?.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'Unknown User';
    final country = chatData.user?.address?.country ?? '';
    final city = chatData.user?.address?.city ?? '';
    final location = '$country/$city'.replaceAll('//', '/');
    final status = chatData.user?.status ?? 'inactive';

    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0D9488),
                radius: 16,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(location.isEmpty ? 'N/A' : location)),
        DataCell(Text(_formatIsoDate(chatData.createdAt))),
        DataCell(_buildStatusChip(status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _handleChatTap(chatData),
                icon: const Icon(Icons.chat, size: 18),
                tooltip: 'Start Chat',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleChatTap(ChatData chatData) {
    final userCurrent = AuthService.instance.authCustomer;
    if (userCurrent?.user == null) {
      showContactDialog(context, const LoginUi());
    } else {
      startChatWithProduct(
        chatData.productId.toString(),
        context,
        uid: chatData.id.toString(),
        productChats: chatData,
      );
    }
  }
}
