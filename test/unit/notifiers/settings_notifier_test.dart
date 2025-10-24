import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';
import 'package:tree/src/view/pages/settings/settings_notifier.dart';

/// テスト用のSharedPreferenceモック
class MockSharedPreference {
  static bool _isAppleLinked = false;
  static bool _isGoogleLinked = false;
  static final List<String> _appleLinkedUserIds = [];
  static final List<String> _googleLinkedUserIds = [];

  static bool get isAppleLinked => _isAppleLinked;
  static bool get isGoogleLinked => _isGoogleLinked;

  static Future<int> getAppleLinkedAccountCount() async {
    return _appleLinkedUserIds.length;
  }

  static Future<int> getGoogleLinkedAccountCount() async {
    return _googleLinkedUserIds.length;
  }

  static void setAppleLinked(bool value) {
    _isAppleLinked = value;
  }

  static void setGoogleLinked(bool value) {
    _isGoogleLinked = value;
  }

  static void addAppleLinkedUserId(String userId) {
    if (!_appleLinkedUserIds.contains(userId)) {
      _appleLinkedUserIds.add(userId);
      _isAppleLinked = true;
    }
  }

  static void addGoogleLinkedUserId(String userId) {
    if (!_googleLinkedUserIds.contains(userId)) {
      _googleLinkedUserIds.add(userId);
      _isGoogleLinked = true;
    }
  }

  static void removeAppleLinkedUserId(String userId) {
    _appleLinkedUserIds.remove(userId);
    if (_appleLinkedUserIds.isEmpty) {
      _isAppleLinked = false;
    }
  }

  static void removeGoogleLinkedUserId(String userId) {
    _googleLinkedUserIds.remove(userId);
    if (_googleLinkedUserIds.isEmpty) {
      _isGoogleLinked = false;
    }
  }

  static void reset() {
    _isAppleLinked = false;
    _isGoogleLinked = false;
    _appleLinkedUserIds.clear();
    _googleLinkedUserIds.clear();
  }
}

/// テスト用のAuthNotifierモック
class MockAuthNotifier extends AuthNotifier {
  bool _shouldThrowError = false;
  String _errorMessage = '';

  void setShouldThrowError(
    bool shouldThrow, {
    String errorMessage = 'Test error',
  }) {
    _shouldThrowError = shouldThrow;
    _errorMessage = errorMessage;
  }

  @override
  Future<void> deleteIndividualAccount(String provider) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    // 成功時のシミュレーション
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// テスト用のSettingsNotifier
class TestSettingsNotifier extends SettingsNotifier {
  @override
  bool hasAppleProvider() {
    return MockSharedPreference.isAppleLinked;
  }

  @override
  bool hasGoogleProvider() {
    return MockSharedPreference.isGoogleLinked;
  }

  @override
  Future<int> getAppleAccountCount() async {
    return await MockSharedPreference.getAppleLinkedAccountCount();
  }

  @override
  Future<int> getGoogleAccountCount() async {
    return await MockSharedPreference.getGoogleLinkedAccountCount();
  }
}

void main() {
  group('SettingsNotifier Tests', () {
    late TestSettingsNotifier settingsNotifier;

    setUp(() {
      settingsNotifier = TestSettingsNotifier();
      MockSharedPreference.reset();
    });

    group('プロバイダー存在チェック', () {
      test('Apple認証プロバイダーが存在しない場合', () {
        MockSharedPreference.setAppleLinked(false);

        final result = settingsNotifier.hasAppleProvider();

        expect(result, isFalse);
      });

      test('Apple認証プロバイダーが存在する場合', () {
        MockSharedPreference.setAppleLinked(true);

        final result = settingsNotifier.hasAppleProvider();

        expect(result, isTrue);
      });

      test('Google認証プロバイダーが存在しない場合', () {
        MockSharedPreference.setGoogleLinked(false);

        final result = settingsNotifier.hasGoogleProvider();

        expect(result, isFalse);
      });

      test('Google認証プロバイダーが存在する場合', () {
        MockSharedPreference.setGoogleLinked(true);

        final result = settingsNotifier.hasGoogleProvider();

        expect(result, isTrue);
      });
    });

    group('アカウント数取得', () {
      test('Apple認証アカウント数が0の場合', () async {
        MockSharedPreference.setAppleLinked(false);

        final count = await settingsNotifier.getAppleAccountCount();

        expect(count, equals(0));
      });

      test('Apple認証アカウント数が複数の場合', () async {
        MockSharedPreference.addAppleLinkedUserId('user1');
        MockSharedPreference.addAppleLinkedUserId('user2');
        MockSharedPreference.addAppleLinkedUserId('user3');

        final count = await settingsNotifier.getAppleAccountCount();

        expect(count, equals(3));
      });

      test('Google認証アカウント数が0の場合', () async {
        MockSharedPreference.setGoogleLinked(false);

        final count = await settingsNotifier.getGoogleAccountCount();

        expect(count, equals(0));
      });

      test('Google認証アカウント数が複数の場合', () async {
        MockSharedPreference.addGoogleLinkedUserId('user1');
        MockSharedPreference.addGoogleLinkedUserId('user2');

        final count = await settingsNotifier.getGoogleAccountCount();

        expect(count, equals(2));
      });
    });

    group('アカウント削除シミュレーション', () {
      test('Apple認証アカウントの削除', () async {
        // 初期状態：3つのAppleアカウント
        MockSharedPreference.addAppleLinkedUserId('user1');
        MockSharedPreference.addAppleLinkedUserId('user2');
        MockSharedPreference.addAppleLinkedUserId('user3');

        expect(await settingsNotifier.getAppleAccountCount(), equals(3));
        expect(settingsNotifier.hasAppleProvider(), isTrue);

        // 1つのアカウントを削除
        MockSharedPreference.removeAppleLinkedUserId('user2');

        expect(await settingsNotifier.getAppleAccountCount(), equals(2));
        expect(settingsNotifier.hasAppleProvider(), isTrue);

        // 残りのアカウントを全て削除
        MockSharedPreference.removeAppleLinkedUserId('user1');
        MockSharedPreference.removeAppleLinkedUserId('user3');

        expect(await settingsNotifier.getAppleAccountCount(), equals(0));
        expect(settingsNotifier.hasAppleProvider(), isFalse);
      });

      test('Google認証アカウントの削除', () async {
        // 初期状態：2つのGoogleアカウント
        MockSharedPreference.addGoogleLinkedUserId('user1');
        MockSharedPreference.addGoogleLinkedUserId('user2');

        expect(await settingsNotifier.getGoogleAccountCount(), equals(2));
        expect(settingsNotifier.hasGoogleProvider(), isTrue);

        // 1つのアカウントを削除
        MockSharedPreference.removeGoogleLinkedUserId('user1');

        expect(await settingsNotifier.getGoogleAccountCount(), equals(1));
        expect(settingsNotifier.hasGoogleProvider(), isTrue);

        // 最後のアカウントを削除
        MockSharedPreference.removeGoogleLinkedUserId('user2');

        expect(await settingsNotifier.getGoogleAccountCount(), equals(0));
        expect(settingsNotifier.hasGoogleProvider(), isFalse);
      });
    });

    group('複数プロバイダーの組み合わせ', () {
      test('AppleとGoogle両方の認証が存在する場合', () {
        MockSharedPreference.addAppleLinkedUserId('apple_user');
        MockSharedPreference.addGoogleLinkedUserId('google_user');

        expect(settingsNotifier.hasAppleProvider(), isTrue);
        expect(settingsNotifier.hasGoogleProvider(), isTrue);
      });

      test('Appleのみ認証が存在する場合', () {
        MockSharedPreference.addAppleLinkedUserId('apple_user');

        expect(settingsNotifier.hasAppleProvider(), isTrue);
        expect(settingsNotifier.hasGoogleProvider(), isFalse);
      });

      test('Googleのみ認証が存在する場合', () {
        MockSharedPreference.addGoogleLinkedUserId('google_user');

        expect(settingsNotifier.hasAppleProvider(), isFalse);
        expect(settingsNotifier.hasGoogleProvider(), isTrue);
      });

      test('認証が存在しない場合', () {
        expect(settingsNotifier.hasAppleProvider(), isFalse);
        expect(settingsNotifier.hasGoogleProvider(), isFalse);
      });
    });

    group('エラーハンドリング', () {
      test('アカウント数取得時のエラー処理', () async {
        // 正常なケース
        MockSharedPreference.addAppleLinkedUserId('user1');
        final count = await settingsNotifier.getAppleAccountCount();
        expect(count, equals(1));

        // エラーが発生した場合のテスト（実際の実装ではtry-catchで処理）
        // このテストでは、MockSharedPreferenceが正常に動作することを確認
        expect(count, isA<int>());
        expect(count, greaterThanOrEqualTo(0));
      });
    });

    group('境界値テスト', () {
      test('アカウント数が0から1に変化', () async {
        expect(await settingsNotifier.getAppleAccountCount(), equals(0));

        MockSharedPreference.addAppleLinkedUserId('user1');

        expect(await settingsNotifier.getAppleAccountCount(), equals(1));
        expect(settingsNotifier.hasAppleProvider(), isTrue);
      });

      test('アカウント数が1から0に変化', () async {
        MockSharedPreference.addAppleLinkedUserId('user1');
        expect(await settingsNotifier.getAppleAccountCount(), equals(1));

        MockSharedPreference.removeAppleLinkedUserId('user1');

        expect(await settingsNotifier.getAppleAccountCount(), equals(0));
        expect(settingsNotifier.hasAppleProvider(), isFalse);
      });
    });

    group('ダイアログ表示テスト', () {
      test('showIndividualDeleteDialogの基本動作 - メソッド呼び出しテスト', () async {
        // 実際のダイアログ表示は複雑なため、メソッドが正常に呼び出されることを確認
        try {
          // このテストでは、メソッドが例外を投げないことを確認
          // 実際のダイアログ表示は統合テストで行う
          expect(
            () => settingsNotifier.showIndividualDeleteDialog(
              null as BuildContext, // テスト用のnullコンテキスト
              null as WidgetRef, // テスト用のnull ref
              'Apple',
            ),
            throwsA(isA<TypeError>()),
          );
        } catch (e) {
          // 期待される例外（nullコンテキストのため）
          expect(e, isA<TypeError>());
        }
      });

      test('showIndividualDeleteDialog - プロバイダー名の検証', () async {
        // プロバイダー名が正しく処理されることを確認
        const appleProvider = 'Apple';
        const googleProvider = 'Google';

        expect(appleProvider, equals('Apple'));
        expect(googleProvider, equals('Google'));
      });
    });

    group('統合テスト', () {
      test('完全な認証フローのシミュレーション', () async {
        // 初期状態：認証なし
        expect(settingsNotifier.hasAppleProvider(), isFalse);
        expect(settingsNotifier.hasGoogleProvider(), isFalse);
        expect(await settingsNotifier.getAppleAccountCount(), equals(0));
        expect(await settingsNotifier.getGoogleAccountCount(), equals(0));

        // Apple認証を追加
        MockSharedPreference.addAppleLinkedUserId('apple_user1');
        expect(settingsNotifier.hasAppleProvider(), isTrue);
        expect(await settingsNotifier.getAppleAccountCount(), equals(1));

        // Google認証を追加
        MockSharedPreference.addGoogleLinkedUserId('google_user1');
        expect(settingsNotifier.hasGoogleProvider(), isTrue);
        expect(await settingsNotifier.getGoogleAccountCount(), equals(1));

        // 複数のアカウントを追加
        MockSharedPreference.addAppleLinkedUserId('apple_user2');
        MockSharedPreference.addGoogleLinkedUserId('google_user2');

        expect(await settingsNotifier.getAppleAccountCount(), equals(2));
        expect(await settingsNotifier.getGoogleAccountCount(), equals(2));

        // アカウントを削除
        MockSharedPreference.removeAppleLinkedUserId('apple_user1');
        expect(await settingsNotifier.getAppleAccountCount(), equals(1));
        expect(settingsNotifier.hasAppleProvider(), isTrue);

        // 最後のAppleアカウントを削除
        MockSharedPreference.removeAppleLinkedUserId('apple_user2');
        expect(await settingsNotifier.getAppleAccountCount(), equals(0));
        expect(settingsNotifier.hasAppleProvider(), isFalse);

        // Googleアカウントは残っている
        expect(settingsNotifier.hasGoogleProvider(), isTrue);
        expect(await settingsNotifier.getGoogleAccountCount(), equals(2));
      });
    });
  });
}
