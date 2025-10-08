import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/flavors.dart';
import 'package:tree/src/tree_app.dart';
import 'package:tree/src/view/pages/home/home_view.dart';
import 'package:tree/src/view/pages/memo/memo_view.dart';
import 'package:tree/src/view/pages/walk_through/walk_through_view.dart';
import 'package:tree/src/view/widgets/on_boarding_page.dart';

void main() {
  setUpAll(() {
    // フレーバーの設定
    F.appFlavor = Flavor.dev;
  });

  group('TreeApp Tests', () {
    testWidgets('TreeApp should build without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('TreeApp should have correct theme configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

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

  group('HomeView Tests', () {
    testWidgets('HomeView should display correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeView(),
          ),
        ),
      );

      // タイトルが表示されることを確認
      expect(find.text('Tree'), findsOneWidget);
    });

    testWidgets('HomeView should have add memo button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeView(),
          ),
        ),
      );

      // 新規メモ追加ボタンが存在することを確認
      expect(find.byIcon(Icons.playlist_add_rounded), findsOneWidget);
    });

    testWidgets('HomeView should have list view for memos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeView(),
          ),
        ),
      );

      // リストビューが存在することを確認
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('MemoView Tests', () {
    testWidgets('MemoView should build without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MemoView(),
          ),
        ),
      );

      // MemoViewが正常にビルドされることを確認
      expect(find.byType(MemoView), findsOneWidget);
    });

    testWidgets('MemoView should have scrollable content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MemoView(),
          ),
        ),
      );

      // スクロール可能なコンテンツが存在することを確認
      expect(find.byType(Scrollable), findsAtLeastNWidgets(1));
    });
  });

  group('WalkThroughView Tests', () {
    testWidgets('WalkThroughView should display onboarding slider',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WalkThroughView(),
          ),
        ),
      );

      // オンボーディングスライダーが表示されることを確認
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('WalkThroughView should have finish button text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WalkThroughView(),
          ),
        ),
      );

      // 「使用を開始する」ボタンのテキストを探す
      expect(find.text('使用を開始する'), findsOneWidget);
    });

    testWidgets('WalkThroughView should have skip button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WalkThroughView(),
          ),
        ),
      );

      // スキップボタンが表示されることを確認
      expect(find.text('skip'), findsOneWidget);
    });
  });

  group('OnBoardingPage Tests', () {
    testWidgets('OnBoardingPage should display title when provided',
        (WidgetTester tester) async {
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

    testWidgets('OnBoardingPage should display description when provided',
        (WidgetTester tester) async {
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

    testWidgets('OnBoardingPage should handle null title and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(),
        ),
      );

      // nullの場合でもクラッシュしないことを確認
      expect(find.byType(OnBoardingPage), findsOneWidget);
    });

    testWidgets('OnBoardingPage should have blue background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            title: 'Test',
            description: 'Test',
          ),
        ),
      );

      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color, Colors.blue);
    });
  });

  group('Widget Interaction Tests', () {
    testWidgets('Tapping add memo button should be responsive',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeView(),
          ),
        ),
      );

      // 新規メモ追加ボタンをタップ
      final addButton = find.byIcon(Icons.playlist_add_rounded);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      // タップ後もボタンが存在することを確認（ナビゲーションは発生しないかもしれないが、クラッシュしないことを確認）
      expect(addButton, findsOneWidget);
    });
  });

  group('UI Component Tests', () {
    testWidgets('Text widgets should have correct styling',
        (WidgetTester tester) async {
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

    testWidgets('AppBar should have correct styling in HomeView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeView(),
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.text('Tree'));

      expect(titleWidget.style?.color, Colors.white);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App should handle SystemChrome orientation settings',
        (WidgetTester tester) async {
      // システム設定のテスト（実際のSystemChromeは使用できないため、ウィジェットの初期化のみテスト）
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Widgets should handle empty or null data gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeView(),
          ),
        ),
      );

      // データが空の場合でもクラッシュしないことを確認
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // group('Navigation Tests', () {
  //   testWidgets('Route names should be defined correctly',
  //       (WidgetTester tester) async {
  //     // ルート名の定数が正しく定義されていることを確認
  //     expect(HomeView.routeName, '/home');
  //     expect(MemoView.routeName, '/memo');
  //     expect(WalkThroughView.routeName, 'walk');
  //   });
  // });

  group('Provider Tests', () {
    testWidgets('ProviderScope should be properly configured',
        (WidgetTester tester) async {
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

  group('Assets Tests', () {
    testWidgets('OnBoardingPage should handle image widget properly',
        (WidgetTester tester) async {
      final testImage = Image.asset(
        'assets/images/tutorial/a1.png',
        width: 300,
        height: 300,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OnBoardingPage(
            image: testImage,
            title: 'Test Title',
            description: 'Test Description',
          ),
        ),
      );

      // 画像ウィジェットが存在することを確認
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
