import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/orders_dashboard/widgets/orders_web_analytics.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/placed_orders_service.dart';

class PlacedOrdersScreen extends StatefulWidget {
  const PlacedOrdersScreen({super.key, this.userId, this.onAdCallback});

  final String? userId; // Add userId parameter for filtering
  final VoidCallback? onAdCallback;

  @override
  State<PlacedOrdersScreen> createState() => _PlacedOrdersScreenState();
}

class _PlacedOrdersScreenState extends State<PlacedOrdersScreen> {
  // Controllers and Services
  late final OrdersDashboardController _controller;
  late final PlacedOrderService _orderService;
  late final ScrollController _scrollController;

  // UI State
  String? _selectedOrderStatus;
  bool _isAppBarExpanded = true;

  // Constants for better performance
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
    colors: [Color(0xFFF97316), Color(0xFFF97316)],
  );

  static const LinearGradient _expandedStackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97316), Color(0xFFFACC15)],
  );

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadOrders();
  }

  void _initializeControllers() {
    _controller = Get.put(OrdersDashboardController());
    _orderService = Get.find<PlacedOrderService>();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  Future<void> _loadOrders() async {
    final String userId =
        (AuthService.instance.role ?? 'customer') != 'admin'
            ? AuthService.instance.authCustomer?.user?.id ?? widget.userId ?? ''
            : widget.userId ?? '';
    try {
      await _orderService.fetchOrders(refresh: true, userId: userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final shouldBeExpanded = _scrollController.offset < _scrollThreshold;
    if (_isAppBarExpanded != shouldBeExpanded) {
      setState(() => _isAppBarExpanded = shouldBeExpanded);
    }

    // Check if we need to load more data (pagination)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_orderService.hasMorePages.value && !_orderService.isLoading.value) {
      try {
        await _orderService.loadNextPage();
        setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load more orders: $e')),
          );
        }
      }
    }
  }

  Future<void> _refreshOrders() async {
    try {
      await _orderService.refreshOrders();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to refresh orders: $e')));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildContent());
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [_buildSliverAppBar(), _buildMainContent()],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
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
            usernumber: AuthService.instance.authCustomer?.user?.phone ?? '',
            userid:
                '${AuthService.instance.authCustomer?.user?.firstName ?? ''} ${AuthService.instance.authCustomer?.user?.lastName ?? ''}',
          ),
          const SizedBox(height: 10),
          _buildPaginationInfo(),
          const SizedBox(height: 10),
          _buildTableHeader(),
          const SizedBox(height: 10),
          _buildOrdersList(),
          _buildLoadMoreIndicator(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.userId != null ? 'Placed Orders' : 'All Orders',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPaginationInfo() {
    return Obx(() {
      final paginationInfo = _orderService.getPaginationInfo();
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${paginationInfo['currentPage']} of ${paginationInfo['totalPages']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              'Total: ${paginationInfo['totalOrders']} orders',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _refreshOrders,
                  tooltip: 'Refresh',
                ),
                if (paginationInfo['currentPage'] > 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () async {
                      await _orderService.loadPage(
                        paginationInfo['currentPage'] - 1,
                      );
                      setState(() {});
                    },
                    tooltip: 'Previous Page',
                  ),
                if (paginationInfo['hasMorePages'])
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    onPressed: () async {
                      _orderService.loadNextPage();
                      setState(() {});
                    },
                    tooltip: 'Next Page',
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
            _HeaderCell(text: 'Buyer'),
            _HeaderCell(text: 'Shop'),
            _HeaderCell(text: 'Order Total'),
            _HeaderCell(text: 'Bonus\nAmount'),
            _HeaderCell(text: 'Payment\nMethod'),
            _HeaderCell(text: 'Payment\nStatus'),
            _HeaderCell(text: 'Order\nDate'),
            _HeaderCell(text: 'Order\nStatus'),
            _HeaderCell(text: 'Action'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = _getFilteredOrders();

    if (orders.isEmpty && !_orderService.isLoading.value) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children:
            orders
                .map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildOrderItem(order),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (!_orderService.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F8C3B)),
            ),
            SizedBox(width: 16),
            Text(
              'Loading more orders...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      );
    });
  }

  List<Order> _getFilteredOrders() {
    final orders = _orderService.orders;

    // Filter by status if selected
    if (_selectedOrderStatus != null) {
      orders.value =
          orders
              .where((order) => order.status.toString() == _selectedOrderStatus)
              .toList();
    }

    return orders;
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
                : 'No orders availables',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshOrders,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      decoration: _buildCardDecoration(),
      height: 180,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildOrderDetails(order), _buildOrderItems(order)],
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
        _controller.fetchOrderItems(order.id.toString());
        _controller.setSelectedOrder(order);
        setState(() {});
        Get.toNamed(Routes.ORDERS_DASHBOARD, preventDuplicates: false);
        break;
      case 'delete':
        await _controller.deleteOrder(order.id ?? '', context);
        await _orderService.refreshOrders();
        setState(() {});
        break;
      case 'add_to_cart':
        await _controller.converttoAddtoCart(
          order.id ?? '',
          context,
        ); // Define logic as needed
        await _orderService.refreshOrders();
        setState(() {});
        break;
      case 'cancel':
        await _controller.updateOrderStatus(
          order.id ?? '',
          context,
        ); // Implement cancel flow
        await _orderService.refreshOrders();
        setState(() {});
        break;
    }
  }

  Widget _buildOrderItems(Order order) {
    return FutureBuilder(
      future: _controller.fetchOrderItemsFuture(order.id.toString()),
      builder: (context, snapshot) {
        // if (snapshot.connectionState != ConnectionState.done) {
        //   return const SizedBox(
        //     height: 40,
        //     child: Center(child: CircularProgressIndicator()),
        //   );
        // }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('No items found'),
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
                Text(
                  '+${snapshot.data!.length - 3} more',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItemImage(dynamic item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child:
          item.imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                ),
              )
              : const Icon(Icons.image),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
