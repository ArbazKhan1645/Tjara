// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'my_colors.dart';

ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: AppColors.appColor1,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      color: AppColors.appColor1,
    ),
    iconTheme: const IconThemeData(color: AppColors.black),
    // Globally set Cabin as the default font
    textTheme: GoogleFonts.cabinTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: AppColors.textColor,
      displayColor: AppColors.textColor,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (states) => AppColors.lightContainerColor),
      overlayColor: WidgetStateProperty.resolveWith(
          (states) => AppColors.themeOrangeColor),
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
//
// ThemeData darkThemeData(BuildContext context) {
//   return ThemeData.dark().copyWith(
//     primaryColor: MyColors.darkThemeColor,
//     scaffoldBackgroundColor: MyColors.darkThemeColor,
//     appBarTheme:const AppBarTheme(centerTitle: false, elevation: 0, color: MyColors.darkThemeColor),
//     iconTheme: const IconThemeData(color: MyColors.darkLightTextColor),
//     textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
//         .apply(bodyColor: MyColors.darkTextColor),
//     colorScheme: const ColorScheme.dark().copyWith(
//       primary: MyColors.darkTextColor ,
//       onPrimary: MyColors.darkButtonTextColor,
//       secondary: MyColors.darkLightTextColor,
//       primaryContainer: MyColors.darkContainerColor,
//       secondaryContainer:MyColors.white,
//       error:MyColors.red,
//     ),
//     bottomNavigationBarTheme: BottomNavigationBarThemeData(
//       elevation: 1.h,
//       backgroundColor: MyColors.darkContainerColor,
//       selectedItemColor: MyColors.darkTitleColor,
//       unselectedItemColor: MyColors.darkLightTextColor,
//       selectedIconTheme: const IconThemeData(color: MyColors.darkTitleColor),
//       showUnselectedLabels: true,
//     ),
//   );
// }
