// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemoState _$MemoStateFromJson(Map<String, dynamic> json) => _MemoState(
  fileName: json['fileName'] as String? ?? "",
  list:
      (json['list'] as List<dynamic>?)
          ?.map((e) => MemoLineState.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  visibleList:
      (json['visibleList'] as List<dynamic>?)
          ?.map((e) => MemoLineState.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  oneIndent: (json['oneIndent'] as num?)?.toDouble() ?? 20.0,
  rnd: json['rnd'] as String? ?? "0",
  isTapIndentChange: json['isTapIndentChange'] as bool? ?? false,
  isEditing: json['isEditing'] as bool? ?? false,
  isTapClear: json['isTapClear'] as bool? ?? false,
  isSaveDialogOpen: json['isSaveDialogOpen'] as bool? ?? false,
  needFocusChange: json['needFocusChange'] as bool? ?? false,
  focusedIndex: (json['focusedIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MemoStateToJson(_MemoState instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'list': instance.list,
      'visibleList': instance.visibleList,
      'oneIndent': instance.oneIndent,
      'rnd': instance.rnd,
      'isTapIndentChange': instance.isTapIndentChange,
      'isEditing': instance.isEditing,
      'isTapClear': instance.isTapClear,
      'isSaveDialogOpen': instance.isSaveDialogOpen,
      'needFocusChange': instance.needFocusChange,
      'focusedIndex': instance.focusedIndex,
    };
