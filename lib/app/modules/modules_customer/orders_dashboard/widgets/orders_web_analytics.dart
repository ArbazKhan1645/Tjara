import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/orders_analytics.dart';

/// Elegant theme constants for Orders Analytics
class _AnalyticsTheme {
  _AnalyticsTheme._();

  // Primary Colors
  static const Color primary = Color(0xFFfda730);
  static const Color primaryLight = Color(0xFFFFF7ED);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);

  // Neutral Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Spacing
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 8.0;
  static const double spacingXl = 20.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusXl = 24.0;

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

class OrdersWebAnalyticsPage extends StatefulWidget {
  const OrdersWebAnalyticsPage({
    super.key,
    required this.userid,
    required this.usernumber,
  });

  final String userid;
  final String usernumber;

  @override
  State<OrdersWebAnalyticsPage> createState() => _OrdersWebAnalyticsPageState();
}

class _OrdersWebAnalyticsPageState extends State<OrdersWebAnalyticsPage>
    with SingleTickerProviderStateMixin {
  Future<OrderAnalyticsModel>? _analyticsData;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _analyticsData = fetchAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<OrderAnalyticsModel> fetchAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/orders/analytics?ordersType=received-orders&dateFilter=all&search=&searchByBuyerName=${widget.userid}&searchByPhoneNumber=&filterByMetaFields[filterJoin]=AND&filterByMetaFields[fields][0][key]=is_testing&filterByMetaFields[fields][0][value]=1&filterByMetaFields[fields][0][operator]=IS_EMPTY&filterByMetaFields[fields][1][key]=is_soft_deleted&filterByMetaFields[fields][1][value]=1&filterByMetaFields[fields][1][operator]=IS_EMPTY',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _animationController.forward();
        return OrderAnalyticsModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  void _refreshData() {
    _animationController.reset();
    setState(() {
      _analyticsData = fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderAnalyticsModel>(
      future: _analyticsData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (snapshot.hasData && snapshot.data?.analytics != null) {
          return _buildAnalyticsCards(snapshot.data!.analytics!);
        } else {
          return _buildNoDataWidget();
        }
      },
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_AnalyticsTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          _buildShimmerBox(width: 180, height: 28),
          const SizedBox(height: _AnalyticsTheme.spacingXl),

          // Summary cards shimmer
          Container(
            padding: const EdgeInsets.all(_AnalyticsTheme.spacingXl),
            decoration: BoxDecoration(
              color: _AnalyticsTheme.surface,
              borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusXl),
              boxShadow: _AnalyticsTheme.shadowSm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCardShimmer()),
                    const SizedBox(width: _AnalyticsTheme.spacingMd),
                    Expanded(child: _buildCardShimmer()),
                  ],
                ),
                const SizedBox(height: _AnalyticsTheme.spacingMd),
                Row(
                  children: [
                    Expanded(child: _buildCardShimmer()),
                    const SizedBox(width: _AnalyticsTheme.spacingMd),
                    Expanded(child: _buildCardShimmer()),
                  ],
                ),
                const SizedBox(height: _AnalyticsTheme.spacingXl),
                ...List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: _AnalyticsTheme.spacingMd,
                    ),
                    child: _buildStatusCardShimmer(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: _AnalyticsTheme.surfaceSecondary,
      highlightColor: _AnalyticsTheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _AnalyticsTheme.surface,
          borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: _AnalyticsTheme.surfaceSecondary,
      highlightColor: _AnalyticsTheme.surface,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: _AnalyticsTheme.surface,
          borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusMd),
        ),
      ),
    );
  }

  Widget _buildStatusCardShimmer() {
    return Shimmer.fromColors(
      baseColor: _AnalyticsTheme.surfaceSecondary,
      highlightColor: _AnalyticsTheme.surface,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: _AnalyticsTheme.surface,
          borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusMd),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards(Analytics analytics) {
    // Safe getters with defaults
    final totalOrders = analytics.totalOrders ?? 0;
    final completedOrders = analytics.totalCompletedOrders ?? 0;
    final totalValue = analytics.totalOrderValue ?? 0.0;
    final deliveryFees = analytics.totalDeliveryFees ?? 0;
    final pendingOrders = analytics.totalPendingOrders ?? 0;
    final pendingValue = analytics.pendingOrdersValue ?? 0.0;
    final processingOrders = analytics.totalProcessingOrders ?? 0;
    final processingValue = analytics.processingOrdersValue ?? 0.0;
    final shippingOrders = analytics.totalShippingOrders ?? 0;
    final shippingValue = analytics.shippingOrdersValue ?? 0.0;
    final completedValue = analytics.completedOrdersValue ?? 0.0;
    final cancelledOrders = analytics.totalCancelledOrders ?? 0;
    final cancelledValue = analytics.cancelledOrdersValue ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_AnalyticsTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: _AnalyticsTheme.spacingXl),

          // Main Card
          Container(
            decoration: BoxDecoration(
              color: _AnalyticsTheme.surface,
              borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusXl),
              boxShadow: _AnalyticsTheme.shadowMd,
            ),
            child: Padding(
              padding: const EdgeInsets.all(_AnalyticsTheme.spacingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section Title
                  _buildSectionTitle('Overview', Icons.analytics_outlined),
                  const SizedBox(height: _AnalyticsTheme.spacingLg),

                  // Summary Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Orders',
                          value: totalOrders.toString(),
                          icon: Icons.shopping_bag_outlined,
                          color: _AnalyticsTheme.info,
                          lightColor: _AnalyticsTheme.infoLight,
                        ),
                      ),
                      const SizedBox(width: _AnalyticsTheme.spacingMd),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Completed',
                          value: completedOrders.toString(),
                          icon: Icons.check_circle_outline,
                          color: _AnalyticsTheme.success,
                          lightColor: _AnalyticsTheme.successLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _AnalyticsTheme.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Sales',
                          value: '\$${totalValue.toStringAsFixed(2)}',
                          icon: Icons.payments_outlined,
                          color: _AnalyticsTheme.primary,
                          lightColor: _AnalyticsTheme.primaryLight,
                        ),
                      ),
                      const SizedBox(width: _AnalyticsTheme.spacingMd),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Delivery Fees',
                          value: '\$$deliveryFees',
                          icon: Icons.local_shipping_outlined,
                          color: _AnalyticsTheme.purple,
                          lightColor: _AnalyticsTheme.purpleLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: _AnalyticsTheme.spacingXl),

                  // Order Status Section
                  _buildSectionTitle(
                    'Order Status',
                    Icons.pending_actions_outlined,
                  ),
                  const SizedBox(height: _AnalyticsTheme.spacingLg),

                  // Status Cards
                  _buildStatusCard(
                    status: 'Pending',
                    count: pendingOrders,
                    value: pendingValue,
                    icon: Icons.schedule_outlined,
                    color: _AnalyticsTheme.warning,
                    lightColor: _AnalyticsTheme.warningLight,
                  ),
                  _buildStatusCard(
                    status: 'Processing',
                    count: processingOrders,
                    value: processingValue,
                    icon: Icons.sync_outlined,
                    color: _AnalyticsTheme.info,
                    lightColor: _AnalyticsTheme.infoLight,
                  ),
                  _buildStatusCard(
                    status: 'Shipping',
                    count: shippingOrders,
                    value: shippingValue,
                    icon: Icons.local_shipping_outlined,
                    color: _AnalyticsTheme.purple,
                    lightColor: _AnalyticsTheme.purpleLight,
                  ),
                  _buildStatusCard(
                    status: 'Completed',
                    count: completedOrders,
                    value: completedValue,
                    icon: Icons.check_circle_outline,
                    color: _AnalyticsTheme.success,
                    lightColor: _AnalyticsTheme.successLight,
                  ),
                  _buildStatusCard(
                    status: 'Cancelled',
                    count: cancelledOrders,
                    value: cancelledValue,
                    icon: Icons.cancel_outlined,
                    color: _AnalyticsTheme.error,
                    lightColor: _AnalyticsTheme.errorLight,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders Analytics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Track your order performance',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _refreshData,
            borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _AnalyticsTheme.primaryLight,
            borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
          ),
          child: Icon(icon, size: 18, color: _AnalyticsTheme.primary),
        ),
        const SizedBox(width: _AnalyticsTheme.spacingMd),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _AnalyticsTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(_AnalyticsTheme.spacingLg),
      decoration: BoxDecoration(
        color: _AnalyticsTheme.surface,
        borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusMd),
        border: Border.all(color: _AnalyticsTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: _AnalyticsTheme.spacingMd),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _AnalyticsTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String status,
    required int count,
    required double value,
    required IconData icon,
    required Color color,
    required Color lightColor,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : _AnalyticsTheme.spacingMd),
      padding: const EdgeInsets.all(_AnalyticsTheme.spacingLg),
      decoration: BoxDecoration(
        color: lightColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: _AnalyticsTheme.spacingLg),

          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'order' : 'orders'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _AnalyticsTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Value
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _AnalyticsTheme.spacingMd,
              vertical: _AnalyticsTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: _AnalyticsTheme.surface,
              borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusSm),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              '\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_AnalyticsTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_AnalyticsTheme.spacingXl),
              decoration: const BoxDecoration(
                color: _AnalyticsTheme.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: _AnalyticsTheme.error,
              ),
            ),
            const SizedBox(height: _AnalyticsTheme.spacingXl),
            const Text(
              'Error loading analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _AnalyticsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: _AnalyticsTheme.spacingSm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _AnalyticsTheme.textSecondary,
              ),
            ),
            const SizedBox(height: _AnalyticsTheme.spacingXl),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AnalyticsTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: _AnalyticsTheme.spacingXl,
                  vertical: _AnalyticsTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_AnalyticsTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_AnalyticsTheme.spacingXl),
              decoration: const BoxDecoration(
                color: _AnalyticsTheme.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 48,
                color: _AnalyticsTheme.textTertiary,
              ),
            ),
            const SizedBox(height: _AnalyticsTheme.spacingXl),
            const Text(
              'No analytics data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _AnalyticsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: _AnalyticsTheme.spacingSm),
            const Text(
              'Check back later for order insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _AnalyticsTheme.textSecondary,
              ),
            ),
            const SizedBox(height: _AnalyticsTheme.spacingXl),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AnalyticsTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: _AnalyticsTheme.spacingXl,
                  vertical: _AnalyticsTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_AnalyticsTheme.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
