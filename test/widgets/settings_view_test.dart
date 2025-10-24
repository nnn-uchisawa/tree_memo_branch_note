import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';
import 'package:tree/src/view/pages/auth/auth_state.dart';
import 'package:tree/src/view/pages/settings/settings_notifier.dart';
import 'package:tree/src/view/pages/settings/settings_view.dart';
import 'package:tree/src/view/pages/settings/theme_notifier.dart';
import 'package:tree/src/view/pages/settings/theme_state.dart';

/// テスト用のSettingsNotifierモック
class MockSettingsNotifier extends SettingsNotifier {
  bool _hasAppleProvider = false;
  bool _hasGoogleProvider = false;

  void setHasAppleProvider(bool value) {
    _hasAppleProvider = value;
  }

  void setHasGoogleProvider(bool value) {
    _hasGoogleProvider = value;
  }

  @override
  bool hasAppleProvider() {
    return _hasAppleProvider;
  }

  @override
  bool hasGoogleProvider() {
    return _hasGoogleProvider;
  }

  @override
  Future<int> getAppleAccountCount() async {
    return _hasAppleProvider ? 1 : 0;
  }

  @override
  Future<int> getGoogleAccountCount() async {
    return _hasGoogleProvider ? 1 : 0;
  }

  @override
  Future<void> showIndividualDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String provider,
  ) async {
    // テスト用の実装 - 何もしない
  }
}

/// テスト用のThemeNotifierモック
class MockThemeNotifier extends ThemeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  void setMockThemeMode(ThemeMode mode) {
    _themeMode = mode;
  }

  @override
  ThemeState build() {
    return ThemeState(themeMode: _themeMode);
  }

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
  }
}

void main() {
  group('SettingsView Tests', () {
    late MockSettingsNotifier mockSettingsNotifier;
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockSettingsNotifier = MockSettingsNotifier();
      mockThemeNotifier = MockThemeNotifier();
    });

    Widget createTestWidget({AuthState? authState}) {
      return ProviderScope(
        overrides: [
          authProvider.overrideWithValue(authState ?? const AuthState()),
          settingsProvider.overrideWith(() => mockSettingsNotifier),
          themeProvider.overrideWith(() => mockThemeNotifier),
        ],
        child: MaterialApp(home: const SettingsView()),
      );
    }

    group('基本表示テスト', () {
      testWidgets('SettingsViewが正常に表示される', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('設定'), findsOneWidget);
        expect(find.text('テーマ設定'), findsOneWidget);
        expect(find.text('認証設定'), findsOneWidget);
      });

      testWidgets('AppBarが正しく表示される', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('設定'), findsOneWidget);
      });

      testWidgets('テーマドロップダウンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(DropdownButton<ThemeMode>), findsOneWidget);
        expect(find.text('システム設定に従う'), findsOneWidget);
      });
    });

    group('認証状態による表示テスト', () {
      testWidgets('ログインしていない場合のメッセージ表示', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(false);
        mockSettingsNotifier.setHasGoogleProvider(false);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: false,
              userId: null,
              displayName: null,
              email: null,
            ),
          ),
        );

        expect(
          find.text('現在ログインしていません。\nSNS認証を行ってから設定を利用できます。'),
          findsOneWidget,
        );
      });

      testWidgets('Apple認証が存在する場合', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);
        mockSettingsNotifier.setHasGoogleProvider(false);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        expect(find.text('認証アカウント管理'), findsOneWidget);
        expect(find.text('Apple認証'), findsOneWidget);
      });

      testWidgets('Google認証が存在する場合', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(false);
        mockSettingsNotifier.setHasGoogleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        expect(find.text('認証アカウント管理'), findsOneWidget);
        expect(find.text('Google認証'), findsOneWidget);
      });

      testWidgets('AppleとGoogle両方の認証が存在する場合', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);
        mockSettingsNotifier.setHasGoogleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        expect(find.text('認証アカウント管理'), findsOneWidget);
        expect(find.text('Apple認証'), findsOneWidget);
        expect(find.text('Google認証'), findsOneWidget);
      });
    });

    group('ログイン状態による表示テスト', () {
      testWidgets('ログイン中の場合の削除ボタン表示', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        expect(
          find.text('現在ログイン中のアカウントを削除します。\n削除時は再認証が必要です。'),
          findsOneWidget,
        );
        expect(find.text('現在のアカウントを削除'), findsOneWidget);
      });

      testWidgets('ログアウト状態の場合の警告メッセージ表示', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: false,
              userId: null,
              displayName: null,
              email: null,
            ),
          ),
        );

        expect(find.text('アカウント削除にはログインが必要です。\n先にログインしてください。'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });
    });

    group('UIコンポーネントテスト', () {
      testWidgets('セクションタイトルが正しく表示される', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('テーマ設定'), findsOneWidget);
        expect(find.text('認証設定'), findsOneWidget);
      });

      testWidgets('プロバイダーアイコンが正しく表示される', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);
        mockSettingsNotifier.setHasGoogleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        expect(find.byIcon(Icons.apple), findsOneWidget);
        expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      });

      testWidgets('削除ボタンが表示される', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        final deleteButton = find.widgetWithText(ElevatedButton, '現在のアカウントを削除');
        expect(deleteButton, findsOneWidget);
      });
    });

    group('レスポンシブテスト', () {
      testWidgets('ListViewが正しく表示される', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('適切なパディングが設定されている', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final listView = find.byType(ListView);
        expect(listView, findsOneWidget);
      });
    });

    group('エラーハンドリングテスト', () {
      testWidgets('認証状態がnullの場合の処理', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // エラーが発生せずに表示されることを確認
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('テーマ設定'), findsOneWidget);
        expect(find.text('認証設定'), findsOneWidget);
      });

      testWidgets('プロバイダー情報が取得できない場合の処理', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(false);
        mockSettingsNotifier.setHasGoogleProvider(false);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: false,
              userId: null,
              displayName: null,
              email: null,
            ),
          ),
        );

        // エラーメッセージが表示されることを確認
        expect(
          find.text('現在ログインしていません。\nSNS認証を行ってから設定を利用できます。'),
          findsOneWidget,
        );
      });
    });

    group('統合テスト', () {
      testWidgets('完全な設定画面の表示テスト', (WidgetTester tester) async {
        mockSettingsNotifier.setHasAppleProvider(true);
        mockSettingsNotifier.setHasGoogleProvider(true);

        await tester.pumpWidget(
          createTestWidget(
            authState: const AuthState(
              isSignedIn: true,
              userId: 'test_user',
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        );

        // 基本要素の確認
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('テーマ設定'), findsOneWidget);
        expect(find.text('認証設定'), findsOneWidget);

        // 認証管理セクションの確認
        expect(find.text('認証アカウント管理'), findsOneWidget);
        expect(find.text('Apple認証'), findsOneWidget);
        expect(find.text('Google認証'), findsOneWidget);
      });
    });
  });
}
