import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';

class ProductDetailsEditorWidget extends StatelessWidget {
  final TextEditingController controller;

  const ProductDetailsEditorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.lightGreyBorderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      height: 200,
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Write Product Detail',
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
