import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/app_router.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/util/shared_preference.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  void build() {
    // 初期化処理は不要
  }

  /// Apple認証プロバイダーが存在するかチェック
  bool hasAppleProvider() {
    return SharedPreference.isAppleLinked;
  }

  /// Google認証プロバイダーが存在するかチェック
  bool hasGoogleProvider() {
    return SharedPreference.isGoogleLinked;
  }

  /// 個別アカウント削除ダイアログを表示
  Future<void> showIndividualDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String provider,
  ) async {
    try {
      AppUtils.showYesNoDialogAlternative(
        Text('$provider認証の削除'),
        Text(
          '現在ログイン中の$providerアカウントを削除しますか？\n\n'
          'このアカウントのクラウドメモは削除されますが、ローカルメモは保持されます。\n'
          '削除時は再認証が必要です。\n\n'
          'この操作は取り消せません。',
        ),
        () async {
          try {
            await ref
                .read(authProvider.notifier)
                .deleteIndividualAccount(provider);
            AppUtils.showSnackBar('$provider認証を削除しました');
            // 画面を再構築してアカウント数を更新
            if (context.mounted) {
              Navigator.of(context).pop(); // 設定画面を閉じて再オープン
              const SettingsRoute().push(context);
            }
          } catch (e) {
            AppUtils.showSnackBar('認証削除に失敗しました: $e');
          }
        },
        null,
      );
    } catch (e) {
      log('個別削除ダイアログ表示エラー: $e');
      AppUtils.showSnackBar('ダイアログの表示に失敗しました: $e');
    }
  }

  /// Apple認証アカウント数を取得
  Future<int> getAppleAccountCount() async {
    try {
      return await SharedPreference.getAppleLinkedAccountCount();
    } catch (e) {
      log('Apple認証アカウント数取得エラー: $e');
      return 0;
    }
  }

  /// Google認証アカウント数を取得
  Future<int> getGoogleAccountCount() async {
    try {
      return await SharedPreference.getGoogleLinkedAccountCount();
    } catch (e) {
      log('Google認証アカウント数取得エラー: $e');
      return 0;
    }
  }
}
