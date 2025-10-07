import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/util/app_utils.dart';

void main() {
  group('AppUtils Tests', () {
    test('sWidth should return a valid width', () {
      // Note: In test environment, these methods might return default values
      // since MediaQuery context is not available
      final width = AppUtils.sWidth();
      expect(width, isA<double>());
      expect(width, greaterThan(0));
    });

    test('sHeight should return a valid height', () {
      final height = AppUtils.sHeight();
      expect(height, isA<double>());
      expect(height, greaterThan(0));
    });

    // その他のAppUtilsのメソッドがあれば追加でテスト
  });
}
