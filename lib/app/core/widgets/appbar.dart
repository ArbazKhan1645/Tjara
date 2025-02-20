// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/routes/app_pages.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController _searchController = TextEditingController();

  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: preferredSize.height,
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
              onTap: () {
                Get.offNamed(Routes.DASHBOARD);
              },
              child: Image.asset(AppAssets.logo, height: 40)),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  color: Color(0xffF9F9F9),
                  borderRadius: BorderRadius.circular(40)),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  suffixIcon: CircleAvatar(
                    backgroundColor: Colors.black,
                    child:
                        Center(child: Icon(Icons.search, color: Colors.white)),
                  ),
                  contentPadding: EdgeInsets.all(12),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Search Product",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}
