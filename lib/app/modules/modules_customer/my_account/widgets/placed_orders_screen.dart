// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/orders_web_analytics.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/orders/placed_orders_service.dart';

class PlacedOrdersScreen extends StatefulWidget {
  const PlacedOrdersScreen({super.key, this.userId, this.onAdCallback});

  final String? userId;
  final VoidCallback? onAdCallback;

  @override
  State<PlacedOrdersScreen> createState() => _PlacedOrdersScreenState();
}

class _PlacedOrdersScreenState extends State<PlacedOrdersScreen> {
  // Controllers and Services
  late final OrdersDashboardController _controller;
  late final PlacedOrderService _orderService;
  late final ScrollController _scrollController;

  // Filter controllers
  final TextEditingController _orderIdSearchCtrl = TextEditingController();
  final TextEditingController _buyerNameSearchCtrl = TextEditingController();
  final TextEditingController _phoneSearchCtrl = TextEditingController();
  final TextEditingController _shopSearchCtrl = TextEditingController();

  // Filter state
  String? _selectedStatus;
  String? _selectedPaymentMethod;
  String? _selectedPaymentStatus;
  String? _selectedShopId;
  String? _selectedShopName;
  bool _showTestingOrders = false;
  bool _showDeletedOrders = false;
  bool _filtersExpanded = false;

  // Shop search
  List<Map<String, dynamic>> _shopResults = [];
  bool _isSearchingShops = false;
  Timer? _shopSearchDebounce;

  // Order items cache (fixes FutureBuilder rebuild issue)
  final Map<String, Future<List<dynamic>>> _orderItemsFutures = {};

  // UI State
  bool _isAppBarExpanded = true;

  // Performance
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _scrollThreshold = 30.0;
  static const double _expandedHeight = 80.0;

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

  // Filter options
  static const List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'on-hold', 'label': 'On Hold'},
    {'value': 'awaiting-payment', 'label': 'Awaiting Payment'},
    {'value': 'cancelled', 'label': 'Cancelled'},
    {'value': 'refunded', 'label': 'Refunded'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'awaiting-fulfillment', 'label': 'Awaiting Fulfillment'},
    {'value': 'awaiting-pickup', 'label': 'Awaiting Pickup'},
    {'value': 'shipping', 'label': 'Shipping'},
    {'value': 'delivered', 'label': 'Delivered'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'returned', 'label': 'Returned'},
    {'value': 'reshipping', 'label': 'Reshipping'},
    {'value': 'reshipped', 'label': 'Reshipped'},
    {'value': 'failed', 'label': 'Failed'},
  ];

  static const List<Map<String, String>> _paymentMethodOptions = [
    {'value': 'cash-on-delivery', 'label': 'Cash on Delivery'},
    {'value': 'stripe', 'label': 'Stripe'},
    {'value': 'paypal', 'label': 'PayPal'},
  ];

  static const List<Map<String, String>> _paymentStatusOptions = [
    {'value': 'paid', 'label': 'Paid'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'failed', 'label': 'Failed'},
  ];

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

  String _getUserId() {
    return (AuthService.instance.role ?? 'customer') != 'admin'
        ? AuthService.instance.authCustomer?.user?.id ?? widget.userId ?? ''
        : widget.userId ?? '';
  }

  // ─── BUILD FILTER PARAMS FOR API ───
  Map<String, String> _buildFilterParams() {
    final params = <String, String>{
      'dateFilter': 'all',
      'with': 'thumbnail,shop,order_items',
      'include_batch_info': 'true',
      'filterJoin': 'AND',
      'orderBy': 'created_at',
      'order': 'desc',
    };

    // Search params
    if (_orderIdSearchCtrl.text.trim().isNotEmpty) {
      params['search'] = _orderIdSearchCtrl.text.trim();
    }
    if (_buyerNameSearchCtrl.text.trim().isNotEmpty) {
      params['searchByBuyerName'] = _buyerNameSearchCtrl.text.trim();
    }
    if (_phoneSearchCtrl.text.trim().isNotEmpty) {
      params['searchByPhoneNumber'] = _phoneSearchCtrl.text.trim();
    }

    // Column filters
    int colIdx = 0;

    // Buyer ID filter (always for placed orders)
    final current = AuthService.instance.authCustomer;
    if (current?.user?.id != null) {
      params['filterByColumns[columns][$colIdx][column]'] = 'buyer_id';
      params['filterByColumns[columns][$colIdx][value]'] = current!.user!.id!;
      params['filterByColumns[columns][$colIdx][operator]'] = '=';
      colIdx++;
    }

    if (_selectedStatus != null) {
      params['filterByColumns[columns][$colIdx][column]'] = 'status';
      params['filterByColumns[columns][$colIdx][value]'] = _selectedStatus!;
      params['filterByColumns[columns][$colIdx][operator]'] = '=';
      colIdx++;
    }

    if (_selectedShopId != null) {
      params['filterByColumns[columns][$colIdx][column]'] = 'shop_id';
      params['filterByColumns[columns][$colIdx][value]'] = _selectedShopId!;
      params['filterByColumns[columns][$colIdx][operator]'] = '=';
      colIdx++;
    }

    if (colIdx > 0) {
      params['filterByColumns[filterJoin]'] = 'AND';
    }

    // Meta field filters
    int metaIdx = 0;
    if (_showTestingOrders) {
      params['filterByMetaFields[fields][$metaIdx][key]'] = 'is_testing';
      params['filterByMetaFields[fields][$metaIdx][value]'] = '1';
      params['filterByMetaFields[fields][$metaIdx][operator]'] = '=';
      metaIdx++;
    }
    if (_showDeletedOrders) {
      params['filterByMetaFields[fields][$metaIdx][key]'] = 'is_soft_deleted';
      params['filterByMetaFields[fields][$metaIdx][value]'] = '1';
      params['filterByMetaFields[fields][$metaIdx][operator]'] = '=';
      metaIdx++;
    }
    if (metaIdx > 0) {
      params['filterByMetaFields[filterJoin]'] = 'AND';
    }

    // Transaction filters
    int txnIdx = 0;
    if (_selectedPaymentMethod != null) {
      params['filterByOrderTransactionColumns[columns][$txnIdx][column]'] =
          'payment_method';
      params['filterByOrderTransactionColumns[columns][$txnIdx][value]'] =
          _selectedPaymentMethod!;
      params['filterByOrderTransactionColumns[columns][$txnIdx][operator]'] =
          '=';
      txnIdx++;
    }
    if (_selectedPaymentStatus != null) {
      params['filterByOrderTransactionColumns[columns][$txnIdx][column]'] =
          'payment_status';
      params['filterByOrderTransactionColumns[columns][$txnIdx][value]'] =
          _selectedPaymentStatus!;
      params['filterByOrderTransactionColumns[columns][$txnIdx][operator]'] =
          '=';
      txnIdx++;
    }
    if (txnIdx > 0) {
      params['filterByOrderTransactionColumns[filterJoin]'] = 'AND';
    }

    return params;
  }

  Future<void> _fetchWithFilters({int page = 1, bool refresh = false}) async {
    final params = _buildFilterParams();
    _orderItemsFutures.clear();
    await _orderService.fetchOrders(
      page: page,
      refresh: refresh,
      userId: _getUserId(),
      queryOverrides: params,
    );
  }

  Future<void> _loadOrders() async {
    try {
      _orderService.resetPagination();
      await _fetchWithFilters(page: 1, refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
      }
    }
  }

  void _applyFilters() {
    _orderService.resetPagination();
    _orderItemsFutures.clear();
    _fetchWithFilters(page: 1, refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _orderIdSearchCtrl.clear();
      _buyerNameSearchCtrl.clear();
      _phoneSearchCtrl.clear();
      _shopSearchCtrl.clear();
      _selectedStatus = null;
      _selectedPaymentMethod = null;
      _selectedPaymentStatus = null;
      _selectedShopId = null;
      _selectedShopName = null;
      _showTestingOrders = false;
      _showDeletedOrders = false;
      _shopResults.clear();
    });
    _applyFilters();
  }

  bool _hasActiveFilters() {
    return _orderIdSearchCtrl.text.isNotEmpty ||
        _buyerNameSearchCtrl.text.isNotEmpty ||
        _phoneSearchCtrl.text.isNotEmpty ||
        _selectedStatus != null ||
        _selectedPaymentMethod != null ||
        _selectedPaymentStatus != null ||
        _selectedShopId != null ||
        _showTestingOrders ||
        _showDeletedOrders;
  }

  // ─── SHOP SEARCH API ───
  Future<void> _searchShops(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _shopResults.clear();
        _isSearchingShops = false;
      });
      return;
    }

    setState(() => _isSearchingShops = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/shops?search=${Uri.encodeComponent(query)}',
        ),
        headers: {
          'X-Request-From': 'Dashboard',
          'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final shops =
            (json['shops']?['data'] as List?)
                ?.map(
                  (s) => {
                    'id': s['id']?.toString() ?? '',
                    'name': s['name']?.toString() ?? '',
                  },
                )
                .toList() ??
            [];
        if (mounted) {
          setState(() {
            _shopResults = shops;
            _isSearchingShops = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isSearchingShops = false);
    }
  }

  void _onShopSearchChanged(String value) {
    _shopSearchDebounce?.cancel();
    _shopSearchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchShops(value);
    });
  }

  // ─── CACHED ORDER ITEMS ───
  Future<List<dynamic>> _getCachedOrderItems(String orderId) {
    return _orderItemsFutures.putIfAbsent(
      orderId,
      () => _controller.fetchOrderItemsFuture(orderId),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final shouldBeExpanded = _scrollController.offset < _scrollThreshold;
    if (_isAppBarExpanded != shouldBeExpanded) {
      setState(() => _isAppBarExpanded = shouldBeExpanded);
    }

    // Pagination on scroll
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_orderService.hasMorePages.value && !_orderService.isLoading.value) {
      try {
        await _fetchWithFilters(page: _orderService.currentPage.value + 1);
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
      _orderService.resetPagination();
      _orderItemsFutures.clear();
      await _fetchWithFilters(page: 1, refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to refresh orders: $e')));
      }
    }
  }

  Future<void> _loadSpecificPage(int page) async {
    if (page < 1 ||
        (page > _orderService.totalPages.value &&
            _orderService.totalPages.value > 0)) {
      return;
    }
    try {
      _orderItemsFutures.clear();
      await _fetchWithFilters(page: page, refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load page $page: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _shopSearchDebounce?.cancel();
    _scrollController.dispose();
    _orderIdSearchCtrl.dispose();
    _buyerNameSearchCtrl.dispose();
    _phoneSearchCtrl.dispose();
    _shopSearchCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildContent());
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshOrders,
      color: Colors.teal,
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
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: _expandedHeight,
      backgroundColor: Colors.teal,
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
        widget.userId != null ? 'User Orders' : 'Placed Orders',
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.userId != null ? 'Placed Orders' : 'My Orders',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          OrdersWebAnalyticsPage(
            usernumber: AuthService.instance.authCustomer?.user?.phone ?? '',
            userid:
                '${AuthService.instance.authCustomer?.user?.firstName ?? ''} ${AuthService.instance.authCustomer?.user?.lastName ?? ''}',
          ),
          const SizedBox(height: 12),
          _buildFiltersSection(),
          const SizedBox(height: 12),
          _buildPaginationInfo(),
          const SizedBox(height: 12),
          _buildOrdersList(),
          _buildLoadMoreIndicator(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // FILTERS SECTION
  // ═══════════════════════════════════════════

  Widget _buildFiltersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Colors.teal.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  if (_hasActiveFilters()) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  AnimatedRotation(
                    turns: _filtersExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState:
                _filtersExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildFilterContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildFilterField(
                  _orderIdSearchCtrl,
                  'Search Order ID',
                  Icons.tag,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFilterField(
                  _buyerNameSearchCtrl,
                  'Buyer Name',
                  Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildFilterField(
                  _phoneSearchCtrl,
                  'Phone Number',
                  Icons.phone_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildShopSearchField()),
            ],
          ),
          if (_shopResults.isNotEmpty || _isSearchingShops)
            _buildShopSearchResults(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'Order Status',
                  _selectedStatus,
                  _statusOptions,
                  (v) => setState(() => _selectedStatus = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                  'Payment Method',
                  _selectedPaymentMethod,
                  _paymentMethodOptions,
                  (v) => setState(() => _selectedPaymentMethod = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'Payment Status',
                  _selectedPaymentStatus,
                  _paymentStatusOptions,
                  (v) => setState(() => _selectedPaymentStatus = v),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildToggle(
                  'Testing Orders',
                  _showTestingOrders,
                  (v) => setState(() => _showTestingOrders = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildToggle(
                  'Deleted Orders',
                  _showDeletedOrders,
                  (v) => setState(() => _showDeletedOrders = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildShopSearchField() {
    return TextField(
      controller: _shopSearchCtrl,
      onChanged: _onShopSearchChanged,
      decoration: InputDecoration(
        hintText: _selectedShopName ?? 'Search Shop',
        hintStyle: TextStyle(
          fontSize: 13,
          color:
              _selectedShopName != null
                  ? Colors.teal.shade700
                  : Colors.grey.shade500,
          fontWeight:
              _selectedShopName != null ? FontWeight.w600 : FontWeight.normal,
        ),
        prefixIcon: Icon(
          Icons.store_outlined,
          size: 18,
          color: Colors.grey.shade500,
        ),
        suffixIcon:
            _selectedShopId != null
                ? IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedShopId = null;
                      _selectedShopName = null;
                      _shopSearchCtrl.clear();
                      _shopResults.clear();
                    });
                  },
                )
                : (_isSearchingShops
                    ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.teal,
                        ),
                      ),
                    )
                    : null),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _selectedShopId != null ? Colors.teal : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildShopSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child:
          _isSearchingShops
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal,
                    ),
                  ),
                ),
              )
              : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _shopResults.length,
                separatorBuilder:
                    (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final shop = _shopResults[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      shop['name'] ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                    leading: Icon(
                      Icons.store,
                      size: 18,
                      color: Colors.teal.shade400,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedShopId = shop['id'];
                        _selectedShopName = shop['name'];
                        _shopSearchCtrl.clear();
                        _shopResults.clear();
                      });
                    },
                  );
                },
              ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: value != null ? Colors.teal : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.grey.shade500,
          ),
          style: TextStyle(
            fontSize: 13,
            color: Colors.teal.shade700,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            ...options.map(
              (opt) => DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(
                  opt['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: value ? Colors.teal : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: value ? Colors.teal.shade50 : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value ? Colors.teal.shade700 : Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(
            height: 28,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.teal,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════

  Widget _buildPaginationInfo() {
    return Obx(() {
      final paginationInfo = _orderService.getPaginationInfo();
      final bool isLoading = _orderService.isLoading.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
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
                _paginationBtn(
                  Icons.refresh,
                  'Refresh',
                  isLoading ? null : _refreshOrders,
                ),
                const SizedBox(width: 4),
                _paginationBtn(
                  Icons.first_page,
                  'First',
                  (isLoading || (paginationInfo['currentPage'] ?? 0) <= 1)
                      ? null
                      : () => _loadSpecificPage(1),
                ),
                _paginationBtn(
                  Icons.chevron_left,
                  'Prev',
                  (isLoading || (paginationInfo['currentPage'] ?? 0) <= 1)
                      ? null
                      : () => _loadSpecificPage(
                        (paginationInfo['currentPage'] ?? 1) - 1,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${paginationInfo['currentPage'] ?? 0}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                _paginationBtn(
                  Icons.chevron_right,
                  'Next',
                  (isLoading || !(paginationInfo['hasMorePages'] ?? false))
                      ? null
                      : () => _loadSpecificPage(
                        (paginationInfo['currentPage'] ?? 1) + 1,
                      ),
                ),
                _paginationBtn(
                  Icons.last_page,
                  'Last',
                  (isLoading || !(paginationInfo['hasMorePages'] ?? false))
                      ? null
                      : () =>
                          _loadSpecificPage(paginationInfo['totalPages'] ?? 1),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _paginationBtn(
    IconData icon,
    String tooltip,
    VoidCallback? onPressed,
  ) {
    return IconButton(
      icon: Icon(
        icon,
        size: 22,
        color: onPressed != null ? Colors.teal : Colors.grey.shade400,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 20,
    );
  }

  // ═══════════════════════════════════════════
  // ORDERS LIST
  // ═══════════════════════════════════════════

  Widget _buildOrdersList() {
    return Obx(() {
      final orders = _orderService.orders;
      final bool isLoading = _orderService.isLoading.value;

      if (isLoading && orders.isEmpty) {
        return _buildShimmerLoading();
      }

      if (orders.isEmpty && !isLoading) {
        return _buildEmptyState();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            key: ValueKey('order_${orders[index].id}'),
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCard(orders[index]),
          );
        },
      );
    });
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (!_orderService.isLoading.value || _orderService.orders.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.teal.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.userId != null
                ? 'No orders found for this user'
                : 'No Orders Found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters()
                ? 'Try adjusting your filters'
                : 'Your orders will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _hasActiveFilters() ? _clearFilters : _refreshOrders,
            icon: Icon(
              _hasActiveFilters() ? Icons.filter_list_off : Icons.refresh,
              size: 18,
            ),
            label: Text(_hasActiveFilters() ? 'Clear Filters' : 'Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ORDER CARD
  // ═══════════════════════════════════════════

  Widget _buildOrderCard(Order order) {
    final orderId = order.meta?['order_id']?.toString() ?? 'N/A';
    final buyerName =
        '${order.buyer?.user?.firstName ?? ''} ${order.buyer?.user?.lastName ?? ''}'
            .trim();
    final buyerPhone = order.buyer?.user?.phone ?? '';
    final shopName = order.shop?.shop?.name ?? 'N/A';
    final total = order.orderTotal?.toStringAsFixed(2) ?? '0.00';
    final status = order.status ?? 'unknown';
    final paymentMethod = order.transaction?.paymentMethod ?? '';
    final paymentStatus = order.transaction?.paymentStatus ?? '';
    final createdAt = order.createdAt;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: Colors.teal.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '#$orderId',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal.shade700,
                  ),
                ),
                if (createdAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
                const Spacer(),
                _buildStatusChip(status),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person_outline,
                        'Buyer',
                        buyerName.isEmpty ? 'N/A' : buyerName,
                      ),
                    ),
                    if (buyerPhone.isNotEmpty)
                      Expanded(
                        child: _buildInfoItem(
                          Icons.phone_outlined,
                          'Phone',
                          buyerPhone,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.store_outlined,
                        'Shop',
                        shopName,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.attach_money,
                        'Total',
                        '\$$total',
                      ),
                    ),
                  ],
                ),
                if (paymentMethod.isNotEmpty || paymentStatus.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (paymentMethod.isNotEmpty)
                        Expanded(
                          child: _buildInfoItem(
                            Icons.credit_card_outlined,
                            'Payment',
                            _formatPaymentMethod(paymentMethod),
                          ),
                        ),
                      if (paymentStatus.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildPaymentStatusChip(paymentStatus),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _buildOrderItemsRow(order),
              ],
            ),
          ),
          // Footer
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await _controller.fetchOrderItems(order.id.toString());
                      _controller.setSelectedOrder(order);
                      if (mounted) {
                        Get.toNamed(
                          Routes.ORDERS_DASHBOARD,
                          preventDuplicates: false,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.teal.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'View / Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (value) => _handleOrderAction(value, order),
                    offset: const Offset(0, -120),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'More',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (context) {
                      final List<PopupMenuEntry<String>> items = [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Delete Order'),
                            ],
                          ),
                        ),
                      ];
                      if (order.status?.toLowerCase() == 'pending') {
                        items.addAll([
                          const PopupMenuItem(
                            value: 'add_to_cart',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text('Add to Cart'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text('Cancel Order'),
                              ],
                            ),
                          ),
                        ]);
                      }
                      return items;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config['dot'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _capitalizeStatus(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config['text'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeStatus(String status) {
    return status
        .replaceAll('-', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return {
          'bg': Colors.green.shade50,
          'text': Colors.green.shade700,
          'dot': Colors.green.shade500,
        };
      case 'pending':
      case 'awaiting-payment':
        return {
          'bg': Colors.orange.shade50,
          'text': Colors.orange.shade700,
          'dot': Colors.orange.shade500,
        };
      case 'processing':
      case 'awaiting-fulfillment':
      case 'awaiting-pickup':
        return {
          'bg': Colors.blue.shade50,
          'text': Colors.blue.shade700,
          'dot': Colors.blue.shade500,
        };
      case 'shipping':
      case 'reshipping':
      case 'reshipped':
        return {
          'bg': Colors.indigo.shade50,
          'text': Colors.indigo.shade700,
          'dot': Colors.indigo.shade500,
        };
      case 'cancelled':
      case 'failed':
        return {
          'bg': Colors.red.shade50,
          'text': Colors.red.shade700,
          'dot': Colors.red.shade500,
        };
      case 'refunded':
      case 'returned':
        return {
          'bg': Colors.purple.shade50,
          'text': Colors.purple.shade700,
          'dot': Colors.purple.shade500,
        };
      case 'on-hold':
        return {
          'bg': Colors.amber.shade50,
          'text': Colors.amber.shade700,
          'dot': Colors.amber.shade500,
        };
      default:
        return {
          'bg': Colors.grey.shade100,
          'text': Colors.grey.shade700,
          'dot': Colors.grey.shade500,
        };
    }
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_outline : Icons.hourglass_empty,
            size: 14,
            color: isPaid ? Colors.green.shade600 : Colors.orange.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            _capitalizeStatus(paymentStatus),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash-on-delivery':
        return 'Cash on Delivery';
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      default:
        return _capitalizeStatus(method);
    }
  }

  // ─── ORDER ITEMS (Cached) ───
  Widget _buildOrderItemsRow(Order order) {
    return FutureBuilder<List<dynamic>>(
      future: _getCachedOrderItems(order.id.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Loading items...',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                'No items',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          );
        }

        final items = snapshot.data!;
        return Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            ...items
                .take(4)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildOrderItemThumb(item),
                  ),
                ),
            if (items.length > 4)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '+${items.length - 4}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOrderItemThumb(dynamic item) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child:
          item.imageUrl != null && item.imageUrl.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                ),
              )
              : Icon(
                Icons.image_outlined,
                size: 16,
                color: Colors.grey.shade400,
              ),
    );
  }

  // ─── ORDER ACTIONS ───
  void _handleOrderAction(String action, Order order) async {
    switch (action) {
      case 'edit':
        _controller.fetchOrderItems(order.id.toString());
        _controller.setSelectedOrder(order);
        Get.toNamed(Routes.ORDERS_DASHBOARD, preventDuplicates: false);
        break;
      case 'delete':
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Confirm Delete'),
                content: Text(
                  'Are you sure you want to delete order #${order.meta?['order_id'] ?? 'N/A'}?',
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
        if (confirmed == true && mounted) {
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
}
