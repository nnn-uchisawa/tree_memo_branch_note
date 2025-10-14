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

  // 認証関連のキー
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userDisplayNameKey = 'user_display_name';
  static const String _authProviderKey = 'auth_provider'; // 'google' or 'apple'

  /// ログイン状態を保存
  static Future<void> saveLoginState({
    required String userId,
    required String email,
    required String displayName,
    required String authProvider,
  }) async {
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userDisplayNameKey, displayName);
    await prefs.setString(_authProviderKey, authProvider);
  }

  /// ログイン状態をクリア
  static Future<void> clearLoginState() async {
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userDisplayNameKey);
    await prefs.remove(_authProviderKey);
  }

  /// ログイン状態を取得
  static bool get isLoggedIn => prefs.getBool(_isLoggedInKey) ?? false;
  static String? get userId => prefs.getString(_userIdKey);
  static String? get userEmail => prefs.getString(_userEmailKey);
  static String? get userDisplayName => prefs.getString(_userDisplayNameKey);
  static String? get authProvider => prefs.getString(_authProviderKey);
}
