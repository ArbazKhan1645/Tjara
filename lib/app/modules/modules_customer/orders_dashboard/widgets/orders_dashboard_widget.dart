// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_drawer_widget.dart';
import 'package:tjara/app/modules/modules_admin/dashboard_admin/widgets/admin_dashboard_overview_widget.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/modules_customer/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/chats.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_details.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/order_dispute.dart';

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
    colors: [Colors.teal, Colors.teal],
  );

  static const LinearGradient _collapsedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.teal, Colors.teal],
  );

  static const LinearGradient _expandedStackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.teal, Colors.teal],
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
          controller.selectedOrder.value != null
              ? null
              : const AdminDrawerWidget(),
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
          backgroundColor: Colors.teal,
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
