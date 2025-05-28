import 'package:flutter/material.dart';
import 'package:mp3_playlist/themes/dark_mode.dart';
import 'package:mp3_playlist/themes/light_mode.dart';

class ThemesProvider extends ChangeNotifier {
  // Iniciando, light mode
  ThemeData _themeData = lightMode;

  // get theme
  ThemeData get themeData => _themeData;

  // is dark mode
  bool get isDarkMode => themeData == darkMode;

  // set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    // update UI
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    if (themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }
}