import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  void build() {
    // 初期化処理は不要
  }

  bool hasAppleProvider() {
    return false;
  }

  bool hasGoogleProvider() {
    return false;
  }

  Future<int> getAppleAccountCount() async {
    return 0;
  }

  Future<int> getGoogleAccountCount() async {
    return 0;
  }

  Future<void> showIndividualDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String provider,
  ) async {}
}
