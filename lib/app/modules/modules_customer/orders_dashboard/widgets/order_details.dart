import 'package:barcode_widget/barcode_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/modules/modules_admin/dashboard_admin/widgets/admin_dashboard_theme.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_invoice.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders/orders_service.dart';

class OrdersDetailOverview extends StatefulWidget {
  const OrdersDetailOverview({super.key});

  @override
  State<OrdersDetailOverview> createState() => _OrdersDetailOverviewState();
}

class _OrdersDetailOverviewState extends State<OrdersDetailOverview> {
  late final OrderService _orderService;
  late final OrdersDashboardController _controller;

  // Loading states
  bool _isDeleting = false;
  bool _isUpdatingStatus = false;

  // Safe getters
  bool get _isAdmin =>
      AuthService.instance.authCustomer?.user?.meta?.dashboardView == 'admin' ||
      AuthService.instance.authCustomer?.user?.meta?.dashboardView == 'vendor';

  @override
  void initState() {
    super.initState();
    _orderService = Get.find<OrderService>();
    _controller = Get.find<OrdersDashboardController>();
  }

  Future<void> _deleteOrder(String orderId) async {
    if (_isDeleting) return;

    try {
      final shouldDelete = await _showDeleteConfirmation();
      if (shouldDelete != true) return;

      setState(() => _isDeleting = true);

      await _orderService.deleteOrder(orderId);
      await _orderService.fetchOrders();

      if (!mounted) return;

      _controller.update();
      _orderService.orders.removeWhere(
        (ord) => ord.id == _controller.selectedOrder.value?.id,
      );
      _controller.selectedOrder.value = null;

      _showSnackBar('Order deleted successfully', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to delete order', isSuccess: false);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusLg),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminDashboardTheme.errorLight,
                    borderRadius: BorderRadius.circular(
                      AdminDashboardTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AdminDashboardTheme.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delete Order',
                  style: AdminDashboardTheme.headingMedium,
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this order? This action cannot be undone.',
              style: AdminDashboardTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: AdminDashboardTheme.outlineButtonStyle,
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: AdminDashboardTheme.errorButtonStyle,
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateOrderStatus() async {
    if (_isUpdatingStatus) return;

    try {
      setState(() => _isUpdatingStatus = true);

      await _controller.updateOrderStatus(
        _controller.selectedOrder.value?.id?.toString() ?? '',
        context,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update order status', isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor:
            isSuccess ? AdminDashboardTheme.success : AdminDashboardTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
      ),
    );
  }

  void _navigateBack() {
    final wasEdited = _controller.orderWasEdited.value;
    _controller.selectedOrder.value = null;
    _controller.orderWasEdited.value = false;
    if (wasEdited) {
      _orderService.refreshOrders();
    }
    Get.back();
  }

  void _generateInvoice() {
    final order = _controller.selectedOrder.value;
    if (order == null) return;
    final items = order.orderItems ?? [];
    OrderInvoiceGenerator(order: order, items: items).generateAndPrint();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          final wasEdited = _controller.orderWasEdited.value;
          _controller.selectedOrder.value = null;
          _controller.orderWasEdited.value = false;
          if (wasEdited) {
            _orderService.refreshOrders();
          }
        }
      },
      child: Obx(() {
        final selectedOrder = _controller.selectedOrder.value;
        if (selectedOrder == null) {
          return const _EmptyOrderState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderHeader(
              order: selectedOrder,
              isAdmin: _isAdmin,
              isDeleting: _isDeleting,
              isUpdatingStatus: _isUpdatingStatus,
              onDelete: () => _deleteOrder(selectedOrder.id?.toString() ?? ''),
              onUpdateStatus: _updateOrderStatus,
              onShowDispute: () {
                _controller.setisSHowndispute(true);
                setState(() {});
              },
              onUpdateOrderStatus: () {
                _controller.showUpdateOrderStatusDialog(
                  selectedOrder.id?.toString() ?? '',
                  context,
                  selectedOrder.status?.toString() ?? 'pending',
                );
              },
              onUpdatePaymentStatus: () {
                _controller.showUpdatePaymentStatusDialog(
                  selectedOrder.id?.toString() ?? '',
                  context,
                  selectedOrder.transaction?.paymentStatus?.toString() ??
                      'pending',
                );
              },
              onGenerateInvoice: _generateInvoice,
            ),
            const SizedBox(height: AdminDashboardTheme.spacingMd),
            _OrderDetailsCard(
              order: selectedOrder,
              controller: _controller,
              onNavigateBack: _navigateBack,
            ),
          ],
        );
      }),
    );
  }
}

/// Empty Order State Widget
class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminDashboardTheme.spacing2Xl),
      decoration: AdminDashboardTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
            decoration: const BoxDecoration(
              color: AdminDashboardTheme.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AdminDashboardTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AdminDashboardTheme.spacingLg),
          const Text(
            'No Order Selected',
            style: AdminDashboardTheme.headingMedium,
          ),
          const SizedBox(height: AdminDashboardTheme.spacingSm),
          const Text(
            'Select an order to view its details',
            style: AdminDashboardTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Order Header with action buttons
class _OrderHeader extends StatelessWidget {
  final dynamic order;
  final bool isAdmin;
  final bool isDeleting;
  final bool isUpdatingStatus;
  final VoidCallback onDelete;
  final VoidCallback onUpdateStatus;
  final VoidCallback onShowDispute;
  final VoidCallback onUpdateOrderStatus;
  final VoidCallback onUpdatePaymentStatus;
  final VoidCallback onGenerateInvoice;

  const _OrderHeader({
    required this.order,
    required this.isAdmin,
    required this.isDeleting,
    required this.isUpdatingStatus,
    required this.onDelete,
    required this.onUpdateStatus,
    required this.onShowDispute,
    required this.onUpdateOrderStatus,
    required this.onUpdatePaymentStatus,
    required this.onGenerateInvoice,
  });

  bool get _isPending => order.status?.toString().toLowerCase() == 'pending';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AdminDashboardTheme.spacingMd),
        // Row 1: Admin actions
        if (isAdmin)
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Order Status',
                  color: const Color(0xFF00897B),
                  isLoading: false,
                  onTap: onUpdateOrderStatus,
                ),
              ),
              const SizedBox(width: AdminDashboardTheme.spacingSm),
              Expanded(
                child: _ActionButton(
                  icon: Icons.payment_rounded,
                  label: 'Payment Status',
                  color: const Color(0xFF5C6BC0),
                  isLoading: false,
                  onTap: onUpdatePaymentStatus,
                ),
              ),
            ],
          ),
        if (isAdmin) const SizedBox(height: AdminDashboardTheme.spacingSm),
        // Row 2: Delete and Cancel/Dispute
        Row(
          children: [
            if (isAdmin)
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: AdminDashboardTheme.error,
                  isLoading: isDeleting,
                  onTap: onDelete,
                ),
              ),
            if (isAdmin) const SizedBox(width: AdminDashboardTheme.spacingSm),
            Expanded(
              child: _ActionButton(
                icon: _isPending ? Icons.cancel_outlined : Icons.gavel_rounded,
                label: _isPending ? 'Cancel' : 'Dispute',
                color:
                    _isPending
                        ? AdminDashboardTheme.warning
                        : AdminDashboardTheme.accent,
                isLoading: isUpdatingStatus,
                onTap: _isPending ? onUpdateStatus : onShowDispute,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminDashboardTheme.spacingSm),
        // Row 3: Generate Invoice
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'Generate Invoice',
                color: const Color(0xFF1E88E5),
                isLoading: false,
                onTap: onGenerateInvoice,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: isLoading ? AdminDashboardTheme.surfaceSecondary : color,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
            boxShadow:
                isLoading ? null : AdminDashboardTheme.shadowColored(color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AdminDashboardTheme.textSecondary,
                    ),
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isLoading
                          ? AdminDashboardTheme.textSecondary
                          : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Order Details Card
class _OrderDetailsCard extends StatefulWidget {
  final dynamic order;
  final OrdersDashboardController controller;
  final VoidCallback onNavigateBack;

  const _OrderDetailsCard({
    required this.order,
    required this.controller,
    required this.onNavigateBack,
  });

  @override
  State<_OrderDetailsCard> createState() => _OrderDetailsCardState();
}

class _OrderDetailsCardState extends State<_OrderDetailsCard> {
  late TextEditingController _trackingController;
  late TextEditingController _deliveryController;

  bool _trackingChanged = false;
  bool _deliveryChanged = false;
  bool _isUpdatingTracking = false;
  bool _isUpdatingDelivery = false;

  late String _originalTracking;
  late String _originalDelivery;

  // Mutable items list for deletion
  List<dynamic> _localItems = [];
  List<dynamic> _fetchedItems = [];
  bool _itemsFetched = false;
  bool _itemsLoading = false;
  final Set<String> _deletingItemIds = {};

  // Safe getters
  String get _orderId =>
      widget.order.meta?['order_id']?.toString() ?? '--';
  String get _shopName =>
      widget.order.shop?.shop?.name?.toString() ?? 'Unknown Shop';
  String get _shopBanner =>
      widget.order.shop?.shop?.banner?.media?.url?.toString() ?? '';
  String get _status => widget.order.status?.toString() ?? '--';
  String get _paymentStatus =>
      widget.order.transaction?.paymentStatus?.toString() ?? '--';
  String get _paymentMethod =>
      widget.order.transaction?.paymentMethod?.toString() ?? '--';

  @override
  void initState() {
    super.initState();
    final meta = widget.order.meta ?? <String, dynamic>{};

    _originalTracking = meta['tracking_number']?.toString() ?? '';
    if (_originalTracking == 'null') _originalTracking = '';
    _originalDelivery = meta['shipping_total']?.toString() ?? '0';

    _trackingController = TextEditingController(text: _originalTracking);
    _deliveryController = TextEditingController(text: _originalDelivery);

    _trackingController.addListener(_onTrackingChanged);
    _deliveryController.addListener(_onDeliveryChanged);

    // Initialize local items
    final embedded = widget.order.orderItems;
    if (embedded != null && (embedded as List).isNotEmpty) {
      _localItems = List.from(embedded);
    } else {
      _loadItems();
    }
  }

  void _onTrackingChanged() {
    setState(() {
      _trackingChanged = _trackingController.text != _originalTracking;
    });
  }

  void _onDeliveryChanged() {
    setState(() {
      _deliveryChanged = _deliveryController.text != _originalDelivery;
    });
  }

  Future<void> _loadItems() async {
    if (_itemsLoading) return;
    setState(() => _itemsLoading = true);
    try {
      final items = await widget.controller.fetchOrderItemsFuture(
        widget.order.id?.toString() ?? '',
      );
      if (mounted) {
        setState(() {
          _fetchedItems = List.from(items);
          _itemsFetched = true;
          _itemsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _itemsFetched = true;
          _itemsLoading = false;
        });
      }
    }
  }

  Future<void> _updateTrackingNumber() async {
    if (_isUpdatingTracking) return;
    setState(() => _isUpdatingTracking = true);

    final success = await widget.controller.updateOrderDetails(
      orderId: widget.order.id?.toString() ?? '',
      context: context,
      trackingNumber: _trackingController.text,
      currentOrder: widget.order,
    );

    if (success && mounted) {
      _originalTracking = _trackingController.text;
      setState(() {
        _trackingChanged = false;
        _isUpdatingTracking = false;
      });
    } else if (mounted) {
      setState(() => _isUpdatingTracking = false);
    }
  }

  Future<void> _updateDeliveryCharges() async {
    if (_isUpdatingDelivery) return;
    setState(() => _isUpdatingDelivery = true);

    final success = await widget.controller.updateOrderDetails(
      orderId: widget.order.id?.toString() ?? '',
      context: context,
      shippingTotal: _deliveryController.text,
      currentOrder: widget.order,
    );

    if (success && mounted) {
      _originalDelivery = _deliveryController.text;
      setState(() {
        _deliveryChanged = false;
        _isUpdatingDelivery = false;
      });
    } else if (mounted) {
      setState(() => _isUpdatingDelivery = false);
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    final itemId = item.id?.toString() ?? '';
    if (itemId.isEmpty || _deletingItemIds.contains(itemId)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AdminDashboardTheme.error, size: 22),
            SizedBox(width: 10),
            Text('Delete Item', style: AdminDashboardTheme.headingMedium),
          ],
        ),
        content: Text(
          'Remove "${item.product?.name ?? 'this item'}" from the order?',
          style: AdminDashboardTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: AdminDashboardTheme.errorButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deletingItemIds.add(itemId));

    final success = await widget.controller.deleteOrderItem(
      widget.order.id?.toString() ?? '',
      itemId,
      context,
    );

    if (success && mounted) {
      setState(() {
        _localItems.removeWhere((i) => i.id?.toString() == itemId);
        _fetchedItems.removeWhere((i) => i.id?.toString() == itemId);
        _deletingItemIds.remove(itemId);
      });
    } else if (mounted) {
      setState(() => _deletingItemIds.remove(itemId));
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminDashboardTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AdminDashboardTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: AdminDashboardTheme.spacingLg),
            _buildShopSection(),
            const SizedBox(height: AdminDashboardTheme.spacingLg),
            _buildOrderInfoSection(),
            const SizedBox(height: AdminDashboardTheme.spacingXl),
            _buildBuyerSection(),
            const SizedBox(height: AdminDashboardTheme.spacingXl),
            _buildItemsSection(),
            const SizedBox(height: AdminDashboardTheme.spacingXl),
            _buildOrderSummary(),
            const SizedBox(height: AdminDashboardTheme.spacingXl),
            _buildShippingBreakdown(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDashboardTheme.spacingSm),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.accentLight,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: AdminDashboardTheme.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: AdminDashboardTheme.spacingMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order ID', style: AdminDashboardTheme.bodySmall),
            Text(
              '#$_orderId',
              style: AdminDashboardTheme.headingMedium.copyWith(
                color: AdminDashboardTheme.accent,
              ),
            ),
          ],
        ),
        const Spacer(),
        Material(
          color: AdminDashboardTheme.accent,
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          child: InkWell(
            onTap: widget.onNavigateBack,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            child: const Padding(
              padding: EdgeInsets.all(AdminDashboardTheme.spacingSm),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopSection() {
    return Container(
      padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
      ),
      child: Row(
        children: [
          _ShopImage(shopName: _shopName, imageUrl: _shopBanner),
          const SizedBox(width: AdminDashboardTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shop', style: AdminDashboardTheme.bodySmall),
                const SizedBox(height: 4),
                Text(_shopName, style: AdminDashboardTheme.headingSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    final statusColor = AdminDashboardTheme.getStatusColor(_status);
    final statusBgColor = AdminDashboardTheme.getStatusBackgroundColor(_status);
    final statusIcon = AdminDashboardTheme.getStatusIcon(_status);

    return Column(
      children: [
        _DetailRow(
          label: 'Order Status',
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDashboardTheme.spacingSm,
              vertical: AdminDashboardTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  _status,
                  style: AdminDashboardTheme.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        _DetailRow(label: 'Payment Status', value: _paymentStatus),
        _DetailRow(label: 'Payment Method', value: _paymentMethod),
        // Editable Tracking Number
        _buildEditableTrackingRow(),
      ],
    );
  }

  Widget _buildEditableTrackingRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: AdminDashboardTheme.spacingSm),
          padding: const EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingSm,
            horizontal: AdminDashboardTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: Row(
            children: [
              Text(
                'Tracking #',
                style: AdminDashboardTheme.bodyMedium.copyWith(
                  color: AdminDashboardTheme.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AdminDashboardTheme.spacingMd),
              Expanded(
                child: TextField(
                  controller: _trackingController,
                  style: AdminDashboardTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminDashboardTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminDashboardTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminDashboardTheme.accent, width: 1.5),
                    ),
                    hintText: 'Enter tracking number',
                    hintStyle: AdminDashboardTheme.bodyMedium,
                  ),
                ),
              ),
              if (_trackingChanged) ...[
                const SizedBox(width: 8),
                _isUpdatingTracking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : InkWell(
                        onTap: _updateTrackingNumber,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AdminDashboardTheme.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ],
            ],
          ),
        ),
        // Barcode
        if (_trackingController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(
              bottom: AdminDashboardTheme.spacingMd,
            ),
            padding: const EdgeInsets.all(AdminDashboardTheme.spacingMd),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
              border: Border.all(color: AdminDashboardTheme.border),
            ),
            child: Center(
              child: BarcodeWidget(
                barcode: Barcode.code128(),
                data: _trackingController.text,
                width: 250,
                height: 60,
                drawText: true,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditableDeliveryRow(double currentFee) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AdminDashboardTheme.spacingXs,
      ),
      child: Row(
        children: [
          Text('Delivery Fee', style: AdminDashboardTheme.bodyMedium),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _deliveryController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AdminDashboardTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                prefixText: '\$ ',
                prefixStyle: AdminDashboardTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AdminDashboardTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AdminDashboardTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AdminDashboardTheme.accent, width: 1.5),
                ),
              ),
            ),
          ),
          if (_deliveryChanged) ...[
            const SizedBox(width: 8),
            _isUpdatingDelivery
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : InkWell(
                    onTap: _updateDeliveryCharges,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AdminDashboardTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  Widget _buildBuyerSection() {
    final meta = widget.order.meta ?? <String, dynamic>{};
    final customBuyer = widget.order.customBuyerDetails ?? <String, dynamic>{};
    final customAddress = widget.order.customAddressDetails ?? <String, dynamic>{};
    final buyer = widget.order.buyer;
    final user = buyer?.user;

    // Use custom_buyer_details first, then fall back to meta, then user
    final firstName =
        customBuyer['first_name']?.toString() ??
        meta['custom_buyer_first_name']?.toString() ??
        user?.firstName?.toString() ??
        '';
    final lastName =
        customBuyer['last_name']?.toString() ??
        meta['custom_buyer_last_name']?.toString() ??
        user?.lastName?.toString() ??
        '';
    final fullName = '$firstName $lastName'.trim();
    final email =
        customBuyer['email']?.toString() ??
        meta['custom_buyer_email']?.toString() ??
        user?.email?.toString() ??
        '--';
    final phone =
        customBuyer['phone']?.toString() ??
        meta['custom_buyer_phone']?.toString() ??
        user?.phone?.toString() ??
        '--';
    final address =
        customAddress['street_address']?.toString() ??
        meta['custom_buyer_street_address']?.toString() ??
        '--';
    final postal =
        customAddress['postal_code']?.toString() ??
        meta['custom_buyer_postal_code']?.toString() ??
        '--';
    final formattedAddress =
        customAddress['formatted_address']?.toString() ??
        meta['custom_buyer_formatted_address']?.toString();
    final city =
        customAddress['city']?.toString() ??
        meta['custom_buyer_city']?.toString();
    final state =
        customAddress['state']?.toString() ??
        meta['custom_buyer_state']?.toString();
    final country =
        customAddress['country']?.toString() ??
        meta['custom_buyer_country']?.toString();
    final orderDate =
        widget.order.createdAt?.toLocal().toString().split(' ')[0] ?? '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingMd,
            horizontal: AdminDashboardTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.accent,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
            boxShadow: AdminDashboardTheme.shadowColored(
              AdminDashboardTheme.accent,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.person_rounded, color: Colors.white, size: 20),
              SizedBox(width: AdminDashboardTheme.spacingSm),
              Text(
                'Buyer Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminDashboardTheme.spacingLg),
        _DetailRow(
          label: 'Full Name',
          value: fullName.isEmpty ? '--' : fullName,
        ),
        _DetailRow(label: 'Email', value: email),
        _DetailRow(label: 'Phone', value: phone),
        _DetailRow(label: 'Order Date', value: orderDate),
        _DetailRow(
          label: 'Address',
          value: formattedAddress ?? address,
        ),
        _DetailRow(label: 'Postal Code', value: postal),
        if (city != null && city.isNotEmpty && city != 'null')
          _DetailRow(label: 'City', value: city),
        if (state != null && state.isNotEmpty && state != 'null')
          _DetailRow(label: 'State', value: state),
        if (country != null && country.isNotEmpty && country != 'null')
          _DetailRow(label: 'Country', value: country),
      ],
    );
  }

  Widget _buildItemsSection() {
    // Use local items (embedded) or fetched items
    final items = _localItems.isNotEmpty ? _localItems : _fetchedItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDashboardTheme.spacingMd),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.accent,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Item Name',
                  style: AdminDashboardTheme.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Quantity',
                style: AdminDashboardTheme.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        if (_itemsLoading)
          const _ItemsShimmerList()
        else if (items.isEmpty && _itemsFetched)
          Container(
            padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
            decoration: BoxDecoration(
              color: AdminDashboardTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            ),
            child: const Center(
              child: Text('No items found', style: AdminDashboardTheme.bodyMedium),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemId = item.id?.toString() ?? '';
              return _OrderItemTile(
                item: item,
                isDeleting: _deletingItemIds.contains(itemId),
                onDelete: () => _deleteItem(item),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final meta = widget.order.meta ?? <String, dynamic>{};

    final double subtotal =
        double.tryParse(meta['initial_total']?.toString() ?? '0') ?? 0.0;
    final double shippingFee =
        double.tryParse(meta['shipping_total']?.toString() ?? '0') ?? 0.0;
    final double discountTotal =
        double.tryParse(meta['discount_total']?.toString() ?? '0') ?? 0.0;
    final double adminCommission = widget.order.adminCommissionTotal ?? 0.0;
    final double transactionAmount = widget.order.transaction?.amount ?? 0.0;
    final double finalOrderTotal = widget.order.orderTotal ?? 0.0;

    // Coupon info
    final couponCode = meta['coupon_code']?.toString();
    final double couponDiscount =
        double.tryParse(meta['coupon_discount']?.toString() ?? '0') ?? 0.0;
    final couponPercentage = meta['coupon_percentage']?.toString();

    // Wallet info
    final double walletAmount =
        double.tryParse(meta['wallet_checkout_amount']?.toString() ?? '0') ??
        0.0;

    // COD info
    final double codAmount =
        double.tryParse(meta['cod_amount']?.toString() ?? '0') ?? 0.0;

    // Reseller info
    final resellerId = meta['reseller_id']?.toString();
    final double resellerDiscount =
        double.tryParse(
          meta['reseller_commission_amount']?.toString() ?? '0',
        ) ?? 0.0;
    final resellerPercentage =
        meta['reseller_commission_percentage']?.toString();

    // Bonus info
    final double bonusEarned =
        double.tryParse(meta['bonus_earned']?.toString() ?? '0') ?? 0.0;

    // Check if this is a reseller order
    final bool isResellerOrder =
        resellerId != null && resellerId.isNotEmpty && resellerId != 'null';

    // Calculate total discounts
    double totalDiscounts = 0;
    if (resellerDiscount > 0) totalDiscounts += resellerDiscount;
    if (couponDiscount > 0) totalDiscounts += couponDiscount;
    if (discountTotal > 0 && totalDiscounts == 0) {
      totalDiscounts = discountTotal;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Summary Header
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingMd,
            horizontal: AdminDashboardTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.accent,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
            boxShadow: AdminDashboardTheme.shadowColored(
              AdminDashboardTheme.accent,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_rounded, color: Colors.white, size: 20),
              SizedBox(width: AdminDashboardTheme.spacingSm),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminDashboardTheme.spacingLg),

        // Reseller order label
        if (isResellerOrder)
          Container(
            margin: const EdgeInsets.only(
              bottom: AdminDashboardTheme.spacingSm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDashboardTheme.spacingMd,
              vertical: AdminDashboardTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(
                AdminDashboardTheme.radiusSm,
              ),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront, size: 16, color: Color(0xFFE65100)),
                SizedBox(width: 6),
                Text(
                  'Reseller Order',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),

        _SummaryRow(
          label: 'Subtotal',
          value: subtotal > 0 ? '\$${subtotal.toStringAsFixed(2)}' : '--',
        ),
        // Editable Delivery Fee
        _buildEditableDeliveryRow(shippingFee),

        // Applied Discounts Section
        if (totalDiscounts > 0 ||
            (couponCode != null &&
                couponCode.isNotEmpty &&
                couponCode != 'null')) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: AdminDashboardTheme.spacingSm,
            ),
            child: Divider(color: AdminDashboardTheme.divider),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: AdminDashboardTheme.spacingXs,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer_rounded,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Applied Discounts',
                  style: AdminDashboardTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (isResellerOrder && resellerDiscount > 0)
            _SummaryRow(
              label:
                  'Reseller Discount${resellerPercentage != null ? ' ($resellerPercentage%)' : ''}',
              value: '-\$${resellerDiscount.toStringAsFixed(2)}',
              valueColor: AdminDashboardTheme.success,
            ),
          if (couponCode != null &&
              couponCode.isNotEmpty &&
              couponCode != 'null')
            _SummaryRow(
              label:
                  'Coupon "$couponCode"${couponPercentage != null && couponPercentage != 'null' ? ' ($couponPercentage%)' : ''}',
              value:
                  couponDiscount > 0
                      ? '-\$${couponDiscount.toStringAsFixed(2)}'
                      : 'Applied',
              valueColor: AdminDashboardTheme.success,
            ),
          if (discountTotal > 0 &&
              resellerDiscount == 0 &&
              couponDiscount == 0)
            _SummaryRow(
              label: 'Discount',
              value: '-\$${discountTotal.toStringAsFixed(2)}',
              valueColor: AdminDashboardTheme.success,
            ),
          _SummaryRow(
            label: 'Total Discounts',
            value: '-\$${totalDiscounts.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AdminDashboardTheme.success,
          ),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingSm,
          ),
          child: Divider(color: AdminDashboardTheme.divider),
        ),

        if (adminCommission > 0)
          _SummaryRow(
            label: 'Admin Commission',
            value: '-\$${adminCommission.toStringAsFixed(2)}',
          ),
        if (walletAmount > 0)
          _SummaryRow(
            label: 'Wallet Payment',
            value: '-\$${walletAmount.toStringAsFixed(2)}',
            valueColor: AdminDashboardTheme.accent,
          ),
        if (codAmount > 0)
          _SummaryRow(
            label: 'COD Amount',
            value: '\$${codAmount.toStringAsFixed(2)}',
          ),
        if (transactionAmount > 0)
          _SummaryRow(
            label: 'Transaction Amount',
            value: '\$${transactionAmount.toStringAsFixed(2)}',
          ),

        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingSm,
          ),
          child: Divider(color: AdminDashboardTheme.divider, thickness: 2),
        ),
        _SummaryRow(
          label: 'Final Total',
          value:
              finalOrderTotal > 0
                  ? '\$${finalOrderTotal.toStringAsFixed(2)}'
                  : '--',
          isBold: true,
          valueColor: AdminDashboardTheme.success,
        ),

        // Bonus earned
        if (bonusEarned > 0)
          Padding(
            padding: const EdgeInsets.only(
              top: AdminDashboardTheme.spacingSm,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDashboardTheme.spacingMd,
                vertical: AdminDashboardTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(
                  AdminDashboardTheme.radiusSm,
                ),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Bonus Earned',
                        style: AdminDashboardTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+\$${bonusEarned.toStringAsFixed(2)}',
                    style: AdminDashboardTheme.headingSmall.copyWith(
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShippingBreakdown() {
    final breakdown = widget.order.shippingBreakdown;
    if (breakdown == null || breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingMd,
            horizontal: AdminDashboardTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.accent,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
            boxShadow: AdminDashboardTheme.shadowColored(
              AdminDashboardTheme.accent,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
              SizedBox(width: AdminDashboardTheme.spacingSm),
              Text(
                'Shipping Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminDashboardTheme.spacingLg),
        ...breakdown.entries
            .where(
              (e) =>
                  e.value != null &&
                  e.value.toString().isNotEmpty &&
                  e.value.toString() != 'null',
            )
            .map(
              (e) => _DetailRow(
                label: _formatLabel(e.key),
                value: e.value is num
                    ? '\$${(e.value as num).toStringAsFixed(2)}'
                    : e.value.toString(),
              ),
            ),
      ],
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');
  }
}

/// Shop Image Widget
class _ShopImage extends StatelessWidget {
  final String shopName;
  final String imageUrl;

  const _ShopImage({required this.shopName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        boxShadow: AdminDashboardTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          cacheManager: PersistentCacheManager(),
          placeholder:
              (context, url) => Container(
                color: AdminDashboardTheme.accent,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: AdminDashboardTheme.accent,
                child: Center(
                  child: Text(
                    shopName.length >= 2
                        ? shopName.substring(0, 2).toUpperCase()
                        : shopName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

/// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _DetailRow({required this.label, this.value, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminDashboardTheme.spacingSm),
      padding: const EdgeInsets.symmetric(
        vertical: AdminDashboardTheme.spacingMd,
        horizontal: AdminDashboardTheme.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AdminDashboardTheme.bodyMedium.copyWith(
              color: AdminDashboardTheme.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
          child ??
              Text(
                value ?? '--',
                style: AdminDashboardTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }
}

/// Summary Row Widget
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AdminDashboardTheme.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isBold
                    ? AdminDashboardTheme.headingSmall
                    : AdminDashboardTheme.bodyMedium,
          ),
          Text(
            value,
            style: (isBold
                    ? AdminDashboardTheme.headingMedium
                    : AdminDashboardTheme.bodyLarge)
                .copyWith(
                  color: valueColor,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Order Item Tile Widget
class _OrderItemTile extends StatelessWidget {
  final dynamic item;
  final bool isDeleting;
  final VoidCallback? onDelete;

  const _OrderItemTile({
    required this.item,
    this.isDeleting = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AdminDashboardTheme.spacingSm),
      padding: const EdgeInsets.all(AdminDashboardTheme.spacingMd),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surface,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
        border: Border.all(color: AdminDashboardTheme.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              cacheManager: PersistentCacheManager(),
              placeholder:
                  (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: AdminDashboardTheme.surfaceSecondary,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: 50,
                    height: 50,
                    color: AdminDashboardTheme.surfaceSecondary,
                    child: const Icon(
                      Icons.image_rounded,
                      color: AdminDashboardTheme.textTertiary,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: AdminDashboardTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Unknown Product',
                  style: AdminDashboardTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price ?? 0}',
                  style: AdminDashboardTheme.bodyMedium.copyWith(
                    color: AdminDashboardTheme.success,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDashboardTheme.spacingSm,
              vertical: AdminDashboardTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AdminDashboardTheme.primaryLight,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            ),
            child: Text(
              'x${item.quantity ?? 1}',
              style: AdminDashboardTheme.labelMedium.copyWith(
                color: AdminDashboardTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AdminDashboardTheme.error,
                    ),
                  )
                : InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AdminDashboardTheme.error,
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

/// Items Shimmer Loading
class _ItemsShimmerList extends StatelessWidget {
  const _ItemsShimmerList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AdminDashboardTheme.surfaceSecondary,
      highlightColor: AdminDashboardTheme.surface,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(top: AdminDashboardTheme.spacingSm),
            height: 70,
            decoration: BoxDecoration(
              color: AdminDashboardTheme.surface,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}
