import 'package:flutter/material.dart';
import 'package:gc_customer_app/constants/colors.dart';

import '../primitives/color_system.dart';
import '../primitives/constants.dart';
import '../primitives/size_system.dart';

class AppTheme {
  static var themeData = ThemeData(
    primarySwatch: Colors.blue,
    progressIndicatorTheme:
        ProgressIndicatorThemeData(color: Colors.black),
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
  );
}
