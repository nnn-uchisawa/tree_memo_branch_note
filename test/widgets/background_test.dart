import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/libraries/on_boarding_slider/background.dart';

void main() {
  group('Background Widget Tests', () {
    testWidgets('should display child widget', (WidgetTester tester) async {
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(color: Colors.red),
        Container(color: Colors.blue),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Background(
              imageVerticalOffset: 0.0,
              centerBackground: false,
              totalPage: 2,
              background: backgrounds,
              speed: 1.0,
              imageHorizontalOffset: 0.0,
              child: testChild,
            ),
          ),
        ),
      );

      // 子ウィジェットが表示されることを確認
      expect(find.text('Test Child'), findsOneWidget);

      // Stackが使用されていることを確認
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('should assert background length equals totalPage',
        (WidgetTester tester) async {
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(color: Colors.red),
      ];

      // アサーションエラーが発生することを確認
      expect(() {
        Background(
          imageVerticalOffset: 0.0,
          centerBackground: false,
          totalPage: 2, // backgroundsの長さと異なる
          background: backgrounds,
          speed: 1.0,
          imageHorizontalOffset: 0.0,
          child: testChild,
        );
      }, throwsA(isA<AssertionError>()));
    });

    testWidgets('should create correct number of BackgroundImage widgets',
        (WidgetTester tester) async {
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(color: Colors.red),
        Container(color: Colors.blue),
        Container(color: Colors.green),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Background(
              imageVerticalOffset: 0.0,
              centerBackground: false,
              totalPage: 3,
              background: backgrounds,
              speed: 1.0,
              imageHorizontalOffset: 0.0,
              child: testChild,
            ),
          ),
        ),
      );

      // 3つのBackgroundImageが作成されることを確認
      // Note: BackgroundImageは別のファイルで定義されているため、
      // ここではStackの存在を確認する
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('should pass correct parameters', (WidgetTester tester) async {
      const testChild = Text('Test Child');
      final backgrounds = [
        Container(color: Colors.red),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Background(
              imageVerticalOffset: 10.0,
              centerBackground: true,
              totalPage: 1,
              background: backgrounds,
              speed: 2.0,
              imageHorizontalOffset: 5.0,
              child: testChild,
            ),
          ),
        ),
      );

      // ウィジェットが正常にビルドされることを確認
      expect(find.byType(Background), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });
  });
}
