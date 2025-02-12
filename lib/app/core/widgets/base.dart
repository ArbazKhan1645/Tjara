// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'optimized_animated_container.dart';

class CommonBaseBodyScreen extends StatelessWidget {
  const CommonBaseBodyScreen({super.key, required this.screens});
  final List<Widget> screens;

  @override
  Widget build(BuildContext context) {
    final bool enableAnimations = true;
    return LayoutBuilder(
      builder: (context, constraints) {
        return OptimizedAnimatedContainer(
          shouldAnimate: enableAnimations,
          child: CommonBaseBodySubScreen(
              constraints: constraints, screens: screens),
        );
      },
    );
  }
}

class CommonBaseBodySubScreen extends StatefulWidget {
  const CommonBaseBodySubScreen(
      {super.key, required this.screens, required this.constraints});
  final List<Widget> screens;
  final BoxConstraints constraints;

  @override
  State<CommonBaseBodySubScreen> createState() =>
      _CommonBaseBodySubScreenState();
}

class _CommonBaseBodySubScreenState extends State<CommonBaseBodySubScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
          if (_scrollController.hasClients) {
            double offset = _scrollController.offset;
            scale = 1 + ((index * 100 - offset).abs() / 200).clamp(0.8, 1.0);
          }
          return Transform.scale(scale: scale, child: widget.screens[index]);
        },
        childCount: widget.screens.length,
      ),
    );
  }
}
