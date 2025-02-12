// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  double heightPercentage(double percentage) => screenHeight * percentage / 100;
  double widthPercentage(double percentage) => screenWidth * percentage / 100;
  static const double _desktopBreakpoint = 1600.0;
  static const double _tabletBreakpoint = 1200.0;

  bool mobile() {
    return MediaQuery.of(context).size.width < 900;
  }

  bool isMobile() {
    return MediaQuery.of(context).size.width < _tabletBreakpoint;
  }

  bool isTablet() {
    return MediaQuery.of(context).size.width >= _tabletBreakpoint &&
        MediaQuery.of(context).size.width < _desktopBreakpoint;
  }

  bool isDesktop() {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  EdgeInsets getResponsivePadding() {
    if (isMobile()) {
      return const EdgeInsets.only(left: 0, right: 0);
    } else if (isTablet()) {
      return const EdgeInsets.only(left: 50, right: 50);
    } else {
      return const EdgeInsets.only(left: 200, right: 200, top: 20);
    }
  }

  double calculateTextSize() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    const double widthFactor = 0.002;
    const double heightFactor = 0.002;

    double adjustedSize = 20.0;

    adjustedSize += screenWidth * widthFactor;
    adjustedSize += screenHeight * heightFactor;

    return adjustedSize;
  }
}
