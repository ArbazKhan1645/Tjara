import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();

  void changeIndex(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
}
