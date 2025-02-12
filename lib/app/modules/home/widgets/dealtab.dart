import 'package:flutter/material.dart';

class DealTabs extends StatelessWidget {
  final List<String> tabs = const ["On sale", "Best Seller", "New Arrivals"];

  const DealTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            dividerColor: Colors.grey.shade300,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.green,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ],
      ),
    );
  }
}
