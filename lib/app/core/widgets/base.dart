// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

class CommonBaseBodyScreen extends StatelessWidget {
  const CommonBaseBodyScreen({
    super.key,
    required this.screens,
    required this.scrollController,
  });

  final List<Widget> screens;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return OptimizedBodySubScreen(
      scrollController: scrollController,
      screens: screens,
    );
  }
}

class OptimizedBodySubScreen extends StatefulWidget {
  const OptimizedBodySubScreen({
    super.key,
    required this.screens,
    required this.scrollController,
  });

  final List<Widget> screens;
  final ScrollController scrollController;

  @override
  State<OptimizedBodySubScreen> createState() => _OptimizedBodySubScreenState();
}

class _OptimizedBodySubScreenState extends State<OptimizedBodySubScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      // Remove shrinkWrap for better performance
      itemCount: widget.screens.length,

      controller: widget.scrollController,

      itemBuilder: (context, index) {
        // Lazily build screens as needed
        return widget.screens[index];
      },
    );
  }
}
