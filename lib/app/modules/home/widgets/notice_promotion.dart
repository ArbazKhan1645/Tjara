import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class SafePaymentButton extends StatelessWidget {
  const SafePaymentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Container(
          height: 53,
          decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(9)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.red,
                child: Center(child: Image.asset(AppAssets.secure)),
              ),
              SizedBox(width: 5),
              Text("Tjara Commitment",
                  style: defaultTextStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w400)),
              Spacer(),
              Text("Low Prices",
                  style: defaultTextStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w300)),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
