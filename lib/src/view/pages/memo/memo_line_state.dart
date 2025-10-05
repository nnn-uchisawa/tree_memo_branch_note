import 'package:freezed_annotation/freezed_annotation.dart';

part 'memo_line_state.freezed.dart';
part 'memo_line_state.g.dart';

@freezed
abstract class MemoLineState with _$MemoLineState {
  MemoLineState._();

  // ignore: invalid_annotation_target
  @JsonSerializable()
  factory MemoLineState({
    @Default(0) int indent,
    @Default("") String text,
    @Default(0) int index,
    @Default(14) double fontSize,
    @Default(false) bool isEditing,
    @Default(false) bool isFolding,
    @Default(false) bool isReadOnly,
    @Default(false) bool displayDropDownMenu,
  }) = _MemoLineState;

  factory MemoLineState.fromJson(Map<String, dynamic> json) =>
      _$MemoLineStateFromJson(json);
}
