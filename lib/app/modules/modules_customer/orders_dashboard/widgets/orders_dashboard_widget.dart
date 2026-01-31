// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/overlay.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/modules_customer/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/chats.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_details.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_dispute.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/overview.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;
  int _selectedIndex = 0;
  late OrdersDashboardController controller;
  late OrderService _orderService;

  void changeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const LinearGradient _expandedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97316), Color(0xFFF97316)],
  );

  static const LinearGradient _collapsedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF97316), Color(0xFFFACC15)],
  );

  static const LinearGradient _expandedStackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97316), Color(0xFFFACC15)],
  );

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _orderService = Get.find<OrderService>();
    _orderService.fetchOrders();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final double currentScroll = _scrollController.offset;
      final bool shouldBeExpanded = currentScroll < 30;
      if (_isAppBarExpanded != shouldBeExpanded) {
        setState(() {
          _isAppBarExpanded = shouldBeExpanded;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_selectedIndex) {
      case 0:
        currentView = _buildAnalyticsView();
        break;
      case 1:
        currentView = MyAccountView(
          ad: () {
            changeIndex(0);
          },
        );
        break;
      case 2:
        currentView = const ChatsScreenView();
        break;
      default:
        currentView = Container();
    }

    return Scaffold(
      drawer:
          controller.selectedOrder.value != null ? null : const CustomDrawer(),
      backgroundColor: Colors.grey.shade100,
      body: currentView,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          controller.selectedOrder.value != null
              ? null
              : _buildBottomNavigationBar(),
    );
  }

  Widget _buildAnalyticsView() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          iconTheme: const IconThemeData(color: Colors.white),
          expandedHeight: 80,
          backgroundColor: const Color(0xFFF97316),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient:
                    _isAppBarExpanded ? _expandedGradient : _collapsedGradient,
              ),
            ),
            collapseMode: CollapseMode.parallax,
          ),
          title: const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [const AdminAppBarActions()],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: !_isAppBarExpanded ? null : _expandedStackGradient,
                ),
                height: MediaQuery.of(context).size.height / 2.7,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Obx(
                  () =>
                      controller.selectedOrder.value == null
                          ? const OrdersOverview()
                          : controller.isShowndisputescreen.value == true
                          ? const OrdersDisputeOverview()
                          : const OrdersDetailOverview(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.web, color: Colors.white),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.fullscreen, color: Colors.white),
        onPressed: () {},
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 10),
      const OverlayMenu(child: CircleAvatar()),
      const SizedBox(width: 20),
    ];
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.shopping_bag_outlined, "Orders", 1),
            _buildNavItem(Icons.chat_bubble_outline, "Chats", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.pink : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.pink : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

List<FlSpot> _getPendingOrdersData() {
  return [
    const FlSpot(0, 4),
    const FlSpot(1, 3.5),
    const FlSpot(2, 4.5),
    const FlSpot(3, 4),
    const FlSpot(4, 5),
    const FlSpot(5, 4.2),
    const FlSpot(6, 5.8),
    const FlSpot(7, 5.2),
    const FlSpot(8, 6.2),
    const FlSpot(9, 5.8),
    const FlSpot(10, 6.5),
  ];
}

List<FlSpot> _getProcessingOrdersData() {
  return [
    const FlSpot(0, 1),
    const FlSpot(1, 1.5),
    const FlSpot(2, 2),
    const FlSpot(3, 1.8),
    const FlSpot(4, 2.5),
    const FlSpot(5, 3),
    const FlSpot(6, 3.5),
    const FlSpot(7, 4.2),
    const FlSpot(8, 4.8),
    const FlSpot(9, 5.5),
    const FlSpot(10, 3),
  ];
}

class StatisticsCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  final bool isIncreasing;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,

    required this.isIncreasing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 30,
            bottom: -10,
            left: 30,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), // Shadow color
                    blurRadius: 1, // Softness of shadow
                    spreadRadius: 1, // How much the shadow expands
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const SizedBox(height: 100, width: double.infinity),
            ),
          ),
          Container(
            height: 130,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Shadow color
                  blurRadius: 1, // Softness of shadow
                  spreadRadius: 1, // How much the shadow expands
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          title.contains('Pending')
                              ? Icons.storage
                              : Icons.sync,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$count $title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 24),
                  // SizedBox(
                  //   height: 100,
                  //   child: LineChart(
                  //     LineChartData(
                  //       gridData: FlGridData(
                  //         show: true,
                  //         drawVerticalLine: true,
                  //         horizontalInterval: 2,
                  //         verticalInterval: 2,
                  //         getDrawingHorizontalLine: (value) {
                  //           return FlLine(
                  //             color: Colors.grey.withOpacity(0.2),
                  //             strokeWidth: 1,
                  //             dashArray: [5, 5],
                  //           );
                  //         },
                  //         getDrawingVerticalLine: (value) {
                  //           return FlLine(
                  //             color: Colors.transparent,
                  //             strokeWidth: 0,
                  //           );
                  //         },
                  //       ),
                  //       titlesData: FlTitlesData(show: false),
                  //       borderData: FlBorderData(show: false),
                  //       minX: 0,
                  //       maxX: 10,
                  //       minY: 0,
                  //       maxY: 8,
                  //       lineBarsData: [
                  //         LineChartBarData(
                  //           spots: data,
                  //           isCurved: true,
                  //           color: color,
                  //           barWidth: 2,
                  //           isStrokeCapRound: true,
                  //           dotData: FlDotData(show: false),
                  //           belowBarData: BarAreaData(
                  //             show: true,
                  //             gradient: LinearGradient(
                  //               colors: [
                  //                 color.withOpacity(0.5),
                  //                 color.withOpacity(0.05),
                  //               ],
                  //               begin: Alignment.topCenter,
                  //               end: Alignment.bottomCenter,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/icons/logo.png', height: 100),
          ),
          CustomExpandableTile(
            leading: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.red,
            ),
            title: 'Orders',
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.list, color: Colors.red),
                    title: const Text('Placed Orders'),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomExpandableTile(
            leading: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.red,
            ),
            title: 'Orders',
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.list, color: Colors.red),
                    title: const Text('Placed Orders'),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.work_outline, color: Colors.red),
            title: const Text('My Job Applications'),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.event_outlined, color: Colors.red),
            title: const Text('My Participations'),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.red,
            ),
            title: const Text('My Bids'),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.chat_outlined, color: Colors.red),
            title: const Text('Product Inquiry Chats'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class CustomExpandableTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final List<Widget> children;

  const CustomExpandableTile({
    super.key,
    required this.leading,
    required this.title,
    required this.children,
  });

  @override
  _CustomExpandableTileState createState() => _CustomExpandableTileState();
}

class _CustomExpandableTileState extends State<CustomExpandableTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration:
                !_isExpanded
                    ? null
                    : BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(4),
                    ),
            child: Row(
              children: [
                widget.leading,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) Column(children: widget.children),
      ],
    );
  }
}
