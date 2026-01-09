import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tjara/app/core/locators/service_locator.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';
import 'package:tjara/app/core/utils/helpers/logger.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/routes/app_pages.dart';

import 'package:tjara/app/modules/splash_screen/controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Splashbody();
  }
}

class Splashbody extends StatefulWidget {
  const Splashbody({super.key});

  @override
  State<Splashbody> createState() => _SplashbodyState();
}

class _SplashbodyState extends State<Splashbody> {
  final SplashService _splashService = SplashService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    // Start the splash service when widget initializes
    _splashService.startSplashScreen();
  }

  Future<void> _initializeApp() async {
    initDependencies();
    AppLogger.info('initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(child: Image.asset(AppAssets.logo, width: 100)),
    );
  }
}

class SplashService {
  // Method to handle the splash screen duration and navigation
  void startSplashScreen() {
    Future.delayed(const Duration(seconds: 4), () {
      Get.offAllNamed(Routes.DASHBOARD);
    });
  }
}
