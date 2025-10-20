// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memo_line_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoLineState {

 int get indent; String get text; int get index; double get fontSize; bool get isEditing; bool get isFolding; bool get isReadOnly;
/// Create a copy of MemoLineState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoLineStateCopyWith<MemoLineState> get copyWith => _$MemoLineStateCopyWithImpl<MemoLineState>(this as MemoLineState, _$identity);

  /// Serializes this MemoLineState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoLineState&&(identical(other.indent, indent) || other.indent == indent)&&(identical(other.text, text) || other.text == text)&&(identical(other.index, index) || other.index == index)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.isFolding, isFolding) || other.isFolding == isFolding)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,indent,text,index,fontSize,isEditing,isFolding,isReadOnly);

@override
String toString() {
  return 'MemoLineState(indent: $indent, text: $text, index: $index, fontSize: $fontSize, isEditing: $isEditing, isFolding: $isFolding, isReadOnly: $isReadOnly)';
}


}

/// @nodoc
abstract mixin class $MemoLineStateCopyWith<$Res>  {
  factory $MemoLineStateCopyWith(MemoLineState value, $Res Function(MemoLineState) _then) = _$MemoLineStateCopyWithImpl;
@useResult
$Res call({
 int indent, String text, int index, double fontSize, bool isEditing, bool isFolding, bool isReadOnly
});




}
/// @nodoc
class _$MemoLineStateCopyWithImpl<$Res>
    implements $MemoLineStateCopyWith<$Res> {
  _$MemoLineStateCopyWithImpl(this._self, this._then);

  final MemoLineState _self;
  final $Res Function(MemoLineState) _then;

/// Create a copy of MemoLineState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? indent = null,Object? text = null,Object? index = null,Object? fontSize = null,Object? isEditing = null,Object? isFolding = null,Object? isReadOnly = null,}) {
  return _then(_self.copyWith(
indent: null == indent ? _self.indent : indent // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,isFolding: null == isFolding ? _self.isFolding : isFolding // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoLineState].
extension MemoLineStatePatterns on MemoLineState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoLineState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoLineState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoLineState value)  $default,){
final _that = this;
switch (_that) {
case _MemoLineState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoLineState value)?  $default,){
final _that = this;
switch (_that) {
case _MemoLineState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int indent,  String text,  int index,  double fontSize,  bool isEditing,  bool isFolding,  bool isReadOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoLineState() when $default != null:
return $default(_that.indent,_that.text,_that.index,_that.fontSize,_that.isEditing,_that.isFolding,_that.isReadOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int indent,  String text,  int index,  double fontSize,  bool isEditing,  bool isFolding,  bool isReadOnly)  $default,) {final _that = this;
switch (_that) {
case _MemoLineState():
return $default(_that.indent,_that.text,_that.index,_that.fontSize,_that.isEditing,_that.isFolding,_that.isReadOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int indent,  String text,  int index,  double fontSize,  bool isEditing,  bool isFolding,  bool isReadOnly)?  $default,) {final _that = this;
switch (_that) {
case _MemoLineState() when $default != null:
return $default(_that.indent,_that.text,_that.index,_that.fontSize,_that.isEditing,_that.isFolding,_that.isReadOnly);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _MemoLineState extends MemoLineState {
   _MemoLineState({this.indent = 0, this.text = "", this.index = 0, this.fontSize = 14, this.isEditing = false, this.isFolding = false, this.isReadOnly = false}): super._();
  factory _MemoLineState.fromJson(Map<String, dynamic> json) => _$MemoLineStateFromJson(json);

@override@JsonKey() final  int indent;
@override@JsonKey() final  String text;
@override@JsonKey() final  int index;
@override@JsonKey() final  double fontSize;
@override@JsonKey() final  bool isEditing;
@override@JsonKey() final  bool isFolding;
@override@JsonKey() final  bool isReadOnly;

/// Create a copy of MemoLineState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoLineStateCopyWith<_MemoLineState> get copyWith => __$MemoLineStateCopyWithImpl<_MemoLineState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoLineStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoLineState&&(identical(other.indent, indent) || other.indent == indent)&&(identical(other.text, text) || other.text == text)&&(identical(other.index, index) || other.index == index)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.isFolding, isFolding) || other.isFolding == isFolding)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,indent,text,index,fontSize,isEditing,isFolding,isReadOnly);

@override
String toString() {
  return 'MemoLineState(indent: $indent, text: $text, index: $index, fontSize: $fontSize, isEditing: $isEditing, isFolding: $isFolding, isReadOnly: $isReadOnly)';
}


}

/// @nodoc
abstract mixin class _$MemoLineStateCopyWith<$Res> implements $MemoLineStateCopyWith<$Res> {
  factory _$MemoLineStateCopyWith(_MemoLineState value, $Res Function(_MemoLineState) _then) = __$MemoLineStateCopyWithImpl;
@override @useResult
$Res call({
 int indent, String text, int index, double fontSize, bool isEditing, bool isFolding, bool isReadOnly
});




}
/// @nodoc
class __$MemoLineStateCopyWithImpl<$Res>
    implements _$MemoLineStateCopyWith<$Res> {
  __$MemoLineStateCopyWithImpl(this._self, this._then);

  final _MemoLineState _self;
  final $Res Function(_MemoLineState) _then;

/// Create a copy of MemoLineState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? indent = null,Object? text = null,Object? index = null,Object? fontSize = null,Object? isEditing = null,Object? isFolding = null,Object? isReadOnly = null,}) {
  return _then(_MemoLineState(
indent: null == indent ? _self.indent : indent // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,isFolding: null == isFolding ? _self.isFolding : isFolding // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
