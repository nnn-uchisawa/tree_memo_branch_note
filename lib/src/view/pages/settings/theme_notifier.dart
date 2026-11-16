import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/src/util/shared_preference.dart';
import 'package:tree/src/view/pages/settings/theme_state.dart';

part 'theme_notifier.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    // SharedPreferences を初期化
    SharedPreference.init();

    // 保存されたテーマモードを読み込み
    _loadThemeMode();

    return const ThemeState();
  }

  /// 保存されたテーマモードを読み込み
  Future<void> _loadThemeMode() async {
    try {
      final savedThemeMode = await SharedPreference.getThemeMode();
      state = state.copyWith(themeMode: savedThemeMode);
    } catch (e) {
      state = state.copyWith(errorMessage: 'テーマ設定の読み込みに失敗しました');
    }
  }

  /// テーマモードを変更
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // SharedPreferencesに保存
      await SharedPreference.setThemeMode(themeMode);

      state = state.copyWith(themeMode: themeMode, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'テーマ設定の保存に失敗しました');
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
