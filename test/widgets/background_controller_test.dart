import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/widgets/trash_box/libraries/on_boarding_slider/background_controller.dart';

void main() {
  group('BackgroundController Widget Tests', () {
    testWidgets('should display page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BackgroundController(
              currentPage: 0,
              totalPage: 3,
              controllerColor: Colors.white,
              indicatorAbove: true,
              hasFloatingButton: false,
              indicatorPosition: 20.0,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
      );

      // ページインジケーターが表示されることを確認
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should handle indicatorAbove = false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BackgroundController(
              currentPage: 0,
              totalPage: 3,
              controllerColor: Colors.white,
              indicatorAbove: false,
              hasFloatingButton: false,
              indicatorPosition: 20.0,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(BackgroundController), findsOneWidget);
    });

    testWidgets('should handle last page with floating button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BackgroundController(
              currentPage: 2, // 最後のページ
              totalPage: 3,
              controllerColor: Colors.white,
              indicatorAbove: false,
              hasFloatingButton: true,
              indicatorPosition: 20.0,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
      );

      // 最後のページでフローティングボタンがある場合、SizedBox.shrinkが表示される
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should use correct colors', (WidgetTester tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BackgroundController(
              currentPage: 0,
              totalPage: 3,
              controllerColor: testColor,
              indicatorAbove: true,
              hasFloatingButton: false,
              indicatorPosition: 20.0,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
      );

      // 背景色が正しく設定されているかを確認
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(
        containers.any((container) => container.color == Colors.blue),
        true,
      );
    });
  });
}
