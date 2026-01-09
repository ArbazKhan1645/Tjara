import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_bottom_navigation_bar.dart';
import 'package:tjara/app/core/widgets/admin_drawer_widget.dart';
import 'package:tjara/app/modules/admin/cars_admin/widgets/cars_view_widget.dart';
import 'package:tjara/app/modules/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/modules/orders_dashboard/widgets/chats.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';


class CarsAdminView extends StatefulWidget {
  const CarsAdminView({super.key});

  @override
  State<CarsAdminView> createState() => _CarsAdminViewState();
}

class _CarsAdminViewState extends State<CarsAdminView> {
  int _selectedIndex = 0;
  final bool _isAppBarExpanded = true;
  late AdminCarsService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminProductsService = Get.find<AdminCarsService>();
    _adminProductsService.fetchProducts(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_selectedIndex) {
      case 0:
        currentView = CarsViewWidget(
            isAppBarExpanded: _isAppBarExpanded,
            adminProductsService: _adminProductsService);
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
            }));
  }
}
