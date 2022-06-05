import 'package:flutter/material.dart';
import 'package:hellohi/utils/shared_pref.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  checkTheme() {
    SharedPref.getData(key: SharedPref.theme).then((value) {
      if (value != null || value != 'null') {
        if (value == 'light') {
          themeMode = ThemeMode.light;
          notifyListeners();
        } else if (value == 'dark') {
          themeMode = ThemeMode.dark;
          notifyListeners();
        } else {
          themeMode = ThemeMode.system;
          notifyListeners();
        }
      }
    });
  }

  changeToDark() {
    SharedPref.setData(key: SharedPref.theme, value: 'dark');
    themeMode = ThemeMode.dark;
    notifyListeners();
  }

  changeToLight() {
    SharedPref.setData(key: SharedPref.theme, value: 'light');
    themeMode = ThemeMode.light;
    notifyListeners();
  }

  changeToSystem() {
    SharedPref.setData(key: SharedPref.theme, value: 'system');
    themeMode = ThemeMode.system;
    notifyListeners();
  }
}
