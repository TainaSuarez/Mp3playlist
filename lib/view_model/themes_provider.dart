import 'package:flutter/material.dart';
import 'package:mp3_playlist/themes/dark_mode.dart';
import 'package:mp3_playlist/themes/light_mode.dart';

class ThemesProvider extends ChangeNotifier {
  
  ThemeData _themeData = lightMode;

  
  ThemeData get themeData => _themeData;

 
  bool get isDarkMode => themeData == darkMode;

  
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    
    notifyListeners();
  }

 
  void toggleTheme() {
    if (themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }
}