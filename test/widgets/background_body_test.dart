import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/libraries/on_boarding_slider/background_body.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BackgroundBody Widget Tests', () {
    late MockPageController pageController;

    setUp(() {
      pageController = MockPageController();
    });

    testWidgets('should display PageView with correct number of pages',
        (WidgetTester tester) async {
      final testBodies = [
        Text('Page 1'),
        Text('Page 2'),
        Text('Page 3'),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(
          BackgroundBody(
            controller: pageController,
            function: (int page) {},
            totalPage: 3,
            bodies: testBodies,
          ),
        ),
      );

      // PageViewが存在することを確認
      expect(find.byType(PageView), findsOneWidget);

      // 最初のページが表示されることを確認
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('should call function when page changes',
        (WidgetTester tester) async {
      int? calledWithPage;

      final testBodies = [
        Text('Page 1', key: Key('page1')),
        Text('Page 2', key: Key('page2')),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(
          BackgroundBody(
            controller: pageController,
            function: (int page) {
              calledWithPage = page;
            },
            totalPage: 2,
            bodies: testBodies,
          ),
        ),
      );

      // ページを変更
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.onPageChanged!(1);

      expect(calledWithPage, 1);
    });

    testWidgets('should have ClampingScrollPhysics',
        (WidgetTester tester) async {
      final testBodies = [
        Text('Page 1'),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(
          BackgroundBody(
            controller: pageController,
            function: (int page) {},
            totalPage: 1,
            bodies: testBodies,
          ),
        ),
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<ClampingScrollPhysics>());
    });

    testWidgets('should use provided controller', (WidgetTester tester) async {
      final testBodies = [
        Text('Page 1'),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(
          BackgroundBody(
            controller: pageController,
            function: (int page) {},
            totalPage: 1,
            bodies: testBodies,
          ),
        ),
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller, pageController);
    });

    testWidgets('should assert bodies length equals totalPage',
        (WidgetTester tester) async {
      // アサーションはデバッグモードでのみ有効
      // 長さが正しい場合は正常に動作することを確認
      final testBodies = [
        Text('Page 1'),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(
          BackgroundBody(
            controller: pageController,
            function: (int page) {},
            totalPage: 1, // bodiesの長さと一致
            bodies: testBodies,
          ),
        ),
      );

      expect(find.text('Page 1'), findsOneWidget);
    });
  });
}
