import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/app_router.dart';
import 'package:tree/gen/fonts.gen.dart';
import 'package:tree/src/view/pages/settings/theme_notifier.dart';

class TreeApp extends ConsumerWidget {
  TreeApp({super.key});

  final themeDark = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.blueAccent,
      cursorColor: Colors.blueAccent,
      selectionHandleColor: Colors.blueAccent,
    ),
    brightness: Brightness.dark,
    fontFamily: FontFamily.notoSansJPRegular,
    colorScheme: const ColorScheme.dark(primary: Colors.blue),
  );

  final themeLight = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.blueAccent,
      cursorColor: Colors.blueAccent,
      selectionHandleColor: Colors.blueAccent,
    ),
    brightness: Brightness.light,
    fontFamily: FontFamily.notoSansJPRegular,
    colorScheme: const ColorScheme.light(primary: Colors.blue),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      darkTheme: themeDark,
      themeMode: themeState.themeMode,
      theme: themeLight,
      title: "TREE",
      restorationScopeId: 'app',
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
    );
  }
}
