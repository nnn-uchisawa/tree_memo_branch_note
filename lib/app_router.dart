import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tree/src/util/shared_preference.dart';
import 'package:tree/src/view/pages/home/home_view.dart';
import 'package:tree/src/view/pages/memo/memo_view.dart';
import 'package:tree/src/view/pages/walk_through/walk_through_view.dart';

part 'app_router.g.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
    // アプリが起動した時
    initialLocation: '/',
    navigatorKey: navigatorKey,
    // パスと画面の組み合わせ
    routes: $appRoutes,
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

@TypedGoRoute<InitRoute>(path: '/')
class InitRoute extends GoRouteData with $InitRoute {
  const InitRoute();

  @override
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final isNI = await SharedPreference.isNotInitial();
    if (!isNI) {
      final jsonstringJp = await DefaultAssetBundle.of(context)
          .loadString("assets/Treeの使い方.tmson");
      final dir = await getApplicationDocumentsDirectory();
      final pathJp = '${dir.path}/Treeの使い方.tmson';
      final newFileJp = File(pathJp);
      await newFileJp.writeAsString(jsonstringJp);
      await SharedPreference.setIsNotInitial();
      return const WalkThroughRoute().location;
    }
    return const HomeRoute().location;
  }
}

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeView();
}

@TypedGoRoute<WalkThroughRoute>(path: '/walk')
class WalkThroughRoute extends GoRouteData with $WalkThroughRoute {
  const WalkThroughRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => WalkThroughView();
}

@TypedGoRoute<MemoRoute>(path: '/memo')
class MemoRoute extends GoRouteData with $MemoRoute {
  const MemoRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MemoView();
}
