import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/orders_analytics.dart';

// Your existing models (OrderAnalyticsModel, Analytics, FiltersApplied)
// ... (include the models from your paste.txt here)

class OrdersWebAnalyticsPage extends StatefulWidget {
  const OrdersWebAnalyticsPage({
    super.key,
    required this.userid,
    required this.usernumber,
  });
  final String userid;
  final String usernumber;

  @override
  _OrdersWebAnalyticsPageState createState() => _OrdersWebAnalyticsPageState();
}

class _OrdersWebAnalyticsPageState extends State<OrdersWebAnalyticsPage> {
  Future<OrderAnalyticsModel>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _analyticsData = fetchAnalytics();
  }

  Future<OrderAnalyticsModel> fetchAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/orders/analytics?ordersType=placed-orders&dateFilter=all&search=&searchByBuyerName=${widget.userid}&searchByPhoneNumber=',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
          // Add your authentication headers here if needed
          // 'Authorization': 'Bearer your_token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return OrderAnalyticsModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  void _refreshData() {
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
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          // Top summary cards shimmer
          Row(
            children: [
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
            ],
          ),
          const SizedBox(height: 24),
          // Order status cards shimmer
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildShimmerCard(height: 80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({double height = 100}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards(Analytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary Cards
          const Text(
            'Orders Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Orders',
                          '${analytics.totalOrders ?? 0}',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Completed \nOrders',
                          '${analytics.totalCompletedOrders ?? 0}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Sales \nValue',
                          '\$${analytics.totalOrderValue?.toStringAsFixed(2) ?? '0.00'}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Delivery Fees',
                          '\$${analytics.totalDeliveryFees ?? 0}',
                          Icons.local_shipping,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Order Status Cards
                  _buildOrderStatusCard(
                    'Pending',
                    analytics.totalPendingOrders ?? 0,
                    (analytics.pendingOrdersValue ?? 0).toStringAsFixed(2),

                    Colors.orange[100]!,
                    Colors.orange,
                  ),

                  _buildOrderStatusCard(
                    'Processing',
                    analytics.totalProcessingOrders ?? 0,
                    (analytics.processingOrdersValue ?? 0.00).toStringAsFixed(
                      2,
                    ),

                    Colors.blue[100]!,
                    Colors.blue,
                  ),

                  _buildOrderStatusCard(
                    'Shipping',
                    analytics.totalShippingOrders ?? 0,
                    '\$${analytics.shippingOrdersValue?.toStringAsFixed(2) ?? '0.00'}',
                    Colors.purple[100]!,
                    Colors.purple,
                  ),

                  _buildOrderStatusCard(
                    'Completed',
                    analytics.totalCompletedOrders ?? 0,
                    '\$${analytics.completedOrdersValue?.toStringAsFixed(2) ?? '0.00'}',
                    Colors.green[100]!,
                    Colors.green,
                  ),

                  _buildOrderStatusCard(
                    'Cancelled',
                    analytics.totalCancelledOrders ?? 0,
                    '\$${analytics.cancelledOrdersValue?.toStringAsFixed(2) ?? '0.00'}',
                    Colors.red[100]!,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // SizedBox(height: 24),

          // // Payment Status Cards
          // Text(
          //   'Payment Analytics',
          //   style: TextStyle(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.grey[800],
          //   ),
          // ),
          // SizedBox(height: 16),

          // _buildPaymentCard(
          //   'Paid Orders',
          //   analytics.paidOrdersCount ?? 0,
          //   Icons.payment,
          //   Colors.green,
          // ),

          // _buildPaymentCard(
          //   'Pending Payments',
          //   analytics.pendingPaymentsCount ?? 0,
          //   Icons.pending,
          //   Colors.orange,
          // ),

          // _buildPaymentCard(
          //   'Failed Payments',
          //   analytics.failedPaymentsCount ?? 0,
          //   Icons.error,
          //   Colors.red,
          // ),

          // SizedBox(height: 24),

          // // Commission & Earnings
          // _buildCommissionCard(
          //   'Admin Commission',
          //   '\$${analytics.totalAdminCommission?.toStringAsFixed(2) ?? '0.00'}',
          //   Icons.admin_panel_settings,
          //   Colors.indigo,
          // ),

          // _buildCommissionCard(
          //   'Vendor Earnings',
          //   '\$${analytics.totalVendorEarnings?.toStringAsFixed(2) ?? '0.00'}',
          //   Icons.store,
          //   Colors.teal,
          // ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            maxLines: 2,

            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard(
    String status,
    int count,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count orders',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No analytics data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshData, child: const Text('Refresh')),
        ],
      ),
    );
  }
}

// Don't forget to add these dependencies to your pubspec.yaml:
/*
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shimmer: ^3.0.0
*/
