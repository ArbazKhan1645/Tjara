// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_types_as_parameter_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/orders_dashboard/widgets/orders_web_analytics.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/dashbopard_services/admin_dashboard_service.dart';

class AdminDashboardOverviewWidget extends StatelessWidget {
  const AdminDashboardOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardService _orderService =
        Get.find<AdminDashboardService>();
    final OrdersDashboardController controller =
        Get.find<OrdersDashboardController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrdersWebAnalyticsPage(
          usernumber: '',
          userid:
              (AuthService.instance.role ?? 'customer') != 'admin'
                  ? '${AuthService.instance.authCustomer?.user?.firstName ?? ''} ${AuthService.instance.authCustomer?.user?.lastName ?? ''}'
                  : '',
        ),
        const SizedBox(height: 8),
        if ((AuthService.instance.role ?? 'customer') == 'admin')
          _buildOrderList(_orderService, controller, context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOrderList(
    AdminDashboardService dashboardOrdersService,
    OrdersDashboardController,
    BuildContext context,
  ) {
    return Obx(() {
      return Column(
        children: [
          SingleChildScrollView(
            controller: dashboardOrdersService.scrollController,
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                dashboardOrdersService.orders.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildOrderItem(
                    dashboardOrdersService.orders[index],
                    OrdersDashboardController,
                    context,
                  ),
                ),
              ),
            ),
          ),
          if (dashboardOrdersService.orders.isNotEmpty)
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          dashboardOrdersService.currentPage.value > 1
                              ? dashboardOrdersService.previousPage
                              : null,
                    ),
                    ...dashboardOrdersService.visiblePageNumbers().map(
                      (page) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            minimumSize: const Size(30, 30),
                            backgroundColor:
                                page == dashboardOrdersService.currentPage.value
                                    ? const Color(0xffF97316)
                                    : Colors.grey[300],
                            foregroundColor:
                                page == dashboardOrdersService.currentPage.value
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          onPressed: () async {
                            await dashboardOrdersService.goToPage(page);
                            dashboardOrdersService.fetchOrders(
                              loaderType: false,
                            );
                          },
                          child: Text(page.toString()),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          dashboardOrdersService.currentPage.value <
                                  dashboardOrdersService.totalPages.value
                              ? dashboardOrdersService.nextPage
                              : null,
                    ),
                  ],
                ),
              );
            }),
        ],
      );
    });
  }

  Widget _buildOrderItem(
    Order order,
    OrdersDashboardController controller,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 1, spreadRadius: 1),
        ],
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 100,
      child: IntrinsicWidth(
        child: Row(
          children: [
            const SizedBox(width: 20),
            _buildOrderColumn(
              'Customer Name',
              "${order.buyer!.user!.firstName} ${order.buyer!.user!.lastName}",
            ),
            const SizedBox(width: 30),
            _buildOrderColumn(
              'Order Id',
              (order.meta?['order_id'] ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
              textColor: Colors.red,
              hasIcon: true,
            ),
            const SizedBox(width: 30),
            _buildOrderColumn(
              'Shop Seller',
              order.buyer?.user?.firstName ?? 'N/Aa',
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 30),
            _buildOrderColumn(
              'Order Total',
              order.orderTotal.toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 30),
            _buildOrderColumn(
              'Order Status',
              order.status.toString(),
              icon: Icons.pending_actions,
              hasIcon: true,
              iconColor:
                  order.status.toString().toLowerCase() == 'pending'
                      ? Colors.red
                      : order.status.toString().toLowerCase() == 'completed'
                      ? Colors.green
                      : Colors.black,
              textColor:
                  order.status.toString().toString().toLowerCase() == 'pending'
                      ? Colors.red
                      : order.status.toString().toLowerCase() == 'Completed'
                      ? Colors.green
                      : Colors.black,
            ),
            const SizedBox(width: 30),
            GestureDetector(
              onTapDown:
                  (details) =>
                      _showPopupMenu(context, details, order, controller),
              child: const Icon(Icons.more_vert, size: 28),
            ),
            const SizedBox(width: 20),
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
          controller.fetchOrderItems(order.id.toString());
          Future.microtask(() => controller.setSelectedOrder(order));
          // Navigate to orders dashboard to view the order details
          Get.toNamed(Routes.ORDERS_DASHBOARD);
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

  Widget _buildOrderColumn(
    String label,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    Color textColor = Colors.black,
    bool hasIcon = false,
    IconData icon = Icons.open_in_new,
    Color iconColor = Colors.red,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Row(
          children: [
            if (hasIcon) Icon(icon, size: 16, color: iconColor),
            Text(value, style: TextStyle(color: textColor)),
          ],
        ),
      ],
    );
  }
}
