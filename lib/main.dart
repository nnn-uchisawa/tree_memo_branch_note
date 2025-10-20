import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/flavors.dart';
import 'package:tree/src/services/firebase/firebase_service.dart';
import 'package:tree/src/tree_app.dart';
import 'package:tree/src/util/shared_preference.dart';

void main() async {
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 環境変数をロード
  await dotenv.load(fileName: '.env');

  // SharedPreferences を初期化
  await SharedPreference.init();

  // Firebase を初期化
  await FirebaseService.initialize();

  runApp(ProviderScope(child: TreeApp()));
}
