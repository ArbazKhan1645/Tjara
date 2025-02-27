// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

class CommonBaseBodyScreen extends StatelessWidget {
  const CommonBaseBodyScreen(
      {super.key, required this.screens, required this.scrollController});
  final List<Widget> screens;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CommonBaseBodySubScreen(
            scrollController: scrollController,
            constraints: constraints,
            screens: screens);
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
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.screens.length,
        cacheExtent: MediaQuery.of(context).size.height * 5,
        controller: widget.scrollController,
        itemBuilder: (context, index) {
          return widget.screens[index];
        });
  }
}
