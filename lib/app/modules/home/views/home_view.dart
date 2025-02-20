import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/appbar.dart';
import '../controllers/home_controller.dart';
import '../pages/homeview_body.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return SafeArea(
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: CustomAppBar(),
                body: controller.selectedCategory != null
                    ? CategoryViewBody(
                        scrollController: controller.scrollController)
                    : HomeViewBody(
                        scrollController: controller.scrollController)),
          );
        });
  }
}
