import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/routes/app_pages.dart';

class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              "Your order is successfully placed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: 10),
            // Text(
            //   "Pellentesque sed lectus nec tortor tristique accumsan quis dictum risus. Donec volutpat mollis nulla non facilisis.",
            //   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  Get.until((route) => route.isFirst);
                  Get.toNamed(Routes.DASHBOARD_ADMIN);
                },
                child: const Text(
                  "GO TO DASHBOARD",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
