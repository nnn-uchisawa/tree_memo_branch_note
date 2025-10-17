import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/app_router.dart';
import 'package:tree/src/services/file/file_service.dart';
import 'package:tree/src/util/app_const.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/widgets/adaptive_text_field.dart';

import 'memo_state.dart';

part 'memo_notifier.g.dart';

@riverpod
class MemoNotifier extends _$MemoNotifier {
  MemoState baseState = MemoState();
  final List<FocusNode> _focusNodes = [];
  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, GlobalKey> _dividerKeys = {};

  List<FocusNode> get focusNodes => _focusNodes;

  /// TextEditingControllerを取得または作成
  TextEditingController getTextController(int index) {
    if (!_textControllers.containsKey(index)) {
      final controller = TextEditingController(
        text: index < state.list.length ? state.list[index].text : '',
      );
      _textControllers[index] = controller;
    }
    return _textControllers[index]!;
  }

  /// GlobalKeyを取得または作成
  GlobalKey getDividerKey(int index) {
    if (!_dividerKeys.containsKey(index)) {
      final key = GlobalKey(debugLabel: "memolinekey:$index");
      _dividerKeys[index] = key;
    }
    return _dividerKeys[index]!;
  }

  /// コントローラーとキーをクリーンアップ
  void cleanupControllersAndKeys() {
    // 不要になったコントローラーを破棄
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    _dividerKeys.clear();
  }

  @override
  MemoState build() {
    var home = ref.watch(homeProvider);
    var memo = home.memoState;
    memo ??= MemoState(
      list: [MemoLineState(index: 0)],
      visibleList: [MemoLineState(index: 0)],
    );
    baseState = memo.copyWith();
    return memo;
  }

  @override
  bool updateShouldNotify(MemoState previous, MemoState next) {
    return !state.isEditing &&
        !state.isSaveDialogOpen &&
        super.updateShouldNotify(previous, next);
  }

  void setBaseState({bool setFocusIndex = false}) {
    if (setFocusIndex) {
      baseState = state.copyWith(focusedIndex: -1);
    } else {
      baseState = state.copyWith();
    }
  }

  /// メモの行の値が含まれたStateObjectの配列から閉じている行を再帰的に探して不可視な行を削除し返却する（プライベート）
  List<MemoLineState> _getFoldingLineList(
    List<MemoLineState> list,
    int parentIndex,
  ) {
    if (list.isEmpty) {
      return [];
    }
    var nextParent = parentIndex + 1;

    if (list[parentIndex].isFolding) {
      for (
        int targetIndex = parentIndex + 1;
        targetIndex < list.length;
        targetIndex++, nextParent++
      ) {
        if (targetIndex < list.length) {
          if (list[targetIndex].indent > list[parentIndex].indent) {
            list.removeAt(targetIndex);
            //for loopで++されると1行飛ばしてしまうので巻き戻す
            targetIndex--;
          } else {
            nextParent = targetIndex;
            break;
          }
        } else {
          break;
        }
      }
    }

    if (nextParent < list.length) {
      list = _getFoldingLineList(list, nextParent);
    }
    return list;
  }

  int _getFoldingEnd(int start) {
    List<MemoLineState> list = List.from(state.list);
    if (list.isEmpty) {
      return -1;
    }
    var next = start + 1;
    var end = start;
    if (list[start].isFolding) {
      for (
        int targetIndex = start + 1;
        targetIndex < list.length;
        targetIndex++, next++
      ) {
        if (targetIndex < list.length) {
          if (list[targetIndex].indent > list[start].indent) {
            list.removeAt(targetIndex);
            //for loopで++されると1行飛ばしてしまうので巻き戻す
            end++;
            targetIndex--;
          } else {
            // next = targetIndex;
            break;
          }
        } else {
          break;
        }
      }
    }
    return end + 1;
  }

  int moveJumpFoldingLine(int fromIndex, int visibleDistance) {
    if (visibleDistance == 0 ||
        fromIndex == -1 ||
        (fromIndex == 0 && visibleDistance < 0)) {
      return fromIndex;
    }

    List<MemoLineState> list = List.from(state.list);
    final startIndent = list[fromIndex].indent;
    var destination = fromIndex;
    var count = 0;
    final foldingEnd = list[fromIndex].isFolding
        ? _getFoldingEnd(fromIndex)
        : fromIndex + 1;
    if (foldingEnd == list.length && visibleDistance > 0) return fromIndex;
    var subList = list.sublist(fromIndex, foldingEnd);
    if (0 > visibleDistance && fromIndex + visibleDistance >= 0) {
      for (var s in list.sublist(0, fromIndex).reversed) {
        if (count++ == 0 && s.indent <= startIndent && !s.isFolding) {
          destination = fromIndex - 1;
          break;
        } else if (s.indent > startIndent) {
          continue;
        } else if (s.isFolding) {
          destination = s.index;
          break;
        } else {
          destination = fromIndex - 1;
          break;
        }
      }

      list.removeRange(fromIndex, foldingEnd);
      var destIndex = list.indexWhere((s) => s.index == destination);
      destIndex = destIndex == -1 ? fromIndex - 1 : destIndex;
      list.insertAll(destIndex, subList);
      for (var i = 0; i < list.length; i++) {
        list[i] = list[i].copyWith(index: i);
      }
      final newVisibleList = _getFoldingLineList(List.from(list), 0);
      state = state.copyWith(list: list, visibleList: newVisibleList);
      return destIndex;
    } else if (0 < visibleDistance &&
        fromIndex + visibleDistance < list.length) {
      final nextfoldingEnd = list[foldingEnd].isFolding
          ? _getFoldingEnd(foldingEnd)
          : foldingEnd + 1;
      destination = nextfoldingEnd - 1;

      list.removeRange(fromIndex, foldingEnd);
      final destIndex = list.indexWhere((s) => s.index == destination) + 1;
      list.insertAll(destIndex, subList);
      for (var i = 0; i < list.length; i++) {
        list[i] = list[i].copyWith(index: i);
      }
      final newVisibleList = _getFoldingLineList(List.from(list), 0);
      state = state.copyWith(list: list, visibleList: newVisibleList);
      return destIndex;
    } else {
      return fromIndex;
    }
  }

  void addLineToLast() {
    List<MemoLineState> list = List.from(state.list);
    List<MemoLineState> newList = [
      ...list,
      MemoLineState(index: state.list.length),
    ];
    var newNode = FocusNode();
    addFocusNode(newNode);
    List<MemoLineState> visibleList = _getFoldingLineList(
      List.from(newList),
      0,
    );
    state = state.copyWith(
      list: newList,
      visibleList: visibleList,
      focusedIndex: visibleList.length - 1,
      needFocusChange: true,
      isEditing: false,
    );
    state = state.copyWith(isEditing: true);
  }

  void addLineToNext(int index) {
    var next = index + 1;
    List<MemoLineState> list = List.from(state.list);
    for (int i = next; i < list.length; i++) {
      list[i] = list[i].copyWith(index: list[i].index + 1);
    }
    List<MemoLineState> front = index == 0
        ? [list[0]]
        : [...list.sublist(0, index + 1)];
    var newLine = MemoLineState(index: next, indent: list[index].indent);
    var back = (list.length - 1) == index ? [] : [...list.sublist(next)];
    var newNode = FocusNode();
    insertFocusNode(next, newNode);
    List<MemoLineState> newList = [...front, newLine, ...back];
    List<MemoLineState> visibleList = _getFoldingLineList(
      List.from(newList),
      0,
    );
    state = state.copyWith(
      list: newList,
      visibleList: visibleList,
      isEditing: false,
      focusedIndex: next,
      needFocusChange: true,
    );
    state = state.copyWith(isEditing: true);
  }

  void onChangeFontSize(int index, double fontSize) {
    List<MemoLineState> list = List.from(state.list);
    MemoLineState memoLineState = list[index];
    memoLineState = memoLineState.copyWith(fontSize: fontSize);

    // 更新されたメモラインをリスト内の正しい位置に配置
    list[index] = memoLineState;

    List<MemoLineState> newList = List.from(list);
    List<MemoLineState> visibleList = _getFoldingLineList(
      List.from(newList),
      0,
    );
    state = state.copyWith(list: list, visibleList: visibleList);
  }

  Function(DragEndDetails dragEndDetails) onHorizontalSwiped(int index) {
    return (dragEndDetails) {
      List<MemoLineState> list = List.from(state.list);
      MemoLineState memoLineState = list[index];

      if (dragEndDetails.velocity.pixelsPerSecond.dx > 20 &&
          memoLineState.indent < 10) {
        memoLineState = memoLineState.copyWith(
          indent: memoLineState.indent + 1,
        );
      } else if (dragEndDetails.velocity.pixelsPerSecond.dx < -20 &&
          memoLineState.indent > 0) {
        memoLineState = memoLineState.copyWith(
          indent: memoLineState.indent - 1,
        );
      }

      // 更新されたメモラインをリスト内の正しい位置に配置
      list[index] = memoLineState;

      List<MemoLineState> newList = List.from(list);
      List<MemoLineState> visibleList = _getFoldingLineList(
        List.from(newList),
        0,
      );
      state = state.copyWith(list: list, visibleList: visibleList);
    };
  }

  Function() onChangeIndent(int index, int quantity) {
    return () {
      List<MemoLineState> list = state.list.toList();
      MemoLineState memoLineState = list[index];
      if (memoLineState.indent + quantity < 0 ||
          memoLineState.indent + quantity > 10) {
        return;
      }
      memoLineState = memoLineState.copyWith(
        indent: memoLineState.indent + quantity,
      );
      list[index] = memoLineState;

      List<MemoLineState> newList = List.from(list);
      List<MemoLineState> visibleList = _getFoldingLineList(
        List.from(newList),
        0,
      );
      state = state.copyWith(list: list, visibleList: visibleList);
    };
  }

  Function(String text) onTextChange(int index) {
    return (text) {
      List<MemoLineState> list = List.from(state.list);
      MemoLineState memoLineState = list[index];

      memoLineState = memoLineState.copyWith(text: text);

      // 更新されたメモラインをリスト内の正しい位置に配置
      list[index] = memoLineState;

      List<MemoLineState> newList = List.from(list);
      List<MemoLineState> visibleList = _getFoldingLineList(
        List.from(newList),
        0,
      );
      state = state.copyWith(
        list: list,
        visibleList: visibleList,
        isEditing: true,
      );
    };
  }

  void onTextChangeEnd() {
    state = state.copyWith(isEditing: false);
  }

  void changeState() async {
    state = state.copyWith(rnd: AppUtils.getRandomString());
  }

  void upDown() {
    state = state.copyWith(isTapIndentChange: false, isTapClear: false);
  }

  void resetStateWithoutFIndex() {
    state = state.copyWith(
      isEditing: false,
      isTapIndentChange: false,
      isTapClear: false,
    );
  }

  void resetState() {
    state = state.copyWith(
      isEditing: false,
      isTapIndentChange: false,
      isTapClear: false,
      focusedIndex: -1,
    );
  }

  void showAlertDeleteLine(int index) {
    resetFocusIfFocus();
    resetState();
    AppUtils.showYesNoDialogAlternativeDestructive(
      Text("確認"),
      Text("この行を削除してもよろしいですか？"),
      () {
        deleteLine(index);
      },
      null,
    );
  }

  void deleteLine(int index) {
    if (state.list.length - 1 < index) return;
    List<MemoLineState> list = List.from(state.list);
    list.removeAt(index);
    for (int i = 0; i < list.length; i++) {
      if (i == index) {
        list[i] = list[i].copyWith(index: i);
      }
    }
    removeFocusNode(index);
    if (list.isNotEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (list.isNotEmpty) {
      _focusNodes[index].requestFocus();
    }
    List<MemoLineState> visibleList = _getFoldingLineList(List.from(list), 0);
    if (index != 0) {
      state = state.copyWith(
        list: list,
        visibleList: visibleList,
        focusedIndex: index,
      );
    } else if (_focusNodes.isNotEmpty) {
      state = state.copyWith(
        list: list,
        visibleList: visibleList,
        focusedIndex: index,
      );
    } else {
      state = state.copyWith(
        list: list,
        visibleList: visibleList,
        focusedIndex: -1,
      );
    }
  }

  void addFocusNode(FocusNode node) {
    _focusNodes.add(node);
  }

  void insertFocusNode(int index, FocusNode node) {
    _focusNodes.insert(index, node);
  }

  void removeFocusNode(int index) {
    _focusNodes.removeAt(index);
  }

  void updateFocusNodes(List<FocusNode> nodes) {
    _focusNodes
      ..clear()
      ..addAll(nodes);
  }

  Function() toggleFoldingStatus(int index) {
    return () {
      List<MemoLineState> list = List.from(state.list);
      list[index] = list[index].copyWith(isFolding: !list[index].isFolding);

      setTrueNeedFocusChangeStatus();
      List<MemoLineState> newList = List.from(list);
      List<MemoLineState> visibleList = _getFoldingLineList(
        List.from(newList),
        0,
      );
      state = state.copyWith(
        list: list,
        visibleList: visibleList,
        isEditing: false,
      );
    };
  }

  Function() toggleReadOnlyStatus(int index) {
    return () {
      List<MemoLineState> list = List.from(state.list);
      list[index] = list[index].copyWith(isReadOnly: !list[index].isReadOnly);

      List<MemoLineState> newList = List.from(list);
      List<MemoLineState> visibleList = _getFoldingLineList(newList, 0);

      state = state.copyWith(list: list, visibleList: visibleList);
    };
  }

  void toggleIndentChangeStatus() {
    // if(isInit) return;

    state = state.copyWith(isTapIndentChange: !state.isTapIndentChange);
  }

  void toggleClearStatus() {
    // if(isInit) return;
    state = state.copyWith(isTapClear: !state.isTapClear);
  }

  void clearCancel() {
    state = state.copyWith(isTapClear: false);
  }

  void clearYes() {
    state = state.copyWith(list: [], isTapClear: false);
    _focusNodes.clear();
    setBaseState(setFocusIndex: true);
  }

  /// listとnodesの長さが不一致の場合にnodesを補正する
  void syncFocusNodesWithList() {
    if (state.list.length != _focusNodes.length) {
      _focusNodes.clear();
      for (int i = 0; i < state.list.length; i++) {
        _focusNodes.add(FocusNode());
      }
    }
  }

  void saveCancel(TextEditingController tec) {
    state = state.copyWith(isSaveDialogOpen: false);
  }

  void saveYes(
    TextEditingController tec,
    String fileName,
    Function handler,
  ) async {
    try {
      state = state.copyWith(isSaveDialogOpen: false);

      // ファイル名の検証
      final newFileName = tec.text.trim();
      if (newFileName.isEmpty) {
        AppUtils.showSnackBar("ファイル名を入力してください");
        return;
      }

      // 無効な文字のチェック
      final invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
      if (invalidChars.any((char) => newFileName.contains(char))) {
        AppUtils.showSnackBar("ファイル名に無効な文字が含まれています");
        return;
      }

      // ファイル名が変更された場合の処理
      if (fileName.isNotEmpty && fileName != newFileName) {
        await renameFile(fileName, newFileName);
      } else {
        // 新規作成または同じファイル名での保存
        await _saveJsonToFile(tec);
      }

      handler();
      setBaseState();
      AppUtils.showSnackBar("ファイルを保存しました");
    } catch (e) {
      log('saveYes エラー: $e');
      AppUtils.showSnackBar("保存に失敗しました: ${e.toString()}");
    }
  }

  void showSliderIndentChangeDialog() {
    resetFocusIfFocus();
    resetState();
    var context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromARGB(127, 0, 0, 0),
        child: SizedBox(
          width: 200,
          child: SizedBox(
            height: AppUtils.sHeight / 4,
            child: Stack(
              children: [
                Consumer(
                  builder: (c, r, w) {
                    return Slider(
                      activeColor: Colors.blue,
                      thumbColor: Colors.blueAccent,
                      divisions:
                          AppConst.maxIndentWidth.toInt() -
                          AppConst.minIndentWidth.toInt(),
                      max: AppConst.maxIndentWidth,
                      min: AppConst.minIndentWidth,
                      value: r.watch(memoProvider).oneIndent,
                      onChanged: (v) {
                        onChangeOneIndent(v);
                      },
                    );
                  },
                ),
                // ステップ数表示
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Consumer(
                    builder: (c, r, w) {
                      final currentValue = r.watch(memoProvider).oneIndent;
                      final stepCount =
                          (currentValue - AppConst.minIndentWidth + 1).toInt();
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .3),
                            ),
                          ),
                          child: Text(
                            stepCount.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  child: Consumer(
                    builder: (c, r, w) {
                      return TextButton(
                        onPressed: r.read(memoProvider.notifier).resetIndent,
                        child: Text(
                          "reset",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetIndent() {
    state = state.copyWith(oneIndent: 20.0);
  }

  void showSliderFontSizeChangeDialog() {
    resetStateWithoutFIndex();
    if (state.focusedIndex == -1) return;
    var context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromARGB(127, 0, 0, 0),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              SizedBox(
                height: AppUtils.sHeight / 4,
                child: Consumer(
                  builder: (c, r, w) {
                    var index = state.focusedIndex;
                    return Slider(
                      activeColor: Colors.blue,
                      thumbColor: Colors.blueAccent,
                      divisions:
                          AppConst.maxFontSize.toInt() -
                          AppConst.minFontSize.toInt(),
                      max: AppConst.maxFontSize,
                      min: AppConst.minFontSize,
                      value: r.watch(memoProvider).list[index].fontSize,
                      onChanged: (v) {
                        onChangeFontSize(index, v);
                      },
                    );
                  },
                ),
              ),
              // ステップ数表示
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Consumer(
                  builder: (c, r, w) {
                    var index = state.focusedIndex;
                    final currentValue = r
                        .watch(memoProvider)
                        .list[index]
                        .fontSize;
                    final stepCount = (currentValue - AppConst.minFontSize + 1)
                        .toInt();
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .3),
                          ),
                        ),
                        child: Text(
                          stepCount.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                child: Consumer(
                  builder: (c, r, w) {
                    return TextButton(
                      onPressed: r.read(memoProvider.notifier).resetFontSize,
                      child: Text(
                        "reset",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetFontSize() {
    if (state.focusedIndex == -1) return;
    List<MemoLineState> list = List.from(state.list);
    var index = state.focusedIndex;
    var memoLineState = list[index];
    memoLineState = memoLineState.copyWith(fontSize: 14);
    list.replaceRange(index, index + 1, [memoLineState]);
    state = state.copyWith(list: list);
    resetStateWithoutFIndex();
  }

  Future<void> showClearDialogs() async {
    if (AppRouter.navigatorKey.currentContext != null) {
      resetFocusIfFocus();
      resetState();
      await Future.delayed(Duration(milliseconds: 10));
      AppUtils.showYesNoDialogAlternativeDestructive(
        const Text("確認"),
        const Text("すべてのメモをクリアしてもよろしいですか？"),
        () {
          clearYes();
          changeFocusNodeIndex(-1);
        },
        () {
          clearCancel();
        },
      );
    }
  }

  void onChangeOneIndent(double indent) {
    state = state.copyWith(oneIndent: indent);
  }

  Future<void> _saveJsonToFile(TextEditingController controller) async {
    try {
      final fileName = controller.text.trim();
      if (fileName.isEmpty) {
        throw Exception("ファイル名が空です");
      }

      var j = state.toJson();
      var dir = await getApplicationDocumentsDirectory();
      var path = '${dir.path}/$fileName.tmson';
      var file = File(path);

      // JSONエンコードのチェック
      String jsonString;
      try {
        jsonString = json.encode(j);
      } catch (e) {
        throw Exception("データのJSONエンコードに失敗しました: $e");
      }

      // ファイル書き込み
      await file.writeAsString(jsonString);

      // ファイルが正常に書き込まれたかチェック
      if (!await file.exists()) {
        throw Exception("ファイルの作成に失敗しました");
      }

      await ref.read(homeProvider.notifier).updateFileNames();
      log('ファイル保存成功: $path');
    } catch (e) {
      log('_saveJsonToFile エラー: $e');
      throw Exception("ファイル保存エラー: $e");
    }
  }

  Future<void> deleteFileFromName(String displayName) async {
    try {
      if (displayName.trim().isEmpty) {
        log('deleteFileFromName: ファイル名が空のためスキップ');
        return;
      }

      await FileService.deleteFileByDisplayName(displayName);
      log('ファイル削除成功: $displayName');
    } catch (e) {
      log('deleteFileFromName エラー: $e');
      // ファイル削除エラーは致命的ではないため、例外を再スローしない
    }
  }

  Future<void> renameFile(String oldDisplayName, String newDisplayName) async {
    try {
      if (oldDisplayName.trim().isEmpty || newDisplayName.trim().isEmpty) {
        throw Exception("ファイル名が空です");
      }

      // 古いファイルが存在するかチェック
      try {
        await FileService.loadMemoStateFromDisplayName(oldDisplayName);
      } catch (e) {
        throw Exception("古いファイルが見つかりません: $oldDisplayName");
      }

      // コピーしてから古いファイルを削除する方式でリネーム
      await FileService.copyFileByDisplayName(oldDisplayName);

      // 新しいファイル名で保存
      await _saveJsonToFileWithName(newDisplayName);

      // 古いファイルを削除
      await FileService.deleteFileByDisplayName(oldDisplayName);

      await ref.read(homeProvider.notifier).updateFileNames();
      log('ファイルリネーム成功: $oldDisplayName -> $newDisplayName');
    } catch (e) {
      log('renameFile エラー: $e');
      throw Exception("ファイルリネームエラー: $e");
    }
  }

  Future<void> _saveJsonToFileWithName(String displayName) async {
    try {
      await FileService.saveMemoStateWithDisplayName(state, displayName);
    } catch (e) {
      log('_saveJsonToFileWithName エラー: $e');
      throw Exception("ファイル保存エラー: $e");
    }
  }

  Future<void> showSaveDialog(Function() handler) async {
    resetFocusIfFocus();
    resetState();
    state = state.copyWith(isSaveDialogOpen: true);
    var fileName = state.fileName;
    var title = const Text("ファイル保存");
    var textEditingController = TextEditingController.fromValue(
      TextEditingValue(text: state.fileName),
    );
    var content = AdaptiveTextField(
      placeholder: "ファイル名",
      onChanged: (String text) {
        state = state.copyWith(fileName: text);
      },
      controller: textEditingController,
    );

    await Future.delayed(Duration(milliseconds: 10));
    AppUtils.showYesNoDialogAlternativeTECArg(
      title,
      content,
      (tec) {
        state = state.copyWith(isSaveDialogOpen: false);
        saveYes(tec, fileName, handler);
      },
      (tec) {
        saveCancel(tec);
      },
      textEditingController,
    );
  }

  /// クラウドに保存
  Future<void> saveToCloud() async {
    try {
      final authState = ref.read(authProvider);
      if (!authState.isSignedIn) {
        AppUtils.showSnackBar('ログインが必要です');
        return;
      }

      // 現在のメモをローカルに保存
      final displayName = state.fileName;
      if (displayName.isEmpty) {
        AppUtils.showSnackBar('ファイル名を設定してください');
        return;
      }

      // home_notifierのuploadMemoToCloudを使用（表示名ベース）
      await ref.read(homeProvider.notifier).uploadMemoToCloud(displayName);
    } catch (e) {
      AppUtils.showSnackBar('クラウド保存に失敗しました: ${e.toString()}');
    }
  }

  void resetFocusIfFocus() {
    if (state.focusedIndex >= 0) {
      for (var v in _focusNodes) {
        v.unfocus();
      }
      List<MemoLineState> list = List.from(state.list);
      state = state.copyWith(list: list, focusedIndex: -1);
    }
  }

  void setTrueNeedFocusChangeStatus() {
    state = state.copyWith(needFocusChange: true);
  }

  void changeFocusNodeIndex(int index) {
    state = state.copyWith(focusedIndex: index, needFocusChange: true);
  }

  bool isEditing() {
    return baseState.list.toString() != state.list.toString();
  }
}
