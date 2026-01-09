// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_types_as_parameter_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/orders_dashboard/widgets/orders_dashboard_widget.dart';

class OrdersOverview extends StatelessWidget {
  const OrdersOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderService _orderService = Get.find<OrderService>();
    final OrdersDashboardController controller =
        Get.find<OrdersDashboardController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w100,
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => StatisticsCard(
            title: 'Orders Pending',
            count: _orderService.orders.length.toString(),
            color: Colors.pink,

            isIncreasing: true,
          ),
        ),
        const SizedBox(height: 16),
        const StatisticsCard(
          title: 'Orders Processing',
          count: '0',
          color: Colors.teal,

          isIncreasing: false,
        ),
        const SizedBox(height: 10),
        _buildOrderList(_orderService, controller, context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOrderList(
    OrderService,
    OrdersDashboardController,
    BuildContext context,
  ) {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            OrderService.orders.length,
            (index) => _buildOrderItem(
              OrderService.orders[index],
              OrdersDashboardController,
              context,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderItem(
    Order order,
    OrdersDashboardController controller,
    BuildContext context,
  ) {
    return SizedBox(
  
      height: 100,
      child: IntrinsicWidth(
        child: Row(
          children: [
            const SizedBox(width: 20),
            _buildOrderColumn(
              'Order Id',
              (order.meta?['order_id'] ?? '').toString(),
            ),
            const SizedBox(width: 30),
            _buildOrderColumn(
              'Shop Seller',
              order.buyer?.user?.firstName ?? 'N/Aa',
            ),
            const SizedBox(width: 30),
            _buildOrderColumn('Order Total', order.orderTotal.toString()),
            const SizedBox(width: 30),
            _buildOrderColumn('Order Status', order.status.toString()),
            const SizedBox(width: 30),
            GestureDetector(
              onTapDown:
                  (details) =>
                      _showPopupMenu(context, details, order, controller),
              child: const Icon(Icons.more_vert, size: 28),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(
    BuildContext context,
    TapDownDetails details,
    Order order,
    OrdersDashboardController controller,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Size screenSize = overlay.size;
    const double iconSize = 40;
    double dx = details.globalPosition.dx - 40;
    final double dy = details.globalPosition.dy + 10;
    if (dx < 0) {
      dx = 0;
    }

    // Pre-define menu items to avoid rebuilding
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem(
        value: "View",
        onTap: () async {
          await controller.fetchOrderItems(order.id.toString());
          Future.microtask(() => controller.setSelectedOrder(order));
        },
        child: const Row(
          children: [
            Icon(Icons.grid_view_rounded, color: Colors.blue),
            SizedBox(width: 10),
            Text(
              "View Order",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(dx, dy, iconSize, 60),
        Offset.zero & screenSize,
      ),
      items: menuItems,
      elevation: 5.0,
      color: Colors.white,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildOrderColumn(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value),
      ],
    );
  }
}
