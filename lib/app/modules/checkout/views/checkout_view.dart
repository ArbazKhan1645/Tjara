import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:tjara/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:tjara/app/modules/checkout/pages/form.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      init: CheckoutController(),
      builder: (controller) {
        return const CheckoutViewBody();
      },
    );
  }
}

class CheckoutViewBody extends StatelessWidget {
  const CheckoutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const FormScreen();
  }
}
