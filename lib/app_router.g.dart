// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $initRoute,
  $homeRoute,
  $walkThroughRoute,
  $memoRoute,
];

RouteBase get $initRoute =>
    GoRouteData.$route(path: '/', factory: $InitRoute._fromState);

mixin $InitRoute on GoRouteData {
  static InitRoute _fromState(GoRouterState state) => const InitRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/home', factory: $HomeRoute._fromState);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $walkThroughRoute =>
    GoRouteData.$route(path: '/walk', factory: $WalkThroughRoute._fromState);

mixin $WalkThroughRoute on GoRouteData {
  static WalkThroughRoute _fromState(GoRouterState state) =>
      const WalkThroughRoute();

  @override
  String get location => GoRouteData.$location('/walk');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $memoRoute =>
    GoRouteData.$route(path: '/memo', factory: $MemoRoute._fromState);

mixin $MemoRoute on GoRouteData {
  static MemoRoute _fromState(GoRouterState state) => const MemoRoute();

  @override
  String get location => GoRouteData.$location('/memo');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
