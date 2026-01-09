import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/admin_jobs/view/jobs_view_widget.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/dashbopard_services/adminJobs_service.dart';

class AdminJobsView extends StatefulWidget {
  const AdminJobsView({super.key});

  @override
  State<AdminJobsView> createState() => _AdminJobsViewState();
}

class _AdminJobsViewState extends State<AdminJobsView> {
  final bool _isAppBarExpanded = true;
  late AdminJobsService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminProductsService = Get.find<AdminJobsService>();
    _adminProductsService.fetchProducts(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: JobsViewWidget(
        isAppBarExpanded: _isAppBarExpanded,
        adminProductsService: _adminProductsService,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
