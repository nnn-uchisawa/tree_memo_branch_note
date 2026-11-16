import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree/src/util/shared_preference.dart';
import 'package:tree/src/view/pages/settings/settings_view.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreference.init();
  });

  // 現在の設定画面はテーマ設定のみ。認証処理は notifier の単体テストで検証する。
  testWidgets('設定画面にテーマ選択を表示する', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsView())),
    );
    await tester.pumpAndSettle();

    expect(find.text('設定'), findsOneWidget);
    expect(find.text('テーマ設定'), findsOneWidget);
    expect(find.byType(DropdownButton<ThemeMode>), findsOneWidget);
    expect(find.text('システム設定に従う'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in {'ライト': ThemeMode.light, 'ダーク': ThemeMode.dark}.entries) {
    testWidgets('${entry.key}を選択すると設定を保存する', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsView())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key).last);
      await tester.pumpAndSettle();

      expect(await SharedPreference.getThemeMode(), entry.value);
      expect(
        tester
            .widget<DropdownButton<ThemeMode>>(
              find.byType(DropdownButton<ThemeMode>),
            )
            .value,
        entry.value,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('保存済みのテーマ設定を表示する', (tester) async {
    await SharedPreference.setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsView())),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DropdownButton<ThemeMode>>(
            find.byType(DropdownButton<ThemeMode>),
          )
          .value,
      ThemeMode.dark,
    );
  });
}
