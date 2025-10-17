import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static SharedPreferences? _prefs;
  static const String isNotInitialKey = 'isInitial';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!;
  }

  static Future<bool> setIsNotInitial() async {
    return (await SharedPreferences.getInstance()).setBool(
      isNotInitialKey,
      true,
    );
  }

  static Future<bool> isNotInitial() async {
    return (await SharedPreferences.getInstance()).getBool(
          SharedPreference.isNotInitialKey,
        ) ??
        false;
  }

  // 認証関連のキー（ログイン状態のみ保存）
  static const String _isLoggedInKey = 'is_logged_in';

  /// ログイン状態を保存（ログイン情報は保存しない）
  static Future<void> saveLoginState() async {
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// ログイン状態をクリア
  static Future<void> clearLoginState() async {
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// ログイン状態を取得
  static bool get isLoggedIn => prefs.getBool(_isLoggedInKey) ?? false;
}
