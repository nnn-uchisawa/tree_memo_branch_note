import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';
import 'package:tree/src/view/pages/settings/settings_notifier.dart';
import 'package:tree/src/view/pages/settings/theme_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    // ローディング状態を監視してダイアログを表示
    ref.listen(authProvider, (previous, next) {
      if (next.isLoading && !(previous?.isLoading ?? false)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      } else if (!next.isLoading && (previous?.isLoading ?? false)) {
        Navigator.of(context).pop(); // ローディングダイアログを閉じる
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // テーマ設定セクション
          _buildSection(
            context,
            title: 'テーマ設定',
            children: [_buildThemeDropdown(context, ref, themeState)],
          ),

          const SizedBox(height: 24),

          // 認証設定セクション（常に表示）
          _buildSection(
            context,
            title: '認証設定',
            children: [_buildAuthSection(context, ref, authState)],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildThemeDropdown(BuildContext context, WidgetRef ref, themeState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<ThemeMode>(
        value: themeState.themeMode,
        isExpanded: true,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('システム設定に従う')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('ライト')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('ダーク')),
        ],
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) {
            ref.read(themeProvider.notifier).setThemeMode(newValue);
          }
        },
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context, WidgetRef ref, authState) {
    return Column(
      children: [
        // プロバイダー別アカウント情報と個別削除
        if (ref.read(settingsProvider.notifier).hasAppleProvider() ||
            ref.read(settingsProvider.notifier).hasGoogleProvider()) ...[
          Text(
            '認証アカウント管理',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
        ],

        if (ref.read(settingsProvider.notifier).hasAppleProvider()) ...[
          _buildProviderAccountInfo(
            context,
            ref,
            provider: 'Apple',
            onDelete: () => ref
                .read(settingsProvider.notifier)
                .showIndividualDeleteDialog(context, ref, 'Apple'),
          ),
          const SizedBox(height: 12),
        ],

        if (ref.read(settingsProvider.notifier).hasGoogleProvider()) ...[
          _buildProviderAccountInfo(
            context,
            ref,
            provider: 'Google',
            onDelete: () => ref
                .read(settingsProvider.notifier)
                .showIndividualDeleteDialog(context, ref, 'Google'),
          ),
        ],

        // ログインしていない場合のメッセージ
        if (!authState.isSignedIn &&
            !ref.read(settingsProvider.notifier).hasAppleProvider() &&
            !ref.read(settingsProvider.notifier).hasGoogleProvider()) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '現在ログインしていません。\nSNS認証を行ってから設定を利用できます。',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProviderAccountInfo(
    BuildContext context,
    WidgetRef ref, {
    required String provider,
    required VoidCallback onDelete,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<int>(
          future: provider == 'Apple'
              ? ref.read(settingsProvider.notifier).getAppleAccountCount()
              : ref.read(settingsProvider.notifier).getGoogleAccountCount(),
          builder: (context, snapshot) {
            final accountCount = snapshot.data ?? 0;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withValues(alpha: 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        provider == 'Apple' ? Icons.apple : Icons.g_mobiledata,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$provider認証',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '登録済みアカウント数: $accountCount個',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authProvider);
                      final isSignedIn = authState.isSignedIn;

                      if (isSignedIn) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '現在ログイン中のアカウントを削除します。\n削除時は再認証が必要です。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.blue.withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('現在のアカウントを削除'),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'アカウント削除にはログインが必要です。\n先にログインしてください。',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.orange.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
