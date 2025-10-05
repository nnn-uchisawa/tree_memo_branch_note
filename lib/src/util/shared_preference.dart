import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  SharedPreference();
  static const String isNotInitialKey = 'isInitial';

  static Future<bool> setIsNotInitial() async {
    return (await SharedPreferences.getInstance())
        .setBool(isNotInitialKey, true);
  }

  static Future<bool> isNotInitial() async {
    return (await SharedPreferences.getInstance())
            .getBool(SharedPreference.isNotInitialKey) ??
        false;
  }
}
