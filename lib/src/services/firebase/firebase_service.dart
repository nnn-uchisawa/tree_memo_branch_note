import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:tree/firebase_options.dart';

/// Firebase 初期化サービス
class FirebaseService {
  static bool _initialized = false;

  /// Firebase を初期化
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    } catch (e) {
      // Firebase が設定されていない場合でもアプリは動作する
      log('Firebase initialization failed: $e');
    }
  }

  /// 初期化済みかどうか
  static bool get isInitialized => _initialized;
}
