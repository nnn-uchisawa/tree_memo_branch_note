import 'package:flutter/material.dart';
// Riverpod/Provider未使用のため削除

/// テスト用のPageControllerのモック
class MockPageController extends PageController {
  double _mockOffset = 0.0;
  double _mockPage = 0.0;

  @override
  double get offset => _mockOffset;

  @override
  double? get page => _mockPage;

  void setMockOffset(double value) {
    _mockOffset = value;
  }

  void setMockPage(double value) {
    _mockPage = value;
  }
}

/// MaterialAppでラップするテストヘルパー
Widget wrapWithMaterialApp(Widget child, {PageController? pageController}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
