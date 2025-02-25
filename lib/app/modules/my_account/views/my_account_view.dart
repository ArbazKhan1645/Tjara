import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tjara/app/modules/my_account/widgets/useraccount.dart';

import '../controllers/my_account_controller.dart';

class MyAccountView extends GetView<MyAccountController> {
  const MyAccountView({super.key});
  @override
  Widget build(BuildContext context) {
    return OrdersScreen();
  }
}
