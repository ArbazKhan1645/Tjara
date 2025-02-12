// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<bool> isSearchMode = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();

  CustomAppBar({super.key});

  void _toggleSearchMode() {
    isSearchMode.value = !isSearchMode.value;
    if (!isSearchMode.value) _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isSearchMode,
      builder: (context, searchMode, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: preferredSize.height,
          color: Colors.white,
          child: Row(
            children: [
              Image.asset(AppAssets.logo, height: 40),
              SizedBox(width: 10),
              if (!searchMode) const Spacer(),
              if (searchMode)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffF0F0F0)),
                        color: Color(0xffF9F9F9),
                        borderRadius: BorderRadius.circular(6)),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: _toggleSearchMode,
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
              if (!searchMode) ...[
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: _toggleSearchMode,
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {
                    // Handle favorite action
                  },
                ),
              ],
              IconButton(
                icon: Image.asset(AppAssets.language),
                onPressed: () {
                  // Handle language change
                },
              ),
              IconButton(
                icon: Image.asset(AppAssets.dropdown),
                onPressed: () {
                  // Handle language change
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}
