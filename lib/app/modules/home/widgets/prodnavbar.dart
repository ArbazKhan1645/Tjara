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
                      width: _selectedIndex == index ? 80 : 20,
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
        ),
        Container(height: 2, color: Colors.grey.shade300)
      ],
    );
  }
}
