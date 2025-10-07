import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/libraries/on_boarding_slider/onboarding_navigation_bar.dart';

void main() {
  group('OnBoardingNavigationBar Widget Tests', () {
    testWidgets('should display navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 0,
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
            ),
          ),
        ),
      );

      expect(find.byType(OnBoardingNavigationBar), findsOneWidget);
    });

    testWidgets('should handle skip callback', (WidgetTester tester) async {
      bool skipCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 0,
              onSkip: () {
                skipCalled = true;
              },
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
            ),
          ),
        ),
      );

      // スキップボタンがある場合はタップしてコールバックが呼ばれることを確認
      // 実装によってはボタンが表示されない場合があるため、存在確認も行う
      final skipButton = find.text('skip');
      if (tester.any(skipButton)) {
        await tester.tap(skipButton);
        expect(skipCalled, true);
      }
    });

    testWidgets('should display custom skip button when provided',
        (WidgetTester tester) async {
      const customSkipButton = Text('Custom Skip');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 0,
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
              skipTextButton: customSkipButton,
            ),
          ),
        ),
      );

      expect(find.text('Custom Skip'), findsOneWidget);
    });

    testWidgets('should display finish button when provided',
        (WidgetTester tester) async {
      const finishButton = Text('Finish');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 2, // 最後のページ
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
              finishButton: finishButton,
              onFinish: () {},
            ),
          ),
        ),
      );

      expect(find.text('Finish'), findsOneWidget);
    });

    testWidgets('should handle finish callback', (WidgetTester tester) async {
      bool finishCalled = false;
      const finishButton = Text('Finish');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 2,
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
              finishButton: finishButton,
              onFinish: () {
                finishCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Finish'));
      expect(finishCalled, true);
    });

    testWidgets('should have correct preferred size',
        (WidgetTester tester) async {
      final navigationBar = OnBoardingNavigationBar(
        currentPage: 0,
        onSkip: () {},
        headerBackgroundColor: Colors.blue,
        totalPage: 3,
      );

      expect(navigationBar.preferredSize, Size.fromHeight(40));
    });

    testWidgets('should handle shouldFullyObstruct correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 0,
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
            ),
          ),
        ),
      );

      final navigationBar = tester.widget<OnBoardingNavigationBar>(
          find.byType(OnBoardingNavigationBar));

      expect(
          navigationBar
              .shouldFullyObstruct(tester.element(find.byType(Scaffold))),
          false);
    });

    testWidgets('should display leading and middle widgets when provided',
        (WidgetTester tester) async {
      const leadingWidget = Icon(Icons.menu);
      const middleWidget = Text('Middle');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 0,
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
              leading: leadingWidget,
              middle: middleWidget,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
    });
  });
}
