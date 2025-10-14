import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/flavors.dart';
import 'package:tree/src/services/firebase/firebase_service.dart';
import 'package:tree/src/tree_app.dart';

void main() async {
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 環境変数をロード（プラットフォーム別の.envを優先）
  String envFile = '.env';
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      envFile = '.env.ios';
      break;
    case TargetPlatform.android:
      envFile = '.env.android';
      break;
    default:
      envFile = '.env';
  }
  await dotenv.load(fileName: envFile);

  // Firebase を初期化
  await FirebaseService.initialize();

  runApp(ProviderScope(child: TreeApp()));
}
