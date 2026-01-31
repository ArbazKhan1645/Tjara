import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/base.dart';
import 'package:tjara/app/modules/modules_customer/store_page/controllers/store_page_controller.dart';
import 'package:tjara/app/modules/modules_customer/store_page/pages/section.dart';

class StorePageView extends GetView<StorePageController> {
  const StorePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StorePageController>(
      init: StorePageController(),
      builder: (controller) {
        return const Scaffold(
          backgroundColor: Colors.white,

          body: StorePageViewBody(),
        );
      },
    );
  }
}

class StorePageViewBody extends StatelessWidget {
  const StorePageViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.find<StorePageController>();
    return CommonBaseBodyScreen(
      scrollController: con.scrollController,
      screens: [const StorePageSectionForm(), const SizedBox(height: 150)],
    );
  }
}
