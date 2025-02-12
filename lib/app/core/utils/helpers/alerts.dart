// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';

showmessageofalert(BuildContext context, String text) {
  Get.snackbar(' Message', text, snackPosition: SnackPosition.BOTTOM);
}
