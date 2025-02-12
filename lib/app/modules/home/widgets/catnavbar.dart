import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class CategoryNavBar extends StatefulWidget {
  const CategoryNavBar({super.key});

  @override
  _CategoryNavBarState createState() => _CategoryNavBarState();
}

class _CategoryNavBarState extends State<CategoryNavBar> {
  final List<String> categories = ["All", "Women", "Men", "Home", "Jewellery"];
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyColor,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                Expanded(
                  child: Center(
                    child: Text(
                      category,
                      style: defaultTextStyle.copyWith(
                        color: _selectedIndex == index
                            ? AppColors.primaryColor
                            : Color(0xff8E8E8E),
                        fontWeight: _selectedIndex == index
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6)),
                    color: _selectedIndex == index
                        ? AppColors.primaryColor
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
