import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showTopLoaderDialog() {
  Get.dialog(
    Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [const BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    ),
    barrierDismissible: false, // User cannot close by tapping outside
  );
}
