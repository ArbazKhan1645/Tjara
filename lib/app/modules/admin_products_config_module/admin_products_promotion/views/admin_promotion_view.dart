import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/controller/admin_promotion_controller.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/views/widgets/promotion_list_widget.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/views/widgets/apply_promotion_widget.dart';

class AdminPromotionView extends StatefulWidget {
  const AdminPromotionView({super.key});

  @override
  State<AdminPromotionView> createState() => _AdminPromotionViewState();
}

class _AdminPromotionViewState extends State<AdminPromotionView>
    with SingleTickerProviderStateMixin {
  static const Color primaryTeal = Color(0xFF009688);

  late TabController _tabController;
  late AdminPromotionController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller = Get.put(AdminPromotionController());
    controller.setTabController(_tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Promotions',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All Promotions'),
            Tab(text: 'Apply Promotion'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PromotionListWidget(controller: controller),
          ApplyPromotionWidget(controller: controller),
        ],
      ),
    );
  }
}
