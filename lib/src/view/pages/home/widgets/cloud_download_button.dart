import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/app_router.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';

class CloudDownloadButton extends ConsumerWidget {
  const CloudDownloadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (!authState.isSignedIn) return const SizedBox.shrink();
    return IconButton(
      onPressed: () async {
        await _showCloudDownloadMenu(ref);
      },
      icon: const Icon(Icons.cloud_download, size: 25, color: Colors.white),
      tooltip: 'クラウドから取得',
    );
  }

  Future<void> _showCloudDownloadMenu(WidgetRef ref) async {
    try {
      // App全体の安全なコンテキストを取得
      final safeContext = AppRouter.navigatorKey.currentContext;
      if (safeContext == null || !safeContext.mounted) return;
      // 一覧取得中はローディングでマスク
      final memos = await _withLoading(() async {
        return await ref.read(homeProvider.notifier).fetchCloudMemoNames();
      });
      if (memos.isEmpty) {
        AppUtils.showSnackBar('クラウドにメモがありません');
        return;
      }

      await showModalBottomSheet(
        // 同じコンテキストで開閉するため許可
        // ignore: use_build_context_synchronously
        context: safeContext,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.download_for_offline),
                  title: const Text('一括ダウンロード'),
                  onTap: () async {
                    final navCtx = AppRouter.navigatorKey.currentContext;
                    if (navCtx != null && navCtx.mounted) {
                      Navigator.of(navCtx, rootNavigator: true).pop();
                    }
                    await _withLoading(() async {
                      await ref
                          .read(homeProvider.notifier)
                          .downloadAllMemosFromCloud(memos);
                    });
                  },
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      final name = memos[index];
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cloud_download),
                              onPressed: () async {
                                final navCtx =
                                    AppRouter.navigatorKey.currentContext;
                                if (navCtx != null && navCtx.mounted) {
                                  Navigator.of(
                                    navCtx,
                                    rootNavigator: true,
                                  ).pop();
                                }
                                await _withLoading(() async {
                                  await ref
                                      .read(homeProvider.notifier)
                                      .downloadMemoFromCloud(name);
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                final navCtx =
                                    AppRouter.navigatorKey.currentContext;
                                if (navCtx != null && navCtx.mounted) {
                                  Navigator.of(
                                    navCtx,
                                    rootNavigator: true,
                                  ).pop();
                                }
                                // 確認ダイアログ（共通UIに合わせる）
                                AppUtils.showYesNoDialogAlternativeDestructive(
                                  const Text('削除の確認'),
                                  Text('クラウドから "$name" を削除しますか？'),
                                  () async {
                                    await _withLoading(() async {
                                      await ref
                                          .read(homeProvider.notifier)
                                          .deleteMemoInCloud(name);
                                    });
                                  },
                                  null,
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          final navCtx = AppRouter.navigatorKey.currentContext;
                          if (navCtx != null && navCtx.mounted) {
                            Navigator.of(navCtx, rootNavigator: true).pop();
                          }
                          await _withLoading(() async {
                            await ref
                                .read(homeProvider.notifier)
                                .downloadMemoFromCloud(name);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      AppUtils.showSnackBar('取得に失敗しました: $e');
    }
  }

  // ダウンロード処理は HomeNotifier に委譲

  Future<T> _withLoading<T>(Future<T> Function() task) async {
    // AppRouterのnavigatorKeyから安全なコンテキストを取得
    final safeContext = AppRouter.navigatorKey.currentContext;
    if (safeContext == null || !safeContext.mounted) {
      return await task();
    }
    // モーダルローディング表示（タップブロック）
    showDialog(
      context: safeContext,
      barrierDismissible: false,
      builder: (ctx) {
        return const Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try {
      final result = await task();
      return result;
    } finally {
      final popContext = AppRouter.navigatorKey.currentContext;
      if (popContext != null && popContext.mounted) {
        Navigator.of(popContext, rootNavigator: true).pop();
      }
    }
  }
}
