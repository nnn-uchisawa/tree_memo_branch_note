import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';

/// ログイン方法選択ダイアログ
class LoginDialog extends ConsumerWidget {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('ログイン方法を選択'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Google サインインボタン
          SignInButton(
            Buttons.Google,
            text: "Google でログイン",
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signInWithGoogle();
            },
          ),
          const SizedBox(height: 16),
          // Apple サインインボタン（iOS でのみ表示）
          if (Platform.isIOS)
            FutureBuilder<bool>(
              future: SignInWithApple.isAvailable(),
              builder: (context, snapshot) {
                final available = snapshot.data ?? false;
                if (!available) return const SizedBox.shrink();
                return SignInButton(
                  Buttons.Apple,
                  text: "Apple でログイン",
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await ref
                          .read(authProvider.notifier)
                          .signInWithApple();
                    } catch (e) {
                      AppUtils.showSnackBar('Appleでのログインに失敗しました: $e');
                    }
                  },
                );
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

/// ログイン選択ダイアログを表示
void showLoginDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const LoginDialog());
}
