import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/my_cart_controller.dart';

class MyCartView extends GetView<MyCartController> {
  const MyCartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyCartView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MyCartView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
