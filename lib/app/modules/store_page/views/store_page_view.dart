import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/appbar.dart';
import '../../../core/widgets/base.dart';
import '../controllers/store_page_controller.dart';
import '../pages/section.dart';

class StorePageView extends GetView<StorePageController> {
  const StorePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StorePageController>(
        init: StorePageController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar(),
              body: StorePageViewBody());
        });
  }
}

class StorePageViewBody extends StatelessWidget {
  const StorePageViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonBaseBodyScreen(screens: [
      StorePageSectionForm(),
      SizedBox(height: 150),
    ]);
  }
}
