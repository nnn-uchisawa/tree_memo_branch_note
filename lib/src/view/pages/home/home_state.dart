import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  factory HomeState({@Default([]) List<File> list, MemoState? memoState}) =
      _HomeState;
}
