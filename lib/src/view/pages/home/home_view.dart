import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tree/app_router.dart';
import 'package:tree/gen/assets.gen.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/widgets/safe_appbar_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
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
              const MemoRoute().push(context);
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
        itemCount: (homeState.fileNames.length),
        itemBuilder: (context, index) {
          return (homeState.fileNames.isEmpty
              ? LoadingView()
              : Column(
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(homeProvider.notifier)
                            .getMemoState(homeState.fileNames[index])
                            .then((memoState) {
                          ref
                              .read(homeProvider.notifier)
                              .setMemoState(memoState);
                          var context = AppRouter.navigatorKey.currentContext;
                          if (context == null) return;
                          // 特定のページの読み込みのみなので非同期処理を許可
                          // ignore: use_build_context_synchronously
                          MemoRoute().push(context);
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            alignment: Alignment.centerLeft,
                            height: 50,
                            child: Text(
                              homeState.fileNames[index],
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (String value) async {
                              final fileName = homeState.fileNames[index];
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
                ));
        },
      ),
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
          width: AppUtils.sWidth / 2,
          height: AppUtils.sWidth / 2,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
