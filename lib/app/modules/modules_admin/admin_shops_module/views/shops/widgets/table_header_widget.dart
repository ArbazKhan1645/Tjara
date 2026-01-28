import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/const/appColors.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Colors.red),
        height: 50,
        child: Center(
          child: Text(
            textAlign: TextAlign.left,
            text,
            style: TextStyle(
              color: appcolors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
