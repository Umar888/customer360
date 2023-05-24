
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeData? _themeData;

  ThemeData? get getThemeData => _themeData;

   void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}