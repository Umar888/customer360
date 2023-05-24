import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import 'constants/colors.dart';

final themeLight = ThemeData(
  brightness: Brightness.light,
  progressIndicatorTheme:
      ProgressIndicatorThemeData(color: ColorSystem.primaryTextColor),
  //accentColor: Colors.whi
  primaryColor: ColorSystem.primary,

  accentColor: ColorSystem.primaryTextColor,
  textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ColorSystem.primaryTextColor,
      // selectionColor: ColorSystem.primaryTextColor,
      selectionHandleColor: ColorSystem.primaryTextColor),
  scaffoldBackgroundColor: ColorSystem.scaffoldBackgroundColor,
  appBarTheme: AppBarTheme(
      backgroundColor: ColorSystem.scaffoldBackgroundColor,
      titleTextStyle: TextStyle(color: Colors.black),
      elevation: 0,
      iconTheme: IconThemeData(color: ColorSystem.black)),
  textTheme: TextTheme(
    headline1: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: SizeSystem.size12,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline2: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w700,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline3: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: SizeSystem.size16,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline4: TextStyle(
        color: AppColors.headline4Textcolor,
        fontWeight: FontWeight.bold,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline5: TextStyle(
        color: AppColors.headline5Textcolor,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    caption: TextStyle(
        color: ColorSystem.primary,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis),
  ),

  primaryColorDark: Colors.white,
  fontFamily: kRubik,
  iconTheme: IconThemeData(color: ColorSystem.primaryTextColor),

  inputDecorationTheme: InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.greyDark, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.primaryTextColor, width: 1.0),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.greyDark, width: 1.0),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.complimentary, width: 1.0),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.complimentary, width: 1.0),
    ),
    focusColor: ColorSystem.primaryTextColor,
    floatingLabelStyle: const TextStyle(color: ColorSystem.primaryTextColor),
  ),
);
final themeDark = ThemeData(
  brightness: Brightness.dark,

  appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(color: Colors.white),
      elevation: 0,
      iconTheme: IconThemeData(color: ColorSystem.white)),
  textTheme: TextTheme(
    headline1: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: SizeSystem.size12,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline2: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w700,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline3: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: SizeSystem.size16,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline4: TextStyle(
        color: AppColors.headline4TextcolorLight,
        fontWeight: FontWeight.bold,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    headline5: TextStyle(
        color: ColorSystem.greyMild,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        overflow: TextOverflow.ellipsis),
    caption: TextStyle(
        color: ColorSystem.greyMild,
        fontSize: SizeSystem.size14,
        fontFamily: kRubik,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: ColorSystem.white),
  // accentColor: Colors.black87,
  primaryColor: ColorSystem.white,
  fontFamily: kRubik,
  iconTheme: IconThemeData(color: ColorSystem.white),
  accentColor: ColorSystem.white,
  primaryColorDark: Colors.black87,
  textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ColorSystem.white,
      selectionColor: ColorSystem.white,
      selectionHandleColor: ColorSystem.white),
  inputDecorationTheme: InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.greyMild, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.white, width: 1.0),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.greyMild, width: 1.0),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.complimentary, width: 1.0),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorSystem.complimentary, width: 1.0),
    ),
    focusColor: ColorSystem.white,
    floatingLabelStyle: const TextStyle(color: ColorSystem.white),
  ),
);
