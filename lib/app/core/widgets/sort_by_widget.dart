import 'package:flutter/material.dart';

class SortByWidget extends StatelessWidget {
  const SortByWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: 200,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: Colors.grey)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sorted By: Columns", style: TextStyle()),
            Icon(Icons.keyboard_arrow_down)
          ],
        ));
  }
}