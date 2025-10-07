import 'package:flutter/material.dart';
import 'package:tree/app_router.dart';
import 'package:tree/gen/fonts.gen.dart';

class TreeApp extends StatelessWidget {
  TreeApp({
    super.key,
  });

  final themeDark = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.blueAccent,
      cursorColor: Colors.blueAccent,
      selectionHandleColor: Colors.blueAccent,
    ),
    brightness: Brightness.dark,
    fontFamily: FontFamily.notoSansJPRegular,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
    ),
  );

  final themeLight = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.blueAccent,
      cursorColor: Colors.blueAccent,
      selectionHandleColor: Colors.blueAccent,
    ),
    brightness: Brightness.light,
    fontFamily: FontFamily.notoSansJPRegular,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      darkTheme: themeDark,
      themeMode: ThemeMode.system,
      theme: themeLight,
      title: "TREE",
      restorationScopeId: 'app',
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
    );
  }
}
