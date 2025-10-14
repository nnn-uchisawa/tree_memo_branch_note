import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/util/app_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppUtils Tests', () {
    test('sWidth should return a valid width', () {
      // AppRouter.navigatorKeyがnullまたはcontextがない場合はデフォルト値を返す
      final width = AppUtils.sWidth;
      expect(width, isA<double>());
      expect(width, greaterThan(0));
      // デフォルト値は1080.0
      expect(width, 1080.0);
    });

    test('sHeight should return a valid height', () {
      // AppRouter.navigatorKeyがnullまたはcontextがない場合はデフォルト値を返す
      final height = AppUtils.sHeight;
      expect(height, isA<double>());
      expect(height, greaterThan(0));
      // デフォルト値は1920.0
      expect(height, 1920.0);
    });

    test('getRandomString should return string with correct length', () {
      final randomString = AppUtils.getRandomString(length: 10);
      expect(randomString, isA<String>());
      expect(randomString.length, 10);

      final defaultRandomString = AppUtils.getRandomString();
      expect(defaultRandomString.length, 64);
    });
  });
}
