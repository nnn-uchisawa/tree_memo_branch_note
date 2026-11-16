import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// テスト用のアセット読み込みモック
class MockAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.contains('.png') || key.contains('.jpg') || key.contains('.svg')) {
      // 画像ファイルの場合は空文字列を返す
      return '';
    }
    return '';
  }

  @override
  Future<ByteData> load(String key) async {
    if (key.contains('.png') || key.contains('.jpg')) {
      // 1x1の透明PNGを返す
      final bytes = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
      ]);
      return ByteData.view(bytes.buffer);
    }
    throw FlutterError('Unable to load asset: $key');
  }
}

/// TestWidgetsFlutterBindingにアセットモックを設定するヘルパー
void setupMockAssets(WidgetTester tester) {
  // DefaultAssetBundleをオーバーライドできないため、
  // テスト内で個別にAssetBundleを渡す必要がある
}
