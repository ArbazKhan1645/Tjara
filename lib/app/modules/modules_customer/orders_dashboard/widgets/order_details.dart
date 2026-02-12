import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/modules/modules_admin/dashboard_admin/widgets/admin_dashboard_theme.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders_service.dart';

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
      AuthService.instance.authCustomer?.user?.role == 'admin' ||
      AuthService.instance.authCustomer?.user?.role == 'vendor';

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
    _controller.selectedOrder.value = null;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _controller.selectedOrder.value = null;
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
class _OrderDetailsCard extends StatelessWidget {
  final dynamic order;
  final OrdersDashboardController controller;
  final VoidCallback onNavigateBack;

  const _OrderDetailsCard({
    required this.order,
    required this.controller,
    required this.onNavigateBack,
  });

  // Safe getters
  String get _orderId => order.meta?['order_id']?.toString() ?? '--';
  String get _shopName => order.shop?.shop?.name?.toString() ?? 'Unknown Shop';
  String get _shopBanner =>
      order.shop?.shop?.banner?.media?.url?.toString() ?? '';
  String get _status => order.status?.toString() ?? '--';
  String get _paymentStatus =>
      order.transaction?.paymentStatus?.toString() ?? '--';
  String get _paymentMethod =>
      order.transaction?.paymentMethod?.toString() ?? '--';

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
            onTap: onNavigateBack,
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
        const _DetailRow(label: 'Tracking Number', value: '#--'),
      ],
    );
  }

  Widget _buildBuyerSection() {
    final meta = order.meta ?? <String, dynamic>{};
    final buyer = order.buyer;
    final user = buyer?.user;

    final firstName = user?.firstName?.toString() ?? '';
    final lastName = user?.lastName?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = meta['custom_buyer_email']?.toString() ?? '--';
    final phone = meta['custom_buyer_phone']?.toString() ?? '--';
    final address = meta['custom_buyer_street_address']?.toString() ?? '--';
    final postal = meta['custom_buyer_postal_code']?.toString() ?? '--';
    final orderDate =
        order.createdAt?.toLocal().toString().split(' ')[0] ?? '--';

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
        _DetailRow(label: 'Address', value: address),
        _DetailRow(label: 'Postal Code', value: postal),
      ],
    );
  }

  Widget _buildItemsSection() {
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
            ],
          ),
        ),
        FutureBuilder(
          future: controller.fetchOrderItemsFuture(order.id?.toString() ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ItemsShimmerList();
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.errorLight,
                  borderRadius: BorderRadius.circular(
                    AdminDashboardTheme.radiusSm,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AdminDashboardTheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to load items',
                        style: AdminDashboardTheme.bodyMedium.copyWith(
                          color: AdminDashboardTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final items = snapshot.data;
            if (items == null || items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(
                    AdminDashboardTheme.radiusSm,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'No items found',
                    style: AdminDashboardTheme.bodyMedium,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _OrderItemTile(item: item);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final meta = order.meta ?? <String, dynamic>{};

    final double subtotal =
        double.tryParse(meta['initial_total']?.toString() ?? '0') ?? 0.0;
    final double shippingFee =
        double.tryParse(meta['shipping_total']?.toString() ?? '0') ?? 0.0;
    final double discountTotal =
        double.tryParse(meta['discount_total']?.toString() ?? '0') ?? 0.0;
    final double adminCommission = order.adminCommissionTotal ?? 0.0;
    final double transactionAmount = order.transaction?.amount ?? 0.0;
    final double finalOrderTotal = order.orderTotal ?? 0.0;
    final double calculatedTotal = subtotal + shippingFee - discountTotal;

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
        _SummaryRow(
          label: 'Subtotal',
          value: subtotal > 0 ? '\$${subtotal.toStringAsFixed(2)}' : '--',
        ),
        _SummaryRow(
          label: 'Delivery Fee',
          value:
              shippingFee > 0 ? '\$${shippingFee.toStringAsFixed(2)}' : 'Free',
        ),
        if (discountTotal > 0)
          _SummaryRow(
            label: 'Discount',
            value: '-\$${discountTotal.toStringAsFixed(2)}',
            valueColor: AdminDashboardTheme.success,
          ),
        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingSm,
          ),
          child: Divider(color: AdminDashboardTheme.divider),
        ),
        _SummaryRow(
          label: 'Subtotal + Fees',
          value:
              calculatedTotal > 0
                  ? '\$${calculatedTotal.toStringAsFixed(2)}'
                  : '--',
        ),
        if (adminCommission > 0)
          _SummaryRow(
            label: 'Admin Commission',
            value: '-\$${adminCommission.toStringAsFixed(2)}',
          ),
        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AdminDashboardTheme.spacingSm,
          ),
          child: Divider(color: AdminDashboardTheme.divider),
        ),
        _SummaryRow(
          label: 'Transaction Amount',
          value:
              transactionAmount > 0
                  ? '\$${transactionAmount.toStringAsFixed(2)}'
                  : '--',
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
      ],
    );
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

  const _OrderItemTile({required this.item});

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
