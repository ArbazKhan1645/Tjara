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
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              Text(
                'تدعم الأفراد عبر برنامج الموزعين',
                style: defaultTextStyle.copyWith(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              Text(
                "تجارة لبنانية",
                style: defaultTextStyle.copyWith(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.red,
                child: Center(child: Image.asset(AppAssets.secure)),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
