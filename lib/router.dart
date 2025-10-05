import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tree/src/util/shared_preference.dart';
import 'package:tree/src/view/pages/home/home_view.dart';
import 'package:tree/src/view/pages/memo/memo_view.dart';
import 'package:tree/src/view/pages/walk_through/walk_through_view.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
    // アプリが起動した時
    initialLocation: '/',
    navigatorKey: navigatorKey,
    // パスと画面の組み合わせ
    routes: [
      GoRoute(
        path: '/',
        name: 'init',
        redirect: (context, state) async {
          final isNI = await SharedPreference.isNotInitial();
          if (!isNI) {
            final jsonstringJp = await DefaultAssetBundle.of(
                // ignore: use_build_context_synchronously
                context).loadString("assets/Treeの使い方.tmson");
            final dir = await getApplicationDocumentsDirectory();
            final pathJp = '${dir.path}/Treeの使い方.tmson';
            final newFileJp = File(pathJp);
            await newFileJp.writeAsString(jsonstringJp);
            await SharedPreference.setIsNotInitial();
            return "/walk";
          }
          return "/home";
        },
      ),
      GoRoute(
        path: '/walk',
        name: 'walk',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: WalkThroughView(),
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const HomeView(),
          );
        },
      ),
      GoRoute(
        path: '/memo',
        name: 'memo',
        onExit: (context, state) {
          return true;
        },
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const MemoView(),
          );
        },
      ),
    ],
    // 遷移ページがないなどのエラーが発生した時に、このページに行く
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text(state.error.toString()),
        ),
      ),
    ),
  );
}
