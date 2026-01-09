// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const GlobalErrorWidget({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 80, color: Colors.redAccent),
          const SizedBox(height: 20),
          const Text(
            "An unexpected error occurred.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Error: ${errorDetails.exception}",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
