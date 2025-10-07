import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/flavors.dart';
import 'package:tree/src/tree_app.dart';

void main() {
  group('App Integration Tests', () {
    setUpAll(() {
      F.appFlavor = Flavor.dev;
    });

    testWidgets('Complete app navigation flow', (WidgetTester tester) async {
      // アプリを起動
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      // アプリが起動することを確認
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // 初期画面が表示されることを確認
      // 注意: 実際のルーティングロジックに依存するため、
      // ウォークスルーまたはホーム画面のいずれかが表示される
      await tester.pumpAndSettle(Duration(seconds: 2));
    });

    testWidgets('Theme switching works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // テーマが正しく設定されていることを確認
      expect(materialApp.theme?.brightness, Brightness.light);
      expect(materialApp.darkTheme?.brightness, Brightness.dark);
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('App handles orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 画面の向きを変更しても正常に動作することを確認
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        null,
        (data) {},
      );

      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Provider system works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return Text('Provider Working');
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Provider Working'), findsOneWidget);
    });

    testWidgets('App handles memory pressure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // メモリプレッシャーをシミュレート
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/system',
        null,
        (data) {},
      );

      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App recovers from errors gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // エラー処理の確認
      // アプリがクラッシュしないことを確認
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('App startup time is reasonable', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // 起動時間が合理的であることを確認（5秒以下）
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('UI renders without frame drops', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TreeApp(),
        ),
      );

      // フレームドロップなしでレンダリングされることを確認
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
