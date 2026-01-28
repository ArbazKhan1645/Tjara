import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_bottom_navigation_bar.dart';
import 'package:tjara/app/core/widgets/admin_drawer_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/shops_admin/view/stories_view_widget.dart';
import 'package:tjara/app/modules/modules_customer/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/widgets/chats.dart';

import 'package:tjara/app/services/dashbopard_services/shops_service.dart';

class AdminShopsView extends StatefulWidget {
  const AdminShopsView({super.key});

  @override
  State<AdminShopsView> createState() => _AdminShopsViewState();
}

class _AdminShopsViewState extends State<AdminShopsView> {
  int _selectedIndex = 0;
  final bool _isAppBarExpanded = true;
  late AdminShopsService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminProductsService = Get.find<AdminShopsService>();
    _adminProductsService.fetchProducts(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_selectedIndex) {
      case 0:
        currentView = ShopsViewWidget(
          isAppBarExpanded: _isAppBarExpanded,
          adminProductsService: _adminProductsService,
        );
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
}
