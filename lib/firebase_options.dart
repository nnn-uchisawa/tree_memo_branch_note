// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 環境変数（flutter_dotenv）から FirebaseOptions を生成
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for Web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidFromEnv();
      case TargetPlatform.iOS:
        return _iosFromEnv();
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions _androidFromEnv() {
    return FirebaseOptions(
      apiKey: _req('ANDROID_API_KEY'),
      appId: _req('ANDROID_APP_ID'),
      messagingSenderId: _req('ANDROID_MESSAGING_SENDER_ID'),
      projectId: _req('ANDROID_PROJECT_ID'),
      storageBucket: _req('ANDROID_STORAGE_BUCKET'),
    );
  }

  static FirebaseOptions _iosFromEnv() {
    return FirebaseOptions(
      apiKey: _req('IOS_API_KEY'),
      appId: _req('IOS_APP_ID'),
      messagingSenderId: _req('IOS_MESSAGING_SENDER_ID'),
      projectId: _req('IOS_PROJECT_ID'),
      storageBucket: _req('IOS_STORAGE_BUCKET'),
      iosBundleId: _req('IOS_BUNDLE_ID'),
    );
  }

  static String _req(String key) {
    final v = dotenv.env[key];
    if (v == null || v.isEmpty) {
      throw StateError('Missing env: ' + key);
    }
    return v;
  }
}
