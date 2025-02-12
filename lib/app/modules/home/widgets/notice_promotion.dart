import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class SafePaymentButton extends StatelessWidget {
  const SafePaymentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          height: 43,
          decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(9)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10),
              Image.asset(AppAssets.secure),
              SizedBox(width: 10),
              Text("Safe Payment",
                  style: defaultTextStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
