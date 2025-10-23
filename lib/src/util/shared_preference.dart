import 'dart:developer';

import 'package:flutter/material.dart';
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

  // テーマ設定関連のキー
  static const String _themeModeKey = 'theme_mode';

  /// テーマモードを保存
  static Future<bool> setThemeMode(ThemeMode themeMode) async {
    return await prefs.setString(_themeModeKey, themeMode.name);
  }

  /// テーマモードを取得
  static Future<ThemeMode> getThemeMode() async {
    final themeModeString =
        prefs.getString(_themeModeKey) ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => ThemeMode.system,
    );
  }

  // プロバイダー連携フラグ関連のキー（後方互換性のため残す）
  static const String _appleLinkedKey = 'apple_linked';
  static const String _googleLinkedKey = 'google_linked';

  // 新しいユーザーIDリスト管理のキー
  static const String _appleLinkedUserIdsKey = 'apple_linked_user_ids';
  static const String _googleLinkedUserIdsKey = 'google_linked_user_ids';

  /// Apple連携フラグを設定（後方互換性のため残す）
  static Future<bool> setAppleLinked(bool isLinked) async {
    return await prefs.setBool(_appleLinkedKey, isLinked);
  }

  /// Google連携フラグを設定（後方互換性のため残す）
  static Future<bool> setGoogleLinked(bool isLinked) async {
    return await prefs.setBool(_googleLinkedKey, isLinked);
  }

  /// Apple連携フラグを取得（後方互換性のため残す）
  static bool get isAppleLinked => prefs.getBool(_appleLinkedKey) ?? false;

  /// Google連携フラグを取得（後方互換性のため残す）
  static bool get isGoogleLinked => prefs.getBool(_googleLinkedKey) ?? false;

  /// 全ての連携フラグをクリア
  static Future<void> clearAllProviderFlags() async {
    await prefs.remove(_appleLinkedKey);
    await prefs.remove(_googleLinkedKey);
    await prefs.remove(_appleLinkedUserIdsKey);
    await prefs.remove(_googleLinkedUserIdsKey);
  }

  // 新しいユーザーIDリスト管理メソッド

  /// AppleでログインしたユーザーIDを追加
  static Future<bool> addAppleLinkedUserId(String userId) async {
    final currentIds = await getAppleLinkedUserIds();
    if (!currentIds.contains(userId)) {
      currentIds.add(userId);
      return await prefs.setStringList(_appleLinkedUserIdsKey, currentIds);
    }
    return true;
  }

  /// GoogleでログインしたユーザーIDを追加
  static Future<bool> addGoogleLinkedUserId(String userId) async {
    final currentIds = await getGoogleLinkedUserIds();
    if (!currentIds.contains(userId)) {
      currentIds.add(userId);
      return await prefs.setStringList(_googleLinkedUserIdsKey, currentIds);
    }
    return true;
  }

  /// AppleユーザーIDを削除
  static Future<bool> removeAppleLinkedUserId(String userId) async {
    final currentIds = await getAppleLinkedUserIds();
    currentIds.remove(userId);
    return await prefs.setStringList(_appleLinkedUserIdsKey, currentIds);
  }

  /// GoogleユーザーIDを削除
  static Future<bool> removeGoogleLinkedUserId(String userId) async {
    final currentIds = await getGoogleLinkedUserIds();
    currentIds.remove(userId);
    return await prefs.setStringList(_googleLinkedUserIdsKey, currentIds);
  }

  /// Appleで連携した全ユーザーIDリストを取得
  static Future<List<String>> getAppleLinkedUserIds() async {
    return prefs.getStringList(_appleLinkedUserIdsKey) ?? [];
  }

  /// Googleで連携した全ユーザーIDリストを取得
  static Future<List<String>> getGoogleLinkedUserIds() async {
    return prefs.getStringList(_googleLinkedUserIdsKey) ?? [];
  }

  /// Apple連携アカウントが存在するか
  static Future<bool> hasAppleLinkedAccounts() async {
    final ids = await getAppleLinkedUserIds();
    return ids.isNotEmpty;
  }

  /// Google連携アカウントが存在するか
  static Future<bool> hasGoogleLinkedAccounts() async {
    final ids = await getGoogleLinkedUserIds();
    return ids.isNotEmpty;
  }

  /// Apple連携ユーザーIDリストをクリア
  static Future<void> clearAppleLinkedUserIds() async {
    await prefs.remove(_appleLinkedUserIdsKey);
  }

  /// Google連携ユーザーIDリストをクリア
  static Future<void> clearGoogleLinkedUserIds() async {
    await prefs.remove(_googleLinkedUserIdsKey);
  }

  /// Apple連携アカウント数を取得
  static Future<int> getAppleLinkedAccountCount() async {
    final ids = await getAppleLinkedUserIds();
    return ids.length;
  }

  /// Google連携アカウント数を取得
  static Future<int> getGoogleLinkedAccountCount() async {
    final ids = await getGoogleLinkedUserIds();
    return ids.length;
  }

  /// 既存ユーザー向けのマイグレーション処理
  static Future<void> migrateFromOldProviderFlags() async {
    try {
      // 古いフラグが存在し、新しいリストが空の場合のみマイグレーション
      final hasOldAppleFlag = prefs.containsKey(_appleLinkedKey);
      final hasOldGoogleFlag = prefs.containsKey(_googleLinkedKey);
      final newAppleIds = await getAppleLinkedUserIds();
      final newGoogleIds = await getGoogleLinkedUserIds();

      if (hasOldAppleFlag && newAppleIds.isEmpty) {
        final oldAppleValue = prefs.getBool(_appleLinkedKey) ?? false;
        if (oldAppleValue) {
          // 古いフラグがtrueの場合、現在のユーザーIDを追加（もしあれば）
          final currentUserId = prefs.getString(_lastLoginProviderKey);
          if (currentUserId != null && currentUserId == 'apple') {
            // 現在のユーザーIDを取得する方法がないため、マイグレーションはスキップ
            log('Apple連携フラグのマイグレーション: 現在のユーザーIDが不明のためスキップ');
          }
        }
      }

      if (hasOldGoogleFlag && newGoogleIds.isEmpty) {
        final oldGoogleValue = prefs.getBool(_googleLinkedKey) ?? false;
        if (oldGoogleValue) {
          // 古いフラグがtrueの場合、現在のユーザーIDを追加（もしあれば）
          final currentUserId = prefs.getString(_lastLoginProviderKey);
          if (currentUserId != null && currentUserId == 'google') {
            // 現在のユーザーIDを取得する方法がないため、マイグレーションはスキップ
            log('Google連携フラグのマイグレーション: 現在のユーザーIDが不明のためスキップ');
          }
        }
      }

      log('プロバイダー連携フラグのマイグレーション完了');
    } catch (e) {
      log('マイグレーション処理エラー: $e');
    }
  }

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
