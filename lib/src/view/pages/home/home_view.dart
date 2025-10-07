import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tree/app_router.dart';
import 'package:tree/gen/assets.gen.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/memo/memo_view.dart';
import 'package:tree/src/view/widgets/safe_appbar_view.dart';

class HomeView extends ConsumerWidget {
  static const routeName = '/home';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileNamesState = ref.watch(fileNamesFutureProvider).value;
    ref.watch(homeProvider);
    return SafeAppBarView(
      appBar: AppBar(
        title: Text(
          'Tree',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () async {
                final fileInfo =
                    await ref.read(homeProvider.notifier).pickFileAndGetInfo();
                if (fileInfo == null) {
                  AppUtils.showSnackBar('有効なファイルを選択してください');
                  return;
                }
                final file = fileInfo['file'] as File;
                final fileName = fileInfo['fileName'] as String;
                final fileExtension = fileInfo['fileExtension'] as String;
                final fileSizeKB = fileInfo['fileSizeKB'] as String;
                AppUtils.showYesNoDialogAlternative(
                  const Text("確認"),
                  Text(
                      "$fileName($fileExtension)\nファイルサイズ: ${fileSizeKB}KB\n\nインポートしますか？"),
                  () {
                    ref.read(homeProvider.notifier).saveFileToDocuments(file);
                  },
                  null,
                );
              },
              icon: SvgPicture.asset(
                Assets.images.folder,
                width: 25,
                height: 25,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )),
          TextButton(
            onPressed: () {
              ref.read(homeProvider.notifier).setMemoState(null);
              const MemoRoute().go(context);
            },
            child: Icon(
              Icons.playlist_add_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: (fileNamesState?.length ?? 0),
          itemBuilder: (context, index) {
            return (fileNamesState?.length ?? 0) == 0
                ? LoadingView()
                : Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          ref
                              .read(homeProvider.notifier)
                              .getMemoState(fileNamesState?[index] ?? "")
                              .then((memoState) {
                            ref
                                .read(homeProvider.notifier)
                                .setMemoState(memoState);
                            AppRouter.navigatorKey.currentContext!
                                .push(MemoView.routeName, extra: memoState);
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 20),
                              alignment: Alignment.centerLeft,
                              height: 50,
                              child: Text(
                                fileNamesState?[index] ?? "",
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (String value) async {
                                final fileName = fileNamesState?[index] ?? "";
                                switch (value) {
                                  case 'copy':
                                    AppUtils.showYesNoDialogAlternative(
                                      const Text('コピーの確認'),
                                      Text('"$fileName" をコピーしますか？'),
                                      () async {
                                        await ref
                                            .read(homeProvider.notifier)
                                            .copyFile(fileName);
                                      },
                                      null,
                                    );
                                    break;
                                  case 'share':
                                    var dir =
                                        await getApplicationDocumentsDirectory();
                                    var _ = await AppUtils.shareFile(
                                        '${dir.path}/$fileName.tmson');
                                    break;
                                  case 'export':
                                    await ref
                                        .read(homeProvider.notifier)
                                        .exportFileAsTxt(fileName);
                                    break;
                                  case 'clipboard':
                                    await ref
                                        .read(homeProvider.notifier)
                                        .copyToClipboard(fileName);
                                    break;
                                  case 'delete':
                                    AppUtils.showYesNoDialogAlternative(
                                      const Text('削除の確認'),
                                      Text('"$fileName" を削除しますか？'),
                                      () async {
                                        await ref
                                            .read(homeProvider.notifier)
                                            .deleteFileFromName(fileName);
                                        ref.invalidate(fileNamesFutureProvider);
                                      },
                                      null,
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'copy',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy, size: 20),
                                      SizedBox(width: 8),
                                      Text('コピーを作成'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share, size: 20),
                                      SizedBox(width: 8),
                                      Text('メモを共有'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'export',
                                  child: Row(
                                    children: [
                                      Icon(Icons.file_download, size: 20),
                                      SizedBox(width: 8),
                                      Text('txtで共有'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'clipboard',
                                  child: Row(
                                    children: [
                                      Icon(Icons.content_copy, size: 20),
                                      SizedBox(width: 8),
                                      Text('クリップボードにコピー'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('削除',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              icon: SvgPicture.asset(
                                Assets.images.verticalThree,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onSurface,
                                    BlendMode.srcIn),
                                width: 20,
                                height: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey,
                        height: 0.5,
                        indent: 20,
                      ),
                    ],
                  );
          }),
    );
  }
}

class LoadingView extends ConsumerWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Center(
        child: SizedBox(
          width: AppUtils.sWidth() / 2,
          height: AppUtils.sWidth() / 2,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
