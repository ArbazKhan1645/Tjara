// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ContainerWithDottedBorderWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String redText;
  final String blackText;
  const ContainerWithDottedBorderWidget({
    super.key,
    required this.onTap,
    required this.redText,
    required this.blackText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, color: Colors.black, size: 20),
            const SizedBox(width: 12),
            Text(
              redText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
