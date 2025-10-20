import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree/src/util/shared_preference.dart';

void main() {
  group('SharedPreference Tests', () {
    setUp(() {
      // テスト前の初期化
      SharedPreferences.setMockInitialValues({});
    });

    test('isNotInitial should return boolean', () async {
      final result = await SharedPreference.isNotInitial();
      expect(result, isA<bool>());
    });

    test('setIsNotInitial should complete without error', () async {
      await SharedPreference.setIsNotInitial();
      // エラーが発生しなければ成功
      final result = await SharedPreference.isNotInitial();
      expect(result, true);
    });

    test('SharedPreference methods should handle async operations', () async {
      // async/awaitパターンが正しく実装されていることを確認
      final initialValue = await SharedPreference.isNotInitial();
      expect(initialValue, false);

      await SharedPreference.setIsNotInitial();
      final updatedValue = await SharedPreference.isNotInitial();
      expect(updatedValue, true);
    });

    group('Login State Tests', () {
      test('ログイン状態の保存と取得が正常に動作する', () async {
        await SharedPreference.init();
        expect(SharedPreference.isLoggedIn, false);

        await SharedPreference.saveLoginState();
        expect(SharedPreference.isLoggedIn, true);

        await SharedPreference.clearLoginState();
        expect(SharedPreference.isLoggedIn, false);
      });

      test('プロバイダー付きでログイン状態を保存できる', () async {
        await SharedPreference.init();
        await SharedPreference.saveLoginState(provider: 'google');
        expect(SharedPreference.isLoggedIn, true);
        expect(SharedPreference.lastLoginProvider, 'google');

        await SharedPreference.saveLoginState(provider: 'apple');
        expect(SharedPreference.lastLoginProvider, 'apple');
      });

      test('セッションタイムスタンプが正しく保存される', () async {
        await SharedPreference.init();
        await SharedPreference.saveLoginState();
        expect(SharedPreference.sessionTimestamp, isNotNull);
        expect(SharedPreference.sessionTimestamp, isA<int>());
      });

      test('セッション有効性の判定が正常に動作する', () async {
        await SharedPreference.init();
        // 新しいセッションは有効
        await SharedPreference.saveLoginState();
        expect(SharedPreference.isSessionValid, true);

        // セッションをクリアすると無効
        await SharedPreference.clearLoginState();
        expect(SharedPreference.isSessionValid, false);
      });

      test('ログイン状態クリア時にすべての情報が削除される', () async {
        await SharedPreference.init();
        await SharedPreference.saveLoginState(provider: 'google');
        expect(SharedPreference.isLoggedIn, true);
        expect(SharedPreference.lastLoginProvider, 'google');
        expect(SharedPreference.sessionTimestamp, isNotNull);

        await SharedPreference.clearLoginState();
        expect(SharedPreference.isLoggedIn, false);
        expect(SharedPreference.lastLoginProvider, isNull);
        expect(SharedPreference.sessionTimestamp, isNull);
      });
    });
  });
}
