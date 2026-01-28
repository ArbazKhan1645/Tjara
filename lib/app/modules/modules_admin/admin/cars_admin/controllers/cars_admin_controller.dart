import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarsAdminController extends GetxController {
  static CarsAdminController get instance => Get.find<CarsAdminController>();

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