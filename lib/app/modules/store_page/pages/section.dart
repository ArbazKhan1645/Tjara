// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/modules/store_page/pages/products_grid.dart';

class StorePageSectionForm extends StatefulWidget {
  const StorePageSectionForm({super.key});

  @override
  _StorePageSectionFormState createState() => _StorePageSectionFormState();
}

class _StorePageSectionFormState extends State<StorePageSectionForm> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    StoreProductGrid(),
    Center(child: Text("All Products")),
    Center(child: Text("About Us")),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.primaryColor,
          height: 215,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/store.png')),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Stylish Collection Wholesellers",
                          style: defaultTextStyle.copyWith(
                              letterSpacing: 1.5,
                              wordSpacing: 2,
                              color: Colors.white)),
                      Text("98.2% positive feedback (279)",
                          style: defaultTextStyle.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 14)),
                      Text("1.1K items sold",
                          style: defaultTextStyle.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 14)),
                      Text("96 followers",
                          style: defaultTextStyle.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 14)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppAssets.heart),
                            SizedBox(width: 10),
                            Text('Follow Shop',
                                style: defaultTextStyle.copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppAssets.apps),
                            SizedBox(width: 10),
                            Text('Follow Shop',
                                style: defaultTextStyle.copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffEAEAEA)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintStyle: defaultTextStyle.copyWith(
                              color: Colors.grey.shade400, fontSize: 14),
                          hintText: 'Search in store',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tune, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            _buildTabButton(0, "Home"),
            _buildTabButton(1, "All Products"),
            _buildTabButton(2, "About Us"),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 10),
        StoreProductNavBar(),
        _screens[_selectedIndex]
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _selectedIndex == index ? Colors.red : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoreProductNavBar extends StatefulWidget {
  const StoreProductNavBar({super.key});

  @override
  _StoreProductNavBarState createState() => _StoreProductNavBarState();
}

class _StoreProductNavBarState extends State<StoreProductNavBar> {
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
