// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoState {

 String get fileName; List<MemoLineState> get list; List<MemoLineState> get visibleList; double get oneIndent; String get rnd; bool get isTapIndentChange; bool get isEditing; bool get isTapClear; bool get isSaveDialogOpen; bool get needFocusChange; int get focusedIndex;
/// Create a copy of MemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoStateCopyWith<MemoState> get copyWith => _$MemoStateCopyWithImpl<MemoState>(this as MemoState, _$identity);

  /// Serializes this MemoState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoState&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.list, list)&&const DeepCollectionEquality().equals(other.visibleList, visibleList)&&(identical(other.oneIndent, oneIndent) || other.oneIndent == oneIndent)&&(identical(other.rnd, rnd) || other.rnd == rnd)&&(identical(other.isTapIndentChange, isTapIndentChange) || other.isTapIndentChange == isTapIndentChange)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.isTapClear, isTapClear) || other.isTapClear == isTapClear)&&(identical(other.isSaveDialogOpen, isSaveDialogOpen) || other.isSaveDialogOpen == isSaveDialogOpen)&&(identical(other.needFocusChange, needFocusChange) || other.needFocusChange == needFocusChange)&&(identical(other.focusedIndex, focusedIndex) || other.focusedIndex == focusedIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileName,const DeepCollectionEquality().hash(list),const DeepCollectionEquality().hash(visibleList),oneIndent,rnd,isTapIndentChange,isEditing,isTapClear,isSaveDialogOpen,needFocusChange,focusedIndex);

@override
String toString() {
  return 'MemoState(fileName: $fileName, list: $list, visibleList: $visibleList, oneIndent: $oneIndent, rnd: $rnd, isTapIndentChange: $isTapIndentChange, isEditing: $isEditing, isTapClear: $isTapClear, isSaveDialogOpen: $isSaveDialogOpen, needFocusChange: $needFocusChange, focusedIndex: $focusedIndex)';
}


}

/// @nodoc
abstract mixin class $MemoStateCopyWith<$Res>  {
  factory $MemoStateCopyWith(MemoState value, $Res Function(MemoState) _then) = _$MemoStateCopyWithImpl;
@useResult
$Res call({
 String fileName, List<MemoLineState> list, List<MemoLineState> visibleList, double oneIndent, String rnd, bool isTapIndentChange, bool isEditing, bool isTapClear, bool isSaveDialogOpen, bool needFocusChange, int focusedIndex
});




}
/// @nodoc
class _$MemoStateCopyWithImpl<$Res>
    implements $MemoStateCopyWith<$Res> {
  _$MemoStateCopyWithImpl(this._self, this._then);

  final MemoState _self;
  final $Res Function(MemoState) _then;

/// Create a copy of MemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileName = null,Object? list = null,Object? visibleList = null,Object? oneIndent = null,Object? rnd = null,Object? isTapIndentChange = null,Object? isEditing = null,Object? isTapClear = null,Object? isSaveDialogOpen = null,Object? needFocusChange = null,Object? focusedIndex = null,}) {
  return _then(_self.copyWith(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as List<MemoLineState>,visibleList: null == visibleList ? _self.visibleList : visibleList // ignore: cast_nullable_to_non_nullable
as List<MemoLineState>,oneIndent: null == oneIndent ? _self.oneIndent : oneIndent // ignore: cast_nullable_to_non_nullable
as double,rnd: null == rnd ? _self.rnd : rnd // ignore: cast_nullable_to_non_nullable
as String,isTapIndentChange: null == isTapIndentChange ? _self.isTapIndentChange : isTapIndentChange // ignore: cast_nullable_to_non_nullable
as bool,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,isTapClear: null == isTapClear ? _self.isTapClear : isTapClear // ignore: cast_nullable_to_non_nullable
as bool,isSaveDialogOpen: null == isSaveDialogOpen ? _self.isSaveDialogOpen : isSaveDialogOpen // ignore: cast_nullable_to_non_nullable
as bool,needFocusChange: null == needFocusChange ? _self.needFocusChange : needFocusChange // ignore: cast_nullable_to_non_nullable
as bool,focusedIndex: null == focusedIndex ? _self.focusedIndex : focusedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoState].
extension MemoStatePatterns on MemoState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoState value)  $default,){
final _that = this;
switch (_that) {
case _MemoState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoState value)?  $default,){
final _that = this;
switch (_that) {
case _MemoState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileName,  List<MemoLineState> list,  List<MemoLineState> visibleList,  double oneIndent,  String rnd,  bool isTapIndentChange,  bool isEditing,  bool isTapClear,  bool isSaveDialogOpen,  bool needFocusChange,  int focusedIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoState() when $default != null:
return $default(_that.fileName,_that.list,_that.visibleList,_that.oneIndent,_that.rnd,_that.isTapIndentChange,_that.isEditing,_that.isTapClear,_that.isSaveDialogOpen,_that.needFocusChange,_that.focusedIndex);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileName,  List<MemoLineState> list,  List<MemoLineState> visibleList,  double oneIndent,  String rnd,  bool isTapIndentChange,  bool isEditing,  bool isTapClear,  bool isSaveDialogOpen,  bool needFocusChange,  int focusedIndex)  $default,) {final _that = this;
switch (_that) {
case _MemoState():
return $default(_that.fileName,_that.list,_that.visibleList,_that.oneIndent,_that.rnd,_that.isTapIndentChange,_that.isEditing,_that.isTapClear,_that.isSaveDialogOpen,_that.needFocusChange,_that.focusedIndex);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileName,  List<MemoLineState> list,  List<MemoLineState> visibleList,  double oneIndent,  String rnd,  bool isTapIndentChange,  bool isEditing,  bool isTapClear,  bool isSaveDialogOpen,  bool needFocusChange,  int focusedIndex)?  $default,) {final _that = this;
switch (_that) {
case _MemoState() when $default != null:
return $default(_that.fileName,_that.list,_that.visibleList,_that.oneIndent,_that.rnd,_that.isTapIndentChange,_that.isEditing,_that.isTapClear,_that.isSaveDialogOpen,_that.needFocusChange,_that.focusedIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoState extends MemoState {
  const _MemoState({this.fileName = "", final  List<MemoLineState> list = const [], final  List<MemoLineState> visibleList = const [], this.oneIndent = 20.0, this.rnd = "0", this.isTapIndentChange = false, this.isEditing = false, this.isTapClear = false, this.isSaveDialogOpen = false, this.needFocusChange = false, this.focusedIndex = 0}): _list = list,_visibleList = visibleList,super._();
  factory _MemoState.fromJson(Map<String, dynamic> json) => _$MemoStateFromJson(json);

@override@JsonKey() final  String fileName;
 final  List<MemoLineState> _list;
@override@JsonKey() List<MemoLineState> get list {
  if (_list is EqualUnmodifiableListView) return _list;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_list);
}

 final  List<MemoLineState> _visibleList;
@override@JsonKey() List<MemoLineState> get visibleList {
  if (_visibleList is EqualUnmodifiableListView) return _visibleList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_visibleList);
}

@override@JsonKey() final  double oneIndent;
@override@JsonKey() final  String rnd;
@override@JsonKey() final  bool isTapIndentChange;
@override@JsonKey() final  bool isEditing;
@override@JsonKey() final  bool isTapClear;
@override@JsonKey() final  bool isSaveDialogOpen;
@override@JsonKey() final  bool needFocusChange;
@override@JsonKey() final  int focusedIndex;

/// Create a copy of MemoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoStateCopyWith<_MemoState> get copyWith => __$MemoStateCopyWithImpl<_MemoState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoState&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other._list, _list)&&const DeepCollectionEquality().equals(other._visibleList, _visibleList)&&(identical(other.oneIndent, oneIndent) || other.oneIndent == oneIndent)&&(identical(other.rnd, rnd) || other.rnd == rnd)&&(identical(other.isTapIndentChange, isTapIndentChange) || other.isTapIndentChange == isTapIndentChange)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.isTapClear, isTapClear) || other.isTapClear == isTapClear)&&(identical(other.isSaveDialogOpen, isSaveDialogOpen) || other.isSaveDialogOpen == isSaveDialogOpen)&&(identical(other.needFocusChange, needFocusChange) || other.needFocusChange == needFocusChange)&&(identical(other.focusedIndex, focusedIndex) || other.focusedIndex == focusedIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileName,const DeepCollectionEquality().hash(_list),const DeepCollectionEquality().hash(_visibleList),oneIndent,rnd,isTapIndentChange,isEditing,isTapClear,isSaveDialogOpen,needFocusChange,focusedIndex);

@override
String toString() {
  return 'MemoState(fileName: $fileName, list: $list, visibleList: $visibleList, oneIndent: $oneIndent, rnd: $rnd, isTapIndentChange: $isTapIndentChange, isEditing: $isEditing, isTapClear: $isTapClear, isSaveDialogOpen: $isSaveDialogOpen, needFocusChange: $needFocusChange, focusedIndex: $focusedIndex)';
}


}

/// @nodoc
abstract mixin class _$MemoStateCopyWith<$Res> implements $MemoStateCopyWith<$Res> {
  factory _$MemoStateCopyWith(_MemoState value, $Res Function(_MemoState) _then) = __$MemoStateCopyWithImpl;
@override @useResult
$Res call({
 String fileName, List<MemoLineState> list, List<MemoLineState> visibleList, double oneIndent, String rnd, bool isTapIndentChange, bool isEditing, bool isTapClear, bool isSaveDialogOpen, bool needFocusChange, int focusedIndex
});




}
/// @nodoc
class __$MemoStateCopyWithImpl<$Res>
    implements _$MemoStateCopyWith<$Res> {
  __$MemoStateCopyWithImpl(this._self, this._then);

  final _MemoState _self;
  final $Res Function(_MemoState) _then;

/// Create a copy of MemoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? list = null,Object? visibleList = null,Object? oneIndent = null,Object? rnd = null,Object? isTapIndentChange = null,Object? isEditing = null,Object? isTapClear = null,Object? isSaveDialogOpen = null,Object? needFocusChange = null,Object? focusedIndex = null,}) {
  return _then(_MemoState(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,list: null == list ? _self._list : list // ignore: cast_nullable_to_non_nullable
as List<MemoLineState>,visibleList: null == visibleList ? _self._visibleList : visibleList // ignore: cast_nullable_to_non_nullable
as List<MemoLineState>,oneIndent: null == oneIndent ? _self.oneIndent : oneIndent // ignore: cast_nullable_to_non_nullable
as double,rnd: null == rnd ? _self.rnd : rnd // ignore: cast_nullable_to_non_nullable
as String,isTapIndentChange: null == isTapIndentChange ? _self.isTapIndentChange : isTapIndentChange // ignore: cast_nullable_to_non_nullable
as bool,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,isTapClear: null == isTapClear ? _self.isTapClear : isTapClear // ignore: cast_nullable_to_non_nullable
as bool,isSaveDialogOpen: null == isSaveDialogOpen ? _self.isSaveDialogOpen : isSaveDialogOpen // ignore: cast_nullable_to_non_nullable
as bool,needFocusChange: null == needFocusChange ? _self.needFocusChange : needFocusChange // ignore: cast_nullable_to_non_nullable
as bool,focusedIndex: null == focusedIndex ? _self.focusedIndex : focusedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
