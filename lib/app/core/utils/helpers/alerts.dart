import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showmessageofalert(String text) {
  if (Get.isSnackbarOpen) return;
  Get.snackbar('Message', text, snackPosition: SnackPosition.BOTTOM);
}

class NotificationHelper {
  static void showSuccess(
    BuildContext contexts,
    String title,
    String description,
  ) {
    final context = Get.context;
    if (context != null) {
      ElegantNotification.success(
        height: description.length > 60 ? 200 : null,
        title: Text(title),
        description: Text(description),
      ).show(context);
    }
  }

  static void showInfo(
    BuildContext contexts,
    String title,
    String description,
  ) {
    final context = Get.context;
    if (context != null) {
      ElegantNotification.info(
        title: Text(title),
        description: Text(description),
      ).show(context);
    }
  }

  static void showError(
    BuildContext contexts,
    String title,
    String description,
  ) {
    final context = Get.context;
    if (context != null) {
      ElegantNotification.error(
        height: description.length > 60 ? 130 : null,
        title: Text(title),
        description: Text(description),
      ).show(context);
    }
  }
}
