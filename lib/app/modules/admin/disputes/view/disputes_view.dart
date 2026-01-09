import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/disputes/view/disputes_view_widget.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class AdminDisputesView extends StatefulWidget {
  const AdminDisputesView({super.key});

  @override
  State<AdminDisputesView> createState() => _AdminDisputesViewState();
}

class _AdminDisputesViewState extends State<AdminDisputesView> {
  final bool _isAppBarExpanded = true;
  late AdminDisputesService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminProductsService = Get.find<AdminDisputesService>();
    _adminProductsService.loadDisputes(userId: Get.arguments ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: DisputesViewWidget(
        isAppBarExpanded: _isAppBarExpanded,
        adminDisputesService: _adminProductsService,
      ),
   
    );
  }
}
