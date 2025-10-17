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

  // 認証関連のキー（セッション永続化用）
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _sessionTimestampKey = 'session_timestamp';
  static const String _lastLoginProviderKey = 'last_login_provider';

  /// ログイン状態を保存（セッション情報も保存）
  static Future<void> saveLoginState({String? provider}) async {
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setInt(
      _sessionTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    if (provider != null) {
      await prefs.setString(_lastLoginProviderKey, provider);
    }
  }

  /// ログイン状態をクリア
  static Future<void> clearLoginState() async {
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_sessionTimestampKey);
    await prefs.remove(_lastLoginProviderKey);
  }

  /// ログイン状態を取得
  static bool get isLoggedIn => prefs.getBool(_isLoggedInKey) ?? false;

  /// セッションのタイムスタンプを取得
  static int? get sessionTimestamp => prefs.getInt(_sessionTimestampKey);

  /// 最後のログインプロバイダーを取得
  static String? get lastLoginProvider =>
      prefs.getString(_lastLoginProviderKey);

  /// セッションが有効かチェック（24時間以内）
  static bool get isSessionValid {
    final timestamp = sessionTimestamp;
    if (timestamp == null) return false;

    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(sessionTime);

    // 24時間以内のセッションは有効
    return difference.inHours < 24;
  }
}
