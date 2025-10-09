import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tree/src/view/widgets/libraries/on_boarding_slider/page_offset_provider.dart';

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

/// テスト用のPageOffsetNotifierラッパー
class TestPageOffsetNotifier extends PageOffsetNotifier {
  TestPageOffsetNotifier(super.pageController);

  void setOffset(double value) {
    // PageOffsetNotifierの内部状態を直接変更するためのヘルパー
    notifyListeners();
  }
}

/// PageOffsetNotifierを提供するテストヘルパーWidget
Widget wrapWithPageOffsetProvider(Widget child,
    {PageController? pageController}) {
  final controller = pageController ?? MockPageController();
  return ChangeNotifierProvider<PageOffsetNotifier>(
    create: (_) => PageOffsetNotifier(controller),
    child: child,
  );
}

/// MaterialAppでラップするテストヘルパー
Widget wrapWithMaterialApp(Widget child, {PageController? pageController}) {
  final controller = pageController ?? MockPageController();
  return ChangeNotifierProvider<PageOffsetNotifier>(
    create: (_) => PageOffsetNotifier(controller),
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}
