// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_line_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemoLineState _$MemoLineStateFromJson(Map<String, dynamic> json) =>
    _MemoLineState(
      indent: (json['indent'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? "",
      index: (json['index'] as num?)?.toInt() ?? 0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14,
      isEditing: json['isEditing'] as bool? ?? false,
      isFolding: json['isFolding'] as bool? ?? false,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$MemoLineStateToJson(_MemoLineState instance) =>
    <String, dynamic>{
      'indent': instance.indent,
      'text': instance.text,
      'index': instance.index,
      'fontSize': instance.fontSize,
      'isEditing': instance.isEditing,
      'isFolding': instance.isFolding,
      'isReadOnly': instance.isReadOnly,
    };
