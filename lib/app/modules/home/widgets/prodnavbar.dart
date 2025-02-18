import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class ProductNavBar extends StatefulWidget {
  const ProductNavBar({super.key});

  @override
  _ProductNavBarState createState() => _ProductNavBarState();
}

class _ProductNavBarState extends State<ProductNavBar> {
  final List<String> categories = [
    "All",
    "On Sale",
    "Best Seller",
    "New Arrivals",
    "Hourly Shops"
  ];
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.greyColor.withOpacity(0.20),
          height: 50,
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
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: _selectedIndex != index
                              ? BoxDecoration()
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: AppColors.greyColor),
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
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Container(height: 2, color: Colors.grey.shade300)
      ],
    );
  }
}
