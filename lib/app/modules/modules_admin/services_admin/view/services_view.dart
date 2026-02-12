import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/services_admin/view/serices_view_widget.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/dashbopard_services/services_service.dart';

class AdminServiceView extends StatefulWidget {
  const AdminServiceView({super.key});

  @override
  State<AdminServiceView> createState() => _AdminServiceViewState();
}

class _AdminServiceViewState extends State<AdminServiceView> {
  final bool _isAppBarExpanded = true;
  late ServicesService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminProductsService = Get.find<ServicesService>();
    _adminProductsService.fetchProducts(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ServicesViewWidget(
        isAppBarExpanded: _isAppBarExpanded,
        adminProductsService: _adminProductsService,
      ),
    );
  }
}
