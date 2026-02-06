// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_bottom_navigation_bar.dart';
import 'package:tjara/app/core/widgets/admin_drawer_widget.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/dashboard_admin/widgets/admin_dashboard_overview_widget.dart';
import 'package:tjara/app/modules/modules_customer/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/chats.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_details.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_dispute.dart';
import 'package:tjara/app/services/dashbopard_services/admin_dashboard_service.dart';

class DashboardAdminView extends StatefulWidget {
  const DashboardAdminView({super.key});

  @override
  _DashboardAdminViewState createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  final ScrollController _scrollController = ScrollController();
  bool isAppBarExpanded = true;
  int _selectedIndex = 0;
  late OrdersDashboardController controller;
  late AdminDashboardService _dashboardService;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _dashboardService = Get.find<AdminDashboardService>();
    _dashboardService.fetchOrders(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_selectedIndex) {
      case 0:
        currentView = _buildAnalyticsView(isAppBarExpanded: isAppBarExpanded);
        break;
      case 1:
        currentView = const MyAccountView();
        break;
      case 2:
        currentView = const ChatsScreenView();
        break;
      default:
        currentView = Container();
    }

    return Scaffold(
      // drawer: const CustomDrawer(),
      drawer: const AdminDrawerWidget(),
      backgroundColor: Colors.grey.shade100,
      body: currentView,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AdminBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int value) {
          _selectedIndex = value;
          setState(() {});
        },
      ),
    );
  }

  Widget _buildAnalyticsView({required bool isAppBarExpanded}) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        AdminSliverAppBarWidget(
          title: 'Dashboard',
          isAppBarExpanded: isAppBarExpanded,
          actions: const [AdminAppBarActions()],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AdminHeaderAnimatedBackgroundWidget(
                isAppBarExpanded: isAppBarExpanded,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Obx(
                  () =>
                      controller.selectedOrder.value == null
                          ? const AdminDashboardOverviewWidget()
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
}

class StatisticsCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final List<FlSpot> data;
  final bool isIncreasing;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.data,
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
            height: 260,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 100,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 2,
                          verticalInterval: 2,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: Colors.transparent,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 10,
                        minY: 0,
                        maxY: 8,
                        lineBarsData: [
                          LineChartBarData(
                            spots: data,
                            isCurved: true,
                            color: color,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.5),
                                  color.withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
