// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class CategoryNavBar extends StatefulWidget {
  const CategoryNavBar({super.key});

  @override
  _CategoryNavBarState createState() => _CategoryNavBarState();
}

class _CategoryNavBarState extends State<CategoryNavBar> {
  final List<String> categories = [
    "All",
    "Women",
    "Men",
    "Home",
    "Jewellery",
    'Accesseries',
    'Sports',
    'Weapons',
    'Cloths'
  ];
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 23,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.asMap().entries.map((entry) {
            int index = entry.key;
            String category = entry.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        category,
                        style: defaultTextStyle.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   height: 4,
                  //   width: 80,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.only(
                  //         topLeft: Radius.circular(6),
                  //         topRight: Radius.circular(6)),
                  //     color: Colors.transparent,
                  //   ),
                  // ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
