import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repo/network_repository.dart';

class DashboardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<Widget> pages = [
    const Center(child: Text("Home", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Categories", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Account", style: TextStyle(fontSize: 20))),
    const Center(child: Text("My Cart", style: TextStyle(fontSize: 20))),
    const Center(child: Text("More", style: TextStyle(fontSize: 20))),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
