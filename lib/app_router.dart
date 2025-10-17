import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tree/src/services/file/file_service.dart';
import 'package:tree/src/util/shared_preference.dart';
import 'package:tree/src/view/pages/home/home_view.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';
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
        body: SingleChildScrollView(child: Text(state.error.toString())),
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
      // アセットファイルを読み込み
      final jsonStringJp = await DefaultAssetBundle.of(
        // 特定のファイルの読み込みのみなので非同期処理を許可
        // ignore: use_build_context_synchronously
        context,
      ).loadString("assets/usage_of_tree.tmson");
      final jsonStringCloud = await DefaultAssetBundle.of(
        // 特定のファイルの読み込みのみなので非同期処理を許可
        // ignore: use_build_context_synchronously
        context,
      ).loadString("assets/usage_of_cloud.tmson");

      // JSONをパースしてMemoStateに変換
      final jsonDataJp = json.decode(jsonStringJp);
      final jsonDataCloud = json.decode(jsonStringCloud);
      
      final memoStateJp = MemoState.fromJson(jsonDataJp);
      final memoStateCloud = MemoState.fromJson(jsonDataCloud);

      // FileServiceを使用してファイルを保存（表示順を維持するためlastUpdatedを保持）
      await FileService.saveMemoStateWithDisplayName(
        memoStateJp, 
        memoStateJp.fileName,
      );
      await FileService.saveMemoStateWithDisplayName(
        memoStateCloud, 
        memoStateCloud.fileName,
      );

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
