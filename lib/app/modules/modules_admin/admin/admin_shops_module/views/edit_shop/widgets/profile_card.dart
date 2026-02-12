import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/const/appColors.dart';

class ProfileCard extends StatelessWidget {
  final VoidCallback onAvatarTap;
  final VoidCallback onclose;
  final img;

  const ProfileCard({
    super.key,
    required this.onAvatarTap,
    required this.onclose,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main container
            Card(
              elevation: 5,
              child: Container(
                width: Get.width * .9,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // BoxShadow(
                    //   color: Colors.grey.withOpacity(0.4),
                    //   blurRadius: 6,
                    //   offset: const Offset(0, 3),
                    // ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    // Close icon (top right)
                    Positioned(
                      top: 20,

                      child: Center(
                        child: Container(
                          child: Center(
                            child: Text(
                              'No cover image found',
                              style: TextStyle(color: appcolors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          onclose();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red.shade400,
                          radius: 14,
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Optional content inside container
                    const Center(child: Text('Profile Content')),
                  ],
                ),
              ),
            ),

            // Circular image at bottom center
            Positioned(
              bottom: -40, // Adjust as needed
              left: 0,
              right: 0,
              child: Center(
                // This ensures horizontal centering
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage:
                              img != null
                                  ? FileImage(File(img.path)) as ImageProvider
                                  : const CachedNetworkImageProvider(
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDk_071dbbz-bewOvpfYa3IlyImYtpvQmluw&s",
                                  ),
                        ),
                      ),
                      // Small green dot
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
