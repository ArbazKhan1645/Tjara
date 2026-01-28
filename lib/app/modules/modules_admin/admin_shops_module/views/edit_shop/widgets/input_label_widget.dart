import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/const/appColors.dart';

class Inputlabel extends StatelessWidget {
  final String label;
  final String helperText;
  final bool isRequired;

  const Inputlabel({
    super.key,
    required this.label,
    required this.helperText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: appcolors.grey,
              ),
            ),
            if (isRequired)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          helperText,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }
}
