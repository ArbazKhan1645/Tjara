// ignore_for_file: avoid_web_libraries_in_flutter, unused_import

import 'package:flutter/material.dart';

import 'package:get/get.dart';
// ignore: deprecated_member_use
// import 'dart:html' if (dart.library.io) 'dart:io';

import 'package:tjara/app/modules/my_account/widgets/orders_screen.dart';

import 'package:tjara/app/modules/my_account/controllers/my_account_controller.dart';

class MyAccountView extends GetView<MyAccountController> {
  const MyAccountView({super.key, this.ad});
  final Function()? ad;
  @override
  Widget build(BuildContext context) {
    return const OrdersScreen();
  }
}
