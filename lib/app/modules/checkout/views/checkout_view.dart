import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/widgets/appbar.dart';
import '../../../core/widgets/base.dart';
import '../controllers/checkout_controller.dart';
import '../pages/form.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
        init: CheckoutController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar(),
              body: CheckoutViewBody());
        });
  }
}

class CheckoutViewBody extends StatelessWidget {
  const CheckoutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonBaseBodyScreen(screens: [
      FormScreen(),
      SizedBox(height: 150),
    ]);
  }
}
