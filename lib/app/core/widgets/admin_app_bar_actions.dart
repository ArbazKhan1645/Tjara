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
        // IconButton(
        //   icon: const Icon(Icons.web, color: Colors.white),
        //   onPressed: () {},
        // ),
        // IconButton(
        //   icon: const Icon(Icons.fullscreen, color: Colors.white),
        //   onPressed: () {},
        // ),
        // Stack(
        //   alignment: Alignment.center,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        //       onPressed: () {},
        //     ),
        //     Positioned(
        //       top: 8,
        //       right: 8,
        //       child: Container(
        //         padding: const EdgeInsets.all(2),
        //         decoration: BoxDecoration(
        //           color: Colors.red,
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //         constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        //         child: const Text(
        //           '2',
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 10,
        //             fontWeight: FontWeight.bold,
        //           ),
        //           textAlign: TextAlign.center,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
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
