import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const theme = 'theme';
  static const language = 'language';

  static Future<bool> setData({required String key, required String value}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
    return true;
  }

  static Future<String?> getData({required String key}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? str = sharedPreferences.getString(key);
    return str;
  }
}
