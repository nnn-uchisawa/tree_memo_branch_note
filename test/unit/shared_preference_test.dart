import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree/src/util/shared_preference.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  });
}
