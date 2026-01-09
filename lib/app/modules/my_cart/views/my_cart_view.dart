import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tjara/app/modules/home/widgets/shopping_cart.dart';

import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';

class MyCartView extends GetView<MyCartController> {
  const MyCartView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyCartController>(
        init: MyCartController(),
        builder: (controller) {
          return const ShoppingCartScreen();
        });
  }
}
