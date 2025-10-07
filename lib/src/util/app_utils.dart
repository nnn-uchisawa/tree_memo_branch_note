import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tree/app_router.dart';

class AppUtils {
  static double sWidth() {
    if (AppRouter.navigatorKey.currentContext != null) {
      var context = AppRouter.navigatorKey.currentContext!;
      return MediaQuery.of(context).size.width;
    }
    return 1080.0;
  }

  static double sHeight() {
    if (AppRouter.navigatorKey.currentContext != null) {
      var context = AppRouter.navigatorKey.currentContext!;
      return MediaQuery.of(context).size.height;
    }
    return 1920.0;
  }

  static String getRandomString({int length = 64}) =>
      String.fromCharCodes(Iterable.generate(length, (_) {
        const chars =
            'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
        Random rnd = Random();
        return chars.codeUnitAt(rnd.nextInt(chars.length));
      }));

  static void showYesNoDialogAlternative(
    Widget title,
    Widget content,
    Function() yesCallBack,
    Function()? noCallBack,
  ) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog.adaptive(
          title: title,
          content: content,
          actions: [
            adaptiveAction(
              context: dialogContext,
              onPressed: () {
                try {
                  noCallBack?.call();
                } finally {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }
              },
              child: const Text("キャンセル"),
            ),
            adaptiveAction(
              context: dialogContext,
              onPressed: () {
                try {
                  yesCallBack();
                } finally {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }
              },
              child: const Text("はい"),
            ),
          ],
        );
      },
    );
  }

  static void showYesNoDialogAlternativeDestructive(
    Widget title,
    Widget content,
    Function() yesCallBack,
    Function()? noCallBack,
  ) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog.adaptive(
          title: title,
          content: content,
          actions: [
            adaptiveAction(
              context: dialogContext,
              onPressed: () {
                try {
                  noCallBack?.call();
                } finally {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }
              },
              child: const Text("キャンセル"),
            ),
            adaptiveActionDestructive(
              context: dialogContext,
              onPressed: () {
                try {
                  yesCallBack();
                } finally {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }
              },
              child: const Text("はい"),
            ),
          ],
        );
      },
    );
  }

  static void showYesNoDialogAlternativeTECArg(
      Widget title,
      Widget content,
      Function(TextEditingController) yesCallBack,
      Function(TextEditingController)? noCallBack,
      TextEditingController arg) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog.adaptive(
        title: title,
        content: content,
        actions: [
          adaptiveAction(
            context: dialogContext,
            onPressed: () {
              if (noCallBack != null) noCallBack(arg);
              Navigator.of(dialogContext, rootNavigator: true).pop();
            },
            child: const Text(
              "キャンセル",
            ),
          ),
          adaptiveAction(
            context: dialogContext,
            onPressed: () {
              yesCallBack(arg);
              Navigator.of(dialogContext, rootNavigator: true).pop();
            },
            child: const Text(
              "はい",
            ),
          )
        ],
      ),
    );
  }

  static Widget adaptiveAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface),
            child: child);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(
            onPressed: onPressed,
            textStyle: TextStyle(color: Color.fromARGB(255, 0, 122, 255)),
            child: child);
    }
  }

  static Widget adaptiveActionDestructive({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface),
            child: child);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(
            onPressed: onPressed,
            textStyle: TextStyle(color: Color.fromARGB(255, 255, 59, 48)),
            child: child);
    }
  }

  static void showSnackBar(String text) {
    if (AppRouter.navigatorKey.currentContext == null) return;
    var bar = SnackBar(
      content: Text(text),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    );
    ScaffoldMessenger.of(AppRouter.navigatorKey.currentContext!)
        .showSnackBar(bar);
  }

  static Future<void> shareFile(String filePath, {String? fileName}) async {
    try {
      final xFile = XFile(filePath, name: fileName);
      await SharePlus.instance.share(ShareParams(files: [xFile]));
    } catch (e) {
      showSnackBar('ファイル共有に失敗しました');
    }
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
