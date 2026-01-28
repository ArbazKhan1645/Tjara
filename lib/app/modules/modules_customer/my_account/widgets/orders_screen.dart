import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/orders_web_analytics.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.userId, this.onAdCallback});

  final String? userId;
  final VoidCallback? onAdCallback;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // Controllers and Services
  late final OrdersDashboardController _controller;
  late final OrderService _orderService;
  late final ScrollController _scrollController;

  // UI State
  String? _selectedOrderStatus;
  bool _isAppBarExpanded = true;
  bool _hasInitialized = false;

  // Real-time updates
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;
  static const Duration _refreshInterval = Duration(seconds: 30);

  // Performance optimization
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _scrollThreshold = 30.0;
  static const double _expandedHeight = 80.0;

  // Pre-defined gradients to avoid recalculation
  static const LinearGradient _expandedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97316), Color(0xFFF97316)],
  );

  static const LinearGradient _collapsedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color.fromARGB(255, 13, 17, 14), Colors.red],
  );

  static const LinearGradient _expandedStackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97316), Color(0xFFFACC15)],
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _loadOrders();
    _startPeriodicRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh orders when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshOrdersIfNeeded();
    }
  }

  void _initializeControllers() {
    _controller = Get.put(OrdersDashboardController());
    _orderService = Get.find<OrderService>();
    _scrollController = ScrollController();
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted && !_orderService.isLoading.value) {
        _refreshOrdersInBackground();
      }
    });
  }

  Future<void> _refreshOrdersIfNeeded() async {
    final now = DateTime.now();
    if (_lastRefreshTime == null ||
        now.difference(_lastRefreshTime!).inSeconds > 30) {
      await _refreshOrdersInBackground();
    }
  }

  Future<void> _refreshOrdersInBackground() async {
    try {
      _lastRefreshTime = DateTime.now();
      final String userId = _getUserId();

      if (widget.userId != null) {
        await _orderService.fetchPlacedOrders(
          userId: userId,
          refresh: true,
          page: 1,
        );
      } else {
        await _orderService.fetchOrders(refresh: true, userId: userId, page: 1);
      }
    } catch (e) {
      // Silent background refresh - don't show error to user
      print('Background refresh failed: $e');
    }
  }

  Future<void> _loadOrders() async {
    if (_hasInitialized) return;

    try {
      _hasInitialized = true;

      // Reset pagination state
      _orderService.resetPagination();

      final String userId = _getUserId();

      if (widget.userId != null) {
        await _orderService.fetchPlacedOrders(
          userId: userId,
          refresh: true,
          page: 1,
        );
      } else {
        await _orderService.fetchOrders(refresh: true, userId: userId, page: 1);
      }

      _lastRefreshTime = DateTime.now();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load orders: $e');
      }
    }
  }

  String _getUserId() {
    return (AuthService.instance.role ?? 'customer') != 'admin'
        ? AuthService.instance.authCustomer?.user?.id ?? widget.userId ?? ''
        : widget.userId ?? '';
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Handle app bar expansion/collapse
    final shouldBeExpanded = _scrollController.offset < _scrollThreshold;
    if (_isAppBarExpanded != shouldBeExpanded) {
      setState(() => _isAppBarExpanded = shouldBeExpanded);
    }
  }

  Future<void> _refreshOrders() async {
    try {
      final String userId = _getUserId();

      // Reset pagination state
      _orderService.resetPagination();

      if (widget.userId != null) {
        await _orderService.fetchPlacedOrders(
          userId: userId,
          refresh: true,
          page: 1,
        );
      } else {
        await _orderService.fetchOrders(refresh: true, userId: userId, page: 1);
      }

      _lastRefreshTime = DateTime.now();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to refresh orders: $e');
      }
    }
  }

  Future<void> _loadSpecificPage(int page) async {
    // Allow page 1 even if totalPages is 0 (initial load)
    if (page < 1 ||
        (page > _orderService.totalPages.value &&
            _orderService.totalPages.value > 0)) {
      print(
        'Invalid page request: page=$page, totalPages=${_orderService.totalPages.value}',
      );
      return;
    }

    try {
      final String userId = _getUserId();

      print('Loading specific page: $page for user: $userId');
      print(
        'Current state before request: currentPage=${_orderService.currentPage.value}, totalPages=${_orderService.totalPages.value}',
      );

      if (widget.userId != null) {
        await _orderService.fetchPlacedOrders(
          userId: userId,
          page: page,
          refresh: true, // Force refresh to get new data for the page
        );
      } else {
        await _orderService.fetchOrders(
          userId: userId,
          page: page,
          refresh: true, // Force refresh to get new data for the page
        );
      }

      print(
        'Successfully loaded page $page with ${_orderService.orders.length} orders',
      );
      print(
        'State after request: currentPage=${_orderService.currentPage.value}, totalPages=${_orderService.totalPages.value}',
      );
    } catch (e) {
      print('Error loading page $page: $e');
      if (mounted) {
        _showErrorSnackbar('Failed to load page $page: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(body: _buildContent());
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [_buildSliverAppBar(), _buildMainContent()],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      leading: IconButton(
        onPressed: () async {
          // Try to pop the current route safely
          final bool didPop = await Navigator.of(context).maybePop();
          if (!didPop) {
            // Fallback to GetX pop if Navigator couldn't pop
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back();
            }
          }
        },
        icon: const Icon(Icons.arrow_back_ios_new_outlined),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: _expandedHeight,
      backgroundColor: const Color(0xFFF97316),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedContainer(
          duration: _animationDuration,
          decoration: BoxDecoration(
            gradient:
                _isAppBarExpanded ? _expandedGradient : _collapsedGradient,
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      title: Text(
        widget.userId != null ? 'User Orders' : 'All Orders Dashboard',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [_buildBackgroundGradient(), _buildOrdersContent()],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return AnimatedContainer(
      duration: _animationDuration,
      decoration: BoxDecoration(
        gradient: _isAppBarExpanded ? _expandedStackGradient : null,
      ),
      height: MediaQuery.of(context).size.height / 2.7,
    );
  }

  Widget _buildOrdersContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          OrdersWebAnalyticsPage(
            usernumber: '',
            userid:
                (AuthService.instance.role ?? 'customer') != 'admin'
                    ? '${AuthService.instance.authCustomer?.user?.firstName ?? ''} ${AuthService.instance.authCustomer?.user?.lastName ?? ''}'
                    : '',
          ),
          const SizedBox(height: 10),
          _buildPaginationInfo(),
          const SizedBox(height: 20),
          _buildOrdersList(),
          // Add spacing at bottom to prevent table from going under bottom bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.userId != null ? 'Placed Orders' : 'All Orders',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Real-time indicator
        Obx(() {
          if (_orderService.isLoading.value) {
            return const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
          return const Icon(Icons.sync, color: Colors.white70, size: 16);
        }),
      ],
    );
  }

  Widget _buildPaginationInfo() {
    return Obx(() {
      final paginationInfo = _orderService.getPaginationInfo();
      final bool isLoading = _orderService.isLoading.value;

      print(
        'Building pagination info: paginationInfo=$paginationInfo, isLoading=$isLoading',
      );
      print(
        'Service state: currentPage=${_orderService.currentPage.value}, totalPages=${_orderService.totalPages.value}, totalOrders=${_orderService.totalOrders.value}',
      );
      print(
        'hasMorePages=${_orderService.hasMorePages.value}, orders.length=${_orderService.orders.length}',
      );

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Page ${paginationInfo['currentPage'] ?? 0} of ${paginationInfo['totalPages'] ?? 0}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total: ${paginationInfo['totalOrders'] ?? 0} orders',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Showing: ${paginationInfo['ordersCount'] ?? 0}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 22,
                    color: Colors.green,
                  ),
                  onPressed: isLoading ? null : _refreshOrders,
                  tooltip: 'Refresh',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.first_page,
                    size: 22,
                    color: Colors.blue,
                  ),
                  onPressed:
                      (isLoading || (paginationInfo['currentPage'] ?? 0) <= 1)
                          ? null
                          : () => _loadSpecificPage(1),
                  tooltip: 'First Page',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.blue,
                  ),
                  onPressed:
                      (isLoading || (paginationInfo['currentPage'] ?? 0) <= 1)
                          ? null
                          : () => _loadSpecificPage(
                            (paginationInfo['currentPage'] ?? 1) - 1,
                          ),
                  tooltip: 'Previous Page',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${paginationInfo['currentPage'] ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.blue,
                  ),
                  onPressed:
                      (isLoading || !(paginationInfo['hasMorePages'] ?? false))
                          ? () {
                            print(
                              'Next button disabled - isLoading=$isLoading, hasMorePages=${paginationInfo['hasMorePages']}',
                            );
                          }
                          : () {
                            final currentPage =
                                paginationInfo['currentPage'] ?? 1;
                            final nextPage = currentPage + 1;
                            print(
                              'Next button pressed: loading page $nextPage',
                            );
                            _loadSpecificPage(nextPage);
                          },
                  tooltip: 'Next Page',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.last_page,
                    size: 22,
                    color: Colors.blue,
                  ),
                  onPressed:
                      (isLoading || !(paginationInfo['hasMorePages'] ?? false))
                          ? null
                          : () => _loadSpecificPage(
                            paginationInfo['totalPages'] ?? 1,
                          ),
                  tooltip: 'Last Page',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _buildCardDecoration(),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _HeaderCell(text: '# Order ID'),
            _HeaderCell(text: 'Shop'),
            _HeaderCell(text: 'Order Total'),
            _HeaderCell(text: 'Order\nStatus'),
            _HeaderCell(text: 'Action'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      final orders = _getFilteredOrders();
      final bool isLoading = _orderService.isLoading.value;

      print(
        'Building orders list: orders=${orders.length}, isLoading=$isLoading, hasInitialized=$_hasInitialized',
      );

      // Handle loading state on first load
      if (isLoading && orders.isEmpty && !_hasInitialized) {
        print('Showing loading state');
        return _buildLoadingState();
      }

      // Handle empty state with better error checking
      if (orders.isEmpty && !isLoading) {
        print('Showing empty state');
        return _buildEmptyState();
      }

      print('Building orders table with ${orders.length} orders');
      // Build orders list
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(),
            // Use optimized list building
            ...orders.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              print('Building order item $index: ${order.id}');
              return Padding(
                key: ValueKey('order_${order.id}'), // Add key for performance
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildOrderItem(order, index),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: _buildCardDecoration(),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F8C3B)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Order> _getFilteredOrders() {
    try {
      var orders = _orderService.orders.value;

      print(
        'Getting filtered orders: total orders = ${orders.length}, currentPage = ${_orderService.currentPage.value}',
      );

      // Safely handle null or empty orders list
      if (orders.isEmpty) {
        print('No orders found in service');
        return <Order>[];
      }

      // Show first few order IDs for debugging
      if (orders.isNotEmpty) {
        final firstOrderIds = orders.take(3).map((o) => o.id).join(', ');
        print('First order IDs: $firstOrderIds');
      }

      // Filter by status if selected
      if (_selectedOrderStatus != null && _selectedOrderStatus!.isNotEmpty) {
        final beforeFilter = orders.length;
        orders =
            orders
                .where(
                  (order) => order.status?.toString() == _selectedOrderStatus,
                )
                .toList();
        print(
          'Filtered by status $_selectedOrderStatus: $beforeFilter -> ${orders.length} orders',
        );
      }

      return orders;
    } catch (e) {
      print('Error filtering orders: $e');
      return <Order>[];
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            widget.userId != null
                ? 'No orders found for this user'
                : 'No orders available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when they are placed',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _orderService.isLoading.value ? null : _refreshOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F8C3B),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Order order, int index) {
    return Container(
      decoration: _buildCardDecoration(),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetails(order),
            const Divider(height: 1),
            _buildOrderItems(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          _OrderColumn(
            label: 'Order ID',
            value: order.meta?['order_id']?.toString() ?? 'N/A',
          ),
          const SizedBox(width: 30),
          _OrderColumn(
            label: 'Shop Seller',
            value: order.shop?.shop?.name ?? 'N/A',
          ),
          const SizedBox(width: 30),
          _OrderColumn(
            label: 'Order Total',
            value: '\$${order.orderTotal?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(width: 30),
          _OrderColumn(
            label: 'Order Status',
            value: order.status?.toString() ?? 'Unknown',
          ),
          const SizedBox(width: 30),
          _buildActionButton(order),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildActionButton(Order order) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 24),
      onSelected: (value) => _handleOrderAction(value, order),
      itemBuilder: (context) {
        final List<PopupMenuEntry<String>> items = [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Edit Order'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Delete Order'),
              ],
            ),
          ),
        ];

        // Add more options if order is pending
        if (order.status?.toLowerCase() == 'pending') {
          items.addAll([
            const PopupMenuItem(
              value: 'add_to_cart',
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Add to Cart'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text('Cancel Order'),
                ],
              ),
            ),
          ]);
        }

        return items;
      },
    );
  }

  void _handleOrderAction(String action, Order order) async {
    switch (action) {
      case 'edit':
        await _controller.fetchOrderItems(order.id.toString());
        _controller.setSelectedOrder(order);
        if (mounted) {
          Get.toNamed(Routes.ORDERS_DASHBOARD, preventDuplicates: false);
        }
        break;
      case 'delete':
        // Show confirmation dialog
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: Text(
                  'Are you sure you want to delete order ${order.meta?['order_id'] ?? 'N/A'}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );

        if (confirmed == true) {
          await _controller.deleteOrder(order.id ?? '', context);
          await _refreshOrders();
        }
        break;
      case 'add_to_cart':
        await _controller.converttoAddtoCart(order.id ?? '', context);
        await _refreshOrders();
        break;
      case 'cancel':
        await _controller.updateOrderStatus(order.id ?? '', context);
        await _refreshOrders();
        break;
    }
  }

  Widget _buildOrderItems(Order order) {
    return FutureBuilder<List<dynamic>>(
      future: _controller.fetchOrderItemsFuture(order.id.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading items...'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('No items found', style: TextStyle(color: Colors.grey)),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Text(
                'Order Items: ',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...snapshot.data!
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildOrderItemImage(item),
                    ),
                  ),
              if (snapshot.data!.length > 3)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${snapshot.data!.length - 3} more',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItemImage(dynamic item) {
    return GestureDetector(
      onTap: () {
        print(item);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child:
            item.imageUrl != null && item.imageUrl.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 20),
                  ),
                )
                : const Icon(Icons.image, size: 20),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// Helper Widgets
class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _OrderColumn extends StatelessWidget {
  const _OrderColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
