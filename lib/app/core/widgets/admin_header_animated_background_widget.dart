import 'package:flutter/material.dart';

class AdminHeaderAnimatedBackgroundWidget extends StatelessWidget {
  final bool isAppBarExpanded;

  const AdminHeaderAnimatedBackgroundWidget({
    super.key,
    required this.isAppBarExpanded,
  });

  LinearGradient get _expandedStackGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97316), Color(0xFFFACC15)],
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isAppBarExpanded ? _expandedStackGradient : null,
      ),
      height: MediaQuery.sizeOf(context).height / 2.7,
    );
  }
}
