import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_contexts/view/contexts_view_widget.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

class AdminContestsView extends StatefulWidget {
  const AdminContestsView({super.key});

  @override
  State<AdminContestsView> createState() => _AdminContestsViewState();
}

class _AdminContestsViewState extends State<AdminContestsView> {
  final bool _isAppBarExpanded = true;
  late ContestsService _adminContestsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminContestsService = Get.find<ContestsService>();
    _adminContestsService.fetchContests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ContestsViewWidget(
        isAppBarExpanded: _isAppBarExpanded,
        contestsService: _adminContestsService,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
