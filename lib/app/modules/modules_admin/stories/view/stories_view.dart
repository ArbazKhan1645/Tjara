import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/stories/view/stories_view_widget.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/dashbopard_services/stories_service.dart';

class AdminStoriesView extends StatefulWidget {
  const AdminStoriesView({super.key});

  @override
  State<AdminStoriesView> createState() => _AdminStoriesViewState();
}

class _AdminStoriesViewState extends State<AdminStoriesView> {
  final bool _isAppBarExpanded = true;
  late StoriesService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrdersDashboardController());
    _adminProductsService = Get.find<StoriesService>();
    _adminProductsService.fetchProducts(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: StoriesViewWidget(
        isAppBarExpanded: _isAppBarExpanded,
        adminProductsService: _adminProductsService,
      ),
    );
  }
}
