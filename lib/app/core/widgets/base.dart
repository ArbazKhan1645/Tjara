// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'optimized_animated_container.dart';

class CommonBaseBodyScreen extends StatelessWidget {
  const CommonBaseBodyScreen(
      {super.key, required this.screens, required this.scrollController});
  final List<Widget> screens;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final bool enableAnimations = true;
    return LayoutBuilder(
      builder: (context, constraints) {
        return OptimizedAnimatedContainer(
          shouldAnimate: enableAnimations,
          child: CommonBaseBodySubScreen(
              scrollController: scrollController,
              constraints: constraints,
              screens: screens),
        );
      },
    );
  }
}

class CommonBaseBodySubScreen extends StatefulWidget {
  const CommonBaseBodySubScreen(
      {super.key,
      required this.screens,
      required this.constraints,
      required this.scrollController});
  final List<Widget> screens;
  final BoxConstraints constraints;
  final ScrollController scrollController;

  @override
  State<CommonBaseBodySubScreen> createState() =>
      _CommonBaseBodySubScreenState();
}

class _CommonBaseBodySubScreenState extends State<CommonBaseBodySubScreen> {
  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        _buildSliverList(),
      ],
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          double scale = 1.0;
          // if (widget.scrollController.hasClients) {
          //   double offset = widget.scrollController.offset;
          //   scale = 1 + ((index * 100 - offset).abs() / 200).clamp(0.8, 1.0);
          // }
          return Transform.scale(scale: scale, child: widget.screens[index]);
        },
        childCount: widget.screens.length,
      ),
    );
  }
}
