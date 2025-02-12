// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../constants/font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  FontWeight fontWeight,
  Color color,
) {
  return GoogleFonts.quicksand(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

// regular style
TextStyle getRegularStyle({double fontSize = 16, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color);
}

// medium style
TextStyle getMediumStyle({double fontSize = 16, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.medium, color);
}

// medium style
TextStyle getLightStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.light, color);
}

// bold style
TextStyle getBoldStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color);
}

// semibold style
TextStyle getSemiBoldStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color);
}

// bold style
TextStyle getExtraBoldStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.extraBold, color);
}
