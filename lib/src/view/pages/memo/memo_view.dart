import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tree/gen/assets.gen.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';
import 'package:tree/src/view/pages/memo/widgets/memo_top_bar_items.dart';
import 'package:tree/src/view/widgets/safe_appbar_view.dart';

import 'memo_line_view.dart';

final memoListscrollControllerProvider =
    Provider.autoDispose<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(controller.dispose);
  return controller;
});

class MemoView extends ConsumerWidget {
  static const routeName = "/memo";

  const MemoView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoProvider);
    ref.read(memoProvider.notifier).syncFocusNodesWithList();
    final nodes = ref.read(memoProvider.notifier).focusNodes;
    final sc = ref.watch(memoListscrollControllerProvider);

    // 戻る処理を共通化
    void handleBackNavigation() {
      final isEditing = ref.read(memoProvider.notifier).isEditing();
      if (isEditing) {
        ref.read(memoProvider.notifier).resetFocusIfFocus();
        ref.read(memoProvider.notifier).resetState();
        AppUtils.showYesNoDialogAlternative(
            const Text("確認"), const Text("編集中ですが、終了してもよろしいですか？"), () {
          Navigator.of(context, rootNavigator: false).pop();
        }, null);
      } else {
        Navigator.of(context, rootNavigator: false).pop();
      }
    }

    return PopScope(
      canPop: false, // Androidのバックボタンを無効化
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          handleBackNavigation();
        }
      },
      child: GestureDetector(
        onTap: () {
          ref.read(memoProvider.notifier).resetState();
        },
        child: SafeAppBarView(
            appBar: AppBar(
              leading: IconButton(
                color: Colors.white,
                icon: Platform.isIOS
                    ? const Icon(Icons.arrow_back_ios)
                    : const Icon(Icons.arrow_back),
                onPressed: handleBackNavigation,
              ),
              titleTextStyle: Theme.of(context).textTheme.titleMedium,
              backgroundColor: Theme.of(context).primaryColor,
              actions: [
                Text(
                  state.list.isNotEmpty &&
                          state.focusedIndex >= 0 &&
                          state.focusedIndex < state.list.length
                      ? (state.focusedIndex + 1).toString()
                      : "-",
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    var i = state.focusedIndex;
                    if (state.list.isNotEmpty &&
                        i - 1 >= 0 &&
                        i - 1 < state.list.length) {
                      final nextIndex = ref
                          .read(memoProvider.notifier)
                          .moveJumpFoldingLine(i, -1);
                      ref
                          .read(memoProvider.notifier)
                          .changeFocusNodeIndex(nextIndex);
                      ref
                          .read(memoProvider.notifier)
                          .focusNodes[nextIndex]
                          .requestFocus();
                    }
                  },
                  icon: SvgPicture.asset(
                    Assets.images.lineUp,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 48,
                    height: 48,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    var i = state.focusedIndex;
                    if (state.list.isNotEmpty &&
                        i + 1 <= state.list.length - 1 &&
                        i + 1 >= 0) {
                      final nextIndex = ref
                          .read(memoProvider.notifier)
                          .moveJumpFoldingLine(i, 1);
                      ref
                          .read(memoProvider.notifier)
                          .changeFocusNodeIndex(nextIndex);
                      ref
                          .read(memoProvider.notifier)
                          .focusNodes[nextIndex]
                          .requestFocus();
                    }
                  },
                  icon: SvgPicture.asset(
                    Assets.images.lineDown,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 48,
                    height: 48,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                MemoTopBarItem(
                  memoLineState: state.list.isNotEmpty &&
                          state.focusedIndex >= 0 &&
                          state.focusedIndex < state.list.length
                      ? state.list[state.focusedIndex]
                      : MemoLineState(),
                ),
                Expanded(
                  child: state.list.isEmpty
                      ? Container(
                          width: AppUtils.sWidth(),
                          height: AppUtils.sHeight(),
                          decoration: const BoxDecoration(),
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [Text("empty")]),
                        )
                      : ListView.builder(
                          clipBehavior: Clip.hardEdge,
                          controller: sc,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.manual,
                          itemCount: state.list.length + 1,
                          itemBuilder: (context, index) {
                            if (index - 1 < 0 ||
                                index - 1 >= state.list.length ||
                                index - 1 >= nodes.length) {
                              return const SizedBox.shrink();
                            }
                            return MemoLineView(
                              memoLineState: state.list[index - 1],
                              oneIndent: state.oneIndent,
                              focusNode: nodes[index - 1],
                            );
                          }),
                ),
              ],
            )),
      ), // PopScopeの閉じ括弧
    );
  }
}
