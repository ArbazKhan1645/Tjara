// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class OrdersDetailOverview extends StatefulWidget {
  const OrdersDetailOverview({super.key});

  @override
  State<OrdersDetailOverview> createState() => _OrdersDetailOverviewState();
}

class _OrdersDetailOverviewState extends State<OrdersDetailOverview> {
  late final OrderService _orderService;
  late final OrdersDashboardController _controller;
  late final bool _isAdmin;

  // Loading states
  bool _isDeleting = false;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _orderService = Get.find<OrderService>();
    _controller = Get.find<OrdersDashboardController>();
    _isAdmin = AuthService.instance.authCustomer?.user?.role == 'admin';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _deleteOrder(String orderId) async {
    if (_isDeleting) return; // Prevent multiple simultaneous calls

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

      _showSuccessSnackBar('Order deleted successfully');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to delete order: ${e.toString()}');
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
            title: const Text('Delete Order'),
            content: const Text(
              'Are you sure you want to delete this order? This action cannot be undone.',
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
  }

  Future<void> _updateOrderStatus() async {
    if (_isUpdatingStatus) return;

    try {
      setState(() => _isUpdatingStatus = true);

      await _controller.updateOrderStatus(
        _controller.selectedOrder.value!.id.toString(),
        context,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update order status: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateBack() {
    // Clear the selected order before navigating back
    _controller.selectedOrder.value = null;
    // Use GetX navigation to ensure proper route management and avoid controller deletion
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _controller.selectedOrder.value = null;
        }
      },
      child: Obx(() {
        final selectedOrder = _controller.selectedOrder.value;
        if (selectedOrder == null) {
          return const Center(child: Text('No order selected'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(selectedOrder),
            const SizedBox(height: 10),
            _buildOrderDetails(selectedOrder),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(selectedOrder) {
    final isPending =
        selectedOrder.status?.toString().toLowerCase() == 'pending';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w100,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              if (_isAdmin) _buildDeleteButton(selectedOrder),
              _buildActionButton(selectedOrder, isPending),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(selectedOrder) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: InkWell(
          onTap:
              _isDeleting
                  ? null
                  : () => _deleteOrder(selectedOrder.id.toString()),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            decoration: BoxDecoration(
              color: _isDeleting ? Colors.grey.shade300 : Colors.red.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isDeleting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: defaultTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(selectedOrder, bool isPending) {
    final isLoading = _isUpdatingStatus;

    return Expanded(
      child: InkWell(
        onTap:
            isLoading
                ? null
                : (isPending
                    ? _updateOrderStatus
                    : () {
                      _controller.setisSHowndispute(true);
                      setState(() {});
                    }),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          width: 130,
          decoration: BoxDecoration(
            color:
                isLoading
                    ? Colors.grey.shade300
                    : isPending
                    ? Colors.orange.shade600
                    : const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isPending ? Colors.orange : const Color(0xFF0D9488))
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  isPending ? Icons.cancel_outlined : Icons.gavel,
                  color: Colors.white,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Text(
                isPending ? 'Cancel' : 'Dispute',
                style: defaultTextStyle.copyWith(
                  color: Colors.white,
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

  Widget _buildOrderDetails(selectedOrder) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildOrderHeader(selectedOrder),
            const SizedBox(height: 8),
            _buildShopDetails(selectedOrder),
            const SizedBox(height: 12),
            _buildOrderInfo(selectedOrder),
            const SizedBox(height: 60),
            _buildBuyerDetails(selectedOrder),
            const SizedBox(height: 20),
            _buildItemsHeader(),
            _buildItemsList(selectedOrder),
            const SizedBox(height: 20),
            _buildOrderSummary(selectedOrder),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(selectedOrder) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          'Order ID: #',
          style: defaultTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF0D9488),
          ),
        ),
        Text(
          selectedOrder.meta?['order_id']?.toString() ?? '--',
          style: defaultTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: _navigateBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildShopDetails(selectedOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            Text(
              'SHOP DETAILS:',
              style: defaultTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF0D9488),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(width: 10),
            _buildShopImage(selectedOrder),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selectedOrder.shop?.shop?.name?.toString() ?? '--',
                style: defaultTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShopImage(selectedOrder) {
    final shopName = selectedOrder.shop?.shop?.name?.toString() ?? '';
    final imageUrl = selectedOrder.shop?.shop?.banner?.media?.url?.toString();

    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: const Color(0xFF0D9488), width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          placeholder:
              (context, url) => Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          height: 120,
          width: 120,
          errorWidget:
              (context, url, error) => Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    shopName.length >= 2
                        ? shopName.substring(0, 2).toUpperCase()
                        : shopName.toUpperCase(),
                    style: defaultTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
          cacheManager: PersistentCacheManager(),
          fit: BoxFit.cover,
          imageUrl: imageUrl ?? '',
        ),
      ),
    );
  }

  Widget _buildOrderInfo(selectedOrder) {
    return Column(
      children: [
        _buildDetailRow(
          'Order Status:',
          selectedOrder.status?.toString() ?? '--',
        ),
        _buildDetailRow(
          'Payment Status:',
          selectedOrder.transaction?.paymentStatus?.toString() ?? '--',
        ),
        _buildDetailRow('Tracking Number:', '#--'),
        _buildDetailRow(' ', '-'),
        _buildDetailRow(
          'Payment Method: ',
          selectedOrder.transaction?.paymentMethod?.toString() ?? '--',
        ),
      ],
    );
  }

  Widget _buildBuyerDetails(selectedOrder) {
    final meta = selectedOrder.meta ?? <String, dynamic>{};
    final buyer = selectedOrder.buyer;
    final user = buyer?.user;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Buyer Details',
              style: defaultTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Full Name:',
          '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Email:',
          meta['custom_buyer_email']?.toString() ?? '--',
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Phone Number:',
          meta['custom_buyer_phone']?.toString() ?? '--',
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Order Date:',
          selectedOrder.createdAt?.toLocal().toString().split(' ')[0] ?? '--',
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Address:',
          meta['custom_buyer_street_address']?.toString() ?? '--',
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Postal:',
          meta['custom_buyer_postal_code']?.toString() ?? '--',
        ),
      ],
    );
  }

  Widget _buildItemsHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0D9488), width: 2),
        color: const Color(0xFF0D9488),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Item Name',
                style: defaultTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Quantity',
                style: defaultTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(selectedOrder) {
    return FutureBuilder(
      future: _controller.fetchOrderItemsFuture(
        selectedOrder.id?.toString() ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error loading items: ${snapshot.error}'),
            ),
          );
        }

        final items = snapshot.data;
        if (items == null || items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No items found'),
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
            return Card(
              elevation: 0,
              child: ListTile(
                leading: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                  errorWidget: (context, url, error) => const Icon(Icons.image),
                ),
                title: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "\$${item.price}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderSummary(selectedOrder) {
    final meta = selectedOrder.meta ?? <String, dynamic>{};

    // Parse financial values with proper fallbacks
    final double subtotal =
        double.tryParse(meta['initial_total']?.toString() ?? '0') ?? 0.0;
    final double shippingFee =
        double.tryParse(meta['shipping_total']?.toString() ?? '0') ?? 0.0;
    final double discountTotal =
        double.tryParse(meta['discount_total']?.toString() ?? '0') ?? 0.0;
    final double adminCommission = selectedOrder.adminCommissionTotal ?? 0.0;
    final double transactionAmount = selectedOrder.transaction?.amount ?? 0.0;
    final double finalOrderTotal = selectedOrder.orderTotal ?? 0.0;

    // Calculate intermediate total (subtotal + shipping - discount)
    final double calculatedTotal = subtotal + shippingFee - discountTotal;

    return Column(
      children: [
        _buildDetailRow(
          'Subtotal:',
          subtotal > 0 ? '\$${subtotal.toStringAsFixed(2)}' : '--',
        ),
        const SizedBox(height: 10),
        _buildDetailRow(
          'Delivery Fee:',
          shippingFee > 0 ? '\$${shippingFee.toStringAsFixed(2)}' : 'Free',
        ),
        if (discountTotal > 0) ...[
          const SizedBox(height: 10),
          _buildDetailRow(
            'Discount:',
            '-\$${discountTotal.toStringAsFixed(2)}',
          ),
        ],
        const Divider(),
        const SizedBox(height: 10),
        _buildDetailRow(
          'Subtotal + Fees:',
          calculatedTotal > 0
              ? '\$${calculatedTotal.toStringAsFixed(2)}'
              : '--',
        ),
        if (adminCommission > 0) ...[
          const SizedBox(height: 10),
          _buildDetailRow(
            'Admin Commission:',
            '-\$${adminCommission.toStringAsFixed(2)}',
          ),
        ],
        const Divider(),
        const SizedBox(height: 10),
        _buildDetailRow(
          'Transaction Amount:',
          transactionAmount > 0
              ? '\$${transactionAmount.toStringAsFixed(2)}'
              : '--',
        ),
        const Divider(),
        _buildDetailRow(
          'Final Total:',
          finalOrderTotal > 0
              ? '\$${finalOrderTotal.toStringAsFixed(2)}'
              : '--',
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: defaultTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF0D9488),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: defaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
