// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';

ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: AppColors.appColor1,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.appColor1,
    ),
    iconTheme: const IconThemeData(color: AppColors.black),
    textTheme: GoogleFonts.cabinTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: AppColors.textColor, displayColor: AppColors.textColor),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => AppColors.lightContainerColor,
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => AppColors.themeOrangeColor,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.textColor,
      onPrimary: AppColors.themeOrangeColor,
      secondary: AppColors.textLightColor,
      primaryContainer: AppColors.lightContainerColor,
      secondaryContainer: AppColors.black,
      error: AppColors.red,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 1,
      backgroundColor: AppColors.lightContainerColor,
      selectedItemColor: AppColors.textColor,
      unselectedItemColor: AppColors.textLightColor,
      selectedIconTheme: IconThemeData(color: AppColors.textLightColor),
      showUnselectedLabels: true,
    ),
  );
}

TextStyle defaultTextStyle = GoogleFonts.outfit(
  fontWeight: FontWeight.w500,
  fontSize: 16,
);
