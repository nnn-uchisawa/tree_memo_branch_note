import 'package:freezed_annotation/freezed_annotation.dart';

import 'memo_line_state.dart';

part 'memo_state.freezed.dart';
part 'memo_state.g.dart';

@freezed
abstract class MemoState with _$MemoState {
  const MemoState._();

  const factory MemoState({
    @Default("") String fileName,
    @Default([]) List<MemoLineState> list,
    @Default([]) List<MemoLineState> visibleList,
    @Default(20.0) double oneIndent,
    @Default("0") String rnd,
    @Default(false) bool isTapIndentChange,
    @Default(false) bool isEditing,
    @Default(false) bool isTapClear,
    @Default(false) bool isSaveDialogOpen,
    @Default(false) bool needFocusChange,
    @Default(0) int focusedIndex,
    @Default("") String lastUpdated,
  }) = _MemoState;

  factory MemoState.fromJson(Map<String, dynamic> json) =>
      _$MemoStateFromJson(json);
}
