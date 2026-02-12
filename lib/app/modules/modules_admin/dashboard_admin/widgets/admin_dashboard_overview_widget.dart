import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/modules_admin/dashboard_admin/widgets/admin_dashboard_theme.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/orders_web_analytics.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/dashbopard_services/admin_dashboard_service.dart';

class AdminDashboardOverviewWidget extends StatelessWidget {
  const AdminDashboardOverviewWidget({super.key});

  // Safe getters for auth data
  String get _userRole =>
      AuthService.instance.authCustomer?.user?.meta?.dashboardView ??
      'customer';
  String get _userName {
    final user = AuthService.instance.authCustomer?.user;
    final firstName = user?.firstName ?? '';
    final lastName = user?.lastName ?? '';
    return '$firstName $lastName'.trim();
  }

  bool get _isAdmin => _userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    final AdminDashboardService orderService =
        Get.find<AdminDashboardService>();
    final OrdersDashboardController controller =
        Get.find<OrdersDashboardController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrdersWebAnalyticsPage(
          usernumber: '',
          userid: _isAdmin ? '' : _userName,
        ),
        const SizedBox(height: AdminDashboardTheme.spacingMd),
        if (_isAdmin)
          _OrdersListSection(
            orderService: orderService,
            controller: controller,
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

/// Orders List Section with header and list
class _OrdersListSection extends StatelessWidget {
  final AdminDashboardService orderService;
  final OrdersDashboardController controller;

  const _OrdersListSection({
    required this.orderService,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = orderService.isLoading.value;
      final orders = orderService.orders;
      final hasOrders = orders.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(hasOrders ? orders.length : 0),
          const SizedBox(height: AdminDashboardTheme.spacingMd),

          // Orders Content
          if (isLoading)
            const _OrdersShimmerList()
          else if (!hasOrders)
            const _EmptyOrdersState()
          else
            _buildOrdersList(orders),

          // Pagination
          if (hasOrders && !isLoading)
            _OrdersPagination(orderService: orderService),
        ],
      );
    });
  }

  Widget _buildSectionHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
      decoration: AdminDashboardTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDashboardTheme.spacingSm),
            decoration: BoxDecoration(
              color: AdminDashboardTheme.primaryLight,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: AdminDashboardTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AdminDashboardTheme.spacingMd),
          const Expanded(
            child: Text(
              'Recent Orders',
              style: AdminDashboardTheme.headingMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDashboardTheme.spacingMd,
              vertical: AdminDashboardTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AdminDashboardTheme.accentLight,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            ),
            child: Text(
              '$count orders',
              style: AdminDashboardTheme.labelMedium.copyWith(
                color: AdminDashboardTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return SingleChildScrollView(
      controller: orderService.scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          orders.length,
          (index) => Padding(
            padding: const EdgeInsets.only(
              bottom: AdminDashboardTheme.spacingSm,
            ),
            child: _OrderItemCard(order: orders[index], controller: controller),
          ),
        ),
      ),
    );
  }
}

/// Single Order Item Card with elegant styling
class _OrderItemCard extends StatefulWidget {
  final Order order;
  final OrdersDashboardController controller;

  const _OrderItemCard({required this.order, required this.controller});

  @override
  State<_OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<_OrderItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  // Safe getters for order data
  String get _orderId => widget.order.meta?['order_id']?.toString() ?? '-';
  String get _customerName {
    final buyer = widget.order.buyer;
    final firstName = buyer?.user?.firstName ?? '';
    final lastName = buyer?.user?.lastName ?? '';
    return '$firstName $lastName'.trim().isEmpty
        ? 'Unknown Customer'
        : '$firstName $lastName'.trim();
  }

  String get _shopName => widget.order.shop?.shop?.name ?? 'Unknown Shop';
  String get _orderTotal {
    final total = widget.order.orderTotal;
    return total != null ? '\$${total.toStringAsFixed(2)}' : '--';
  }

  String get _status => widget.order.status?.toString() ?? 'Unknown';

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AdminDashboardTheme.getStatusColor(_status);
    final statusBgColor = AdminDashboardTheme.getStatusBackgroundColor(_status);
    final statusIcon = AdminDashboardTheme.getStatusIcon(_status);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration:
              _isHovered
                  ? AdminDashboardTheme.cardHoverDecoration
                  : AdminDashboardTheme.cardDecoration,
          child: IntrinsicWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDashboardTheme.spacingLg,
                vertical: AdminDashboardTheme.spacingMd,
              ),
              child: Row(
                children: [
                  // Order ID Column
                  _buildColumn(
                    label: 'Order ID',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          size: 14,
                          color: AdminDashboardTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#$_orderId',
                          style: AdminDashboardTheme.headingSmall.copyWith(
                            color: AdminDashboardTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),

                  // Customer Name Column
                  _buildColumn(
                    label: 'Customer',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AdminDashboardTheme.accentLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _customerName.isNotEmpty
                                  ? _customerName[0].toUpperCase()
                                  : '?',
                              style: AdminDashboardTheme.labelMedium.copyWith(
                                color: AdminDashboardTheme.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _customerName,
                          style: AdminDashboardTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),

                  // Shop Column
                  _buildColumn(
                    label: 'Shop',
                    child: Text(
                      _shopName,
                      style: AdminDashboardTheme.bodyLarge,
                    ),
                  ),
                  _buildDivider(),

                  // Order Total Column
                  _buildColumn(
                    label: 'Total',
                    child: Text(
                      _orderTotal,
                      style: AdminDashboardTheme.headingSmall.copyWith(
                        color: AdminDashboardTheme.success,
                      ),
                    ),
                  ),
                  _buildDivider(),

                  // Status Column
                  _buildColumn(
                    label: 'Status',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminDashboardTheme.spacingSm,
                        vertical: AdminDashboardTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(
                          AdminDashboardTheme.radiusSm,
                        ),
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
                  const SizedBox(width: AdminDashboardTheme.spacingLg),

                  // Actions Button
                  _buildActionsButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn({required String label, required Widget child}) {
    return SizedBox(
      width: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AdminDashboardTheme.bodySmall),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: AdminDashboardTheme.spacingMd,
      ),
      color: AdminDashboardTheme.border,
    );
  }

  Widget _buildActionsButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showActionsMenu(context),
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AdminDashboardTheme.spacingSm),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            color: AdminDashboardTheme.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
            decoration: BoxDecoration(
              color: AdminDashboardTheme.surface,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusLg),
              boxShadow: AdminDashboardTheme.shadowLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AdminDashboardTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AdminDashboardTheme.spacingLg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminDashboardTheme.spacingLg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminDashboardTheme.primaryLight,
                          borderRadius: BorderRadius.circular(
                            AdminDashboardTheme.radiusSm,
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AdminDashboardTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #$_orderId',
                            style: AdminDashboardTheme.headingSmall,
                          ),
                          Text(
                            _customerName,
                            style: AdminDashboardTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _ActionMenuItem(
                  icon: Icons.visibility_rounded,
                  iconColor: AdminDashboardTheme.info,
                  label: 'View Order Details',
                  onTap: () {
                    Navigator.pop(context);
                    widget.controller.fetchOrderItems(
                      widget.order.id.toString(),
                    );
                    Future.microtask(
                      () => widget.controller.setSelectedOrder(widget.order),
                    );
                    Get.toNamed(Routes.ORDERS_DASHBOARD);
                  },
                ),
                const SizedBox(height: AdminDashboardTheme.spacingLg),
              ],
            ),
          ),
    );
  }
}

/// Action Menu Item
class _ActionMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionMenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDashboardTheme.spacingLg,
            vertical: AdminDashboardTheme.spacingMd,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AdminDashboardTheme.radiusSm,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: AdminDashboardTheme.bodyLarge),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AdminDashboardTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer Loading for Orders List
class _OrdersShimmerList extends StatelessWidget {
  const _OrdersShimmerList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AdminDashboardTheme.surfaceSecondary,
      highlightColor: AdminDashboardTheme.surface,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(
              bottom: AdminDashboardTheme.spacingSm,
            ),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AdminDashboardTheme.surface,
                borderRadius: BorderRadius.circular(
                  AdminDashboardTheme.radiusMd,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty Orders State
class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminDashboardTheme.spacing2Xl),
      decoration: AdminDashboardTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
            decoration: const BoxDecoration(
              color: AdminDashboardTheme.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AdminDashboardTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AdminDashboardTheme.spacingLg),
          const Text('No Orders Yet', style: AdminDashboardTheme.headingMedium),
          const SizedBox(height: AdminDashboardTheme.spacingSm),
          const Text(
            'Orders will appear here once customers start placing them.',
            style: AdminDashboardTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Orders Pagination
class _OrdersPagination extends StatelessWidget {
  final AdminDashboardService orderService;

  const _OrdersPagination({required this.orderService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPage = orderService.currentPage.value;
      final totalPages = orderService.totalPages.value;
      final visiblePages = orderService.visiblePageNumbers();

      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: AdminDashboardTheme.spacingMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            _PaginationButton(
              icon: Icons.chevron_left_rounded,
              onTap: currentPage > 1 ? orderService.previousPage : null,
              isEnabled: currentPage > 1,
            ),
            const SizedBox(width: AdminDashboardTheme.spacingSm),

            // Page Numbers
            ...visiblePages.map(
              (page) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _PageButton(
                  page: page,
                  isSelected: page == currentPage,
                  onTap: () async {
                    await orderService.goToPage(page);
                    orderService.fetchOrders(loaderType: false);
                  },
                ),
              ),
            ),
            const SizedBox(width: AdminDashboardTheme.spacingSm),

            // Next Button
            _PaginationButton(
              icon: Icons.chevron_right_rounded,
              onTap: currentPage < totalPages ? orderService.nextPage : null,
              isEnabled: currentPage < totalPages,
            ),
          ],
        ),
      );
    });
  }
}

/// Pagination Arrow Button
class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _PaginationButton({
    required this.icon,
    this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                isEnabled
                    ? AdminDashboardTheme.surfaceSecondary
                    : AdminDashboardTheme.surfaceSecondary.withValues(
                      alpha: 0.5,
                    ),
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            border: Border.all(color: AdminDashboardTheme.border),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isEnabled
                    ? AdminDashboardTheme.textPrimary
                    : AdminDashboardTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Page Number Button
class _PageButton extends StatelessWidget {
  final int page;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageButton({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AdminDashboardTheme.primary
                    : AdminDashboardTheme.surface,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            border: Border.all(
              color:
                  isSelected
                      ? AdminDashboardTheme.primary
                      : AdminDashboardTheme.border,
            ),
            boxShadow:
                isSelected
                    ? AdminDashboardTheme.shadowColored(
                      AdminDashboardTheme.primary,
                    )
                    : null,
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected
                        ? AdminDashboardTheme.textOnPrimary
                        : AdminDashboardTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
