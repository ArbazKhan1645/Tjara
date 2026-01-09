import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  static AdminDashboardController get instance => Get.find<AdminDashboardController>();

  DateTime? lastPressed;

  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void changeIndex(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
    update();
  }

}