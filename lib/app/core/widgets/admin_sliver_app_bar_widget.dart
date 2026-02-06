import 'package:flutter/material.dart';

class AdminSliverAppBarWidget extends StatelessWidget {
  final String title;
  final bool isAppBarExpanded;
  final List<Widget>? actions;

  const AdminSliverAppBarWidget({
    super.key,
    required this.title,
    required this.isAppBarExpanded,
    this.actions,
  });

  // Predefined gradients
  LinearGradient get _expandedGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.teal, Colors.teal],
  );

  LinearGradient get _collapsedGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color.fromARGB(255, 13, 17, 14), Colors.teal],
  );

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 80,
      elevation: 0,
      backgroundColor: Colors.teal,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isAppBarExpanded ? _expandedGradient : _collapsedGradient,
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }
}
