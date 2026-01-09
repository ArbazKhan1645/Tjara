import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/auction_admin/controllers/auction_admin_controller.dart';
import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';

class AuctionAdminView extends StatefulWidget {
  const AuctionAdminView({super.key});

  @override
  State<AuctionAdminView> createState() => _AuctionAdminViewState();
}

class _AuctionAdminViewState extends State<AuctionAdminView> {
  late AdminAuctionService _adminProductsService;
  late OrdersDashboardController controller;

  @override
  void initState() {
    super.initState();

    _adminProductsService = Get.find<AdminAuctionService>();
    _adminProductsService.fetchProducts(refresh: true, showLoader: true);

  }

  @override
  Widget build(BuildContext context) {
    const Widget currentView = AdminAuctionPage();

    return Scaffold(backgroundColor: Colors.grey.shade100, body: currentView);
  }
}
