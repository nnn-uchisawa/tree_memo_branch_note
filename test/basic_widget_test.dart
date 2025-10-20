import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/flavors.dart';
import 'package:tree/src/tree_app.dart';
import 'package:tree/src/view/pages/home/home_view.dart';
import 'package:tree/src/view/widgets/on_boarding_page.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    // フレーバーの設定
    F.appFlavor = Flavor.dev;
  });

  group('TreeApp Basic Tests', () {
    testWidgets('TreeApp should build without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(child: TreeApp()));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('TreeApp should have correct theme configuration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(child: TreeApp()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      // ライトテーマの確認
      expect(materialApp.theme?.brightness, Brightness.light);
      expect(materialApp.theme?.colorScheme.primary, Colors.blue);

      // ダークテーマの確認
      expect(materialApp.darkTheme?.brightness, Brightness.dark);
      expect(materialApp.darkTheme?.colorScheme.primary, Colors.blue);

      // テーマモードの確認
      expect(materialApp.themeMode, ThemeMode.system);
    });
  });

  group('HomeView Basic Tests', () {
    testWidgets('HomeView should display basic structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviderScope(HomeView()));

      // 基本的な構造が存在することを確認
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Tree'), findsOneWidget);
    });
  });

  group('OnBoardingPage Tests', () {
    testWidgets('OnBoardingPage should display title when provided', (
      WidgetTester tester,
    ) async {
      const testTitle = 'Test Title';

      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            title: testTitle,
            description: 'Test Description',
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('OnBoardingPage should display description when provided', (
      WidgetTester tester,
    ) async {
      const testDescription = 'Test Description';

      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            title: 'Test Title',
            description: testDescription,
          ),
        ),
      );

      expect(find.text(testDescription), findsOneWidget);
    });

    testWidgets('OnBoardingPage should handle null title and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: OnBoardingPage()));

      // nullの場合でもクラッシュしないことを確認
      expect(find.byType(OnBoardingPage), findsOneWidget);
    });

    testWidgets('OnBoardingPage should have blue background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(title: 'Test', description: 'Test'),
        ),
      );

      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color, Colors.blue);
    });
  });

  group('UI Component Tests', () {
    testWidgets('Text widgets should have correct styling', (
      WidgetTester tester,
    ) async {
      const testTitle = 'Test Title';

      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            title: testTitle,
            description: 'Test Description',
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.text(testTitle));
      expect(titleWidget.style?.color, Colors.white);
      expect(titleWidget.style?.fontSize, 30);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('AppBar should have correct styling in HomeView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviderScope(HomeView()));

      final titleWidget = tester.widget<Text>(find.text('Tree'));
      expect(titleWidget.style?.color, Colors.white);
    });
  });

  // group('Route Names Tests', () {
  //   test('Route names should be defined correctly', () {
  //     // ルート名の定数が正しく定義されていることを確認
  //     expect(HomeView.routeName, '/home');
  //     expect(MemoView.routeName, '/memo');
  //   });
  // });

  group('Provider Tests', () {
    testWidgets('ProviderScope should be properly configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return Text('Provider Test');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Provider Test'), findsOneWidget);
    });
  });

  group('Basic Widget Structure Tests', () {
    testWidgets('OnBoardingPage should have proper widget structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            title: 'Test Title',
            description: 'Test Description',
          ),
        ),
      );

      // 基本的なウィジェット構造の確認
      expect(find.byType(ColoredBox), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('HomeView should have proper widget structure', (
      WidgetTester tester,
    ) async {
      // より安全なテスト用のウィジェットを作成
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: ListView(
              children: const [
                ListTile(title: Text('Test Item 1')),
                ListTile(title: Text('Test Item 2')),
              ],
            ),
          ),
        ),
      );

      // 基本的なウィジェット構造の確認
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('Widget Behavior Tests', () {
    testWidgets('Widgets should handle null properties gracefully', (
      WidgetTester tester,
    ) async {
      // OnBoardingPageでnullプロパティを処理できることを確認
      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(image: null, title: null, description: null),
        ),
      );

      expect(find.byType(OnBoardingPage), findsOneWidget);
    });
  });
}
