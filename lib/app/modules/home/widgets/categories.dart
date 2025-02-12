// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class CategorySection extends StatefulWidget {
  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  final List<Map<String, dynamic>> categories = [
    {"icon": "assets/icons/shopping.png", "name": "Bags, Shoes & Accessories"},
    {"icon": "assets/icons/car.png", "name": "Car Parts & Accessories"},
    {"icon": "assets/icons/appliance.png", "name": "Electronics & Accessories"},
    {"icon": "assets/icons/appliance.png", "name": "Sports & Outdoors"},
    {"icon": "assets/icons/appliance.png", "name": "Mobile Phones"},
  ];

  @override
  void initState() {
    super.initState();
    _scrollProgress = 0.2;
    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) {
      return;
    }

    double progress =
        _scrollController.offset / _scrollController.position.maxScrollExtent;
    progress = progress.isNaN ? 0.2 : progress;

    setState(() {
      _scrollProgress = progress.clamp(0.2, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'All Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        // Unified scrollable row
        SizedBox(
          height: 250,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> category = entry.value;
                final bool isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 84,
                      child: Column(
                        children: [
                          // Top Category Icon
                          Container(
                            height: 74,
                            width: 74,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.red
                                    : Colors.grey.shade300,
                              ),
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(category["icon"]),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            category["name"],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: isSelected ? Colors.red : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          // Bottom Category Icon (duplicate for parallel view)
                          Container(
                            height: 74,
                            width: 74,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.red
                                    : Colors.grey.shade300,
                              ),
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(category["icon"]),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            category["name"],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: isSelected ? Colors.red : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 10),
        // Scroll Progress Indicator (Fixed NaN issue)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              child: LinearProgressIndicator(
                value: _scrollProgress, // Now starts at 0.2
                backgroundColor: Colors.grey.shade300,
                color: Colors.red,

                minHeight: 4,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
