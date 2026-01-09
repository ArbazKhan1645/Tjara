import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tjara/app/modules/orders_dashboard/widgets/orders_dashboard_widget.dart';

import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';

class OrdersDashboardView extends GetView<OrdersDashboardController> {
  const OrdersDashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return const AnalyticsScreen();
  }
}
