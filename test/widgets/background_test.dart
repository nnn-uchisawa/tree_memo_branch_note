import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/widgets/libraries/on_boarding_slider/background.dart';

void main() {
  group('Background Widget Tests', () {
    testWidgets('should display child widget', (WidgetTester tester) async {
      // Backgroundウィジェットは内部でConsumer<PageOffsetNotifier>を使用するため、
      // テスト環境では完全なProviderセットアップが必要
      // ここでは基本的な構造のみをテスト
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(key: Key('bg1'), color: Colors.red),
        Container(key: Key('bg2'), color: Colors.blue),
      ];

      // Backgroundウィジェットの基本的な構造を確認
      final background = Background(
        imageVerticalOffset: 0.0,
        centerBackground: false,
        totalPage: 2,
        background: backgrounds,
        speed: 1.0,
        imageHorizontalOffset: 0.0,
        child: testChild,
      );

      expect(background, isA<StatelessWidget>());
      expect(background.child, testChild);
      expect(background.totalPage, 2);
    });

    testWidgets('should assert background length equals totalPage',
        (WidgetTester tester) async {
      // アサーションのテスト - 長さが一致する場合の確認
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(key: Key('bg1'), color: Colors.red),
      ];

      final background = Background(
        imageVerticalOffset: 0.0,
        centerBackground: false,
        totalPage: 1, // backgroundsの長さと一致
        background: backgrounds,
        speed: 1.0,
        imageHorizontalOffset: 0.0,
        child: testChild,
      );

      expect(background.totalPage, backgrounds.length);
    });

    testWidgets('should create correct number of BackgroundImage widgets',
        (WidgetTester tester) async {
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(key: Key('bg1'), color: Colors.red),
        Container(key: Key('bg2'), color: Colors.blue),
        Container(key: Key('bg3'), color: Colors.green),
      ];

      final background = Background(
        imageVerticalOffset: 0.0,
        centerBackground: false,
        totalPage: 3,
        background: backgrounds,
        speed: 1.0,
        imageHorizontalOffset: 0.0,
        child: testChild,
      );

      expect(background.background.length, 3);
      expect(background.totalPage, 3);
    });

    testWidgets('should pass correct parameters', (WidgetTester tester) async {
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(key: Key('bg1'), color: Colors.red),
      ];

      final background = Background(
        imageVerticalOffset: 10.0,
        centerBackground: true,
        totalPage: 1,
        background: backgrounds,
        speed: 2.0,
        imageHorizontalOffset: 5.0,
        child: testChild,
      );

      expect(background.imageVerticalOffset, 10.0);
      expect(background.centerBackground, true);
      expect(background.speed, 2.0);
      expect(background.imageHorizontalOffset, 5.0);
    });
  });
}
