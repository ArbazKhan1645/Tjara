import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/new_profile.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';

class AdminAppBarActions extends StatelessWidget {
  const AdminAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NotificationIconButton(),
        const SizedBox(width: 10),

        GestureDetector(
          onTap: () {
            UserMenuHelper.showUserMenu(context);
          },
          child: const CircleAvatar(
            radius: 25, // half of diameter
            backgroundColor: AppColors.white,
            backgroundImage: AssetImage(AppAssets.logo),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class AdminAppBarActionsSimple extends StatelessWidget {
  const AdminAppBarActionsSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const NotificationIconButton(),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            UserMenuHelper.showUserMenu(context);
          },
          child: const CircleAvatar(
            radius: 25, // half of diameter
            backgroundColor: AppColors.white,
            backgroundImage: AssetImage(AppAssets.logo),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
