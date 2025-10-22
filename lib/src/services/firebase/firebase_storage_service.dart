import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:tree/src/exceptions/authentication_exception.dart';
import 'package:tree/src/services/firebase/firebase_auth_service.dart';
import 'package:tree/src/services/firebase/firebase_service.dart';

/// Firebase Storage サービス
class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ユーザーのメモディレクトリパスを取得
  static String _getUserMemosPath() {
    final userId = FirebaseAuthService.userId;
    if (userId == null) {
      throw Exception('ユーザーが認証されていません');
    }
    return 'users/$userId/memos';
  }

  /// メモファイルをアップロード
  static Future<void> uploadMemo(String fileName, File file) async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      if (!FirebaseAuthService.isSignedIn) {
        throw Exception('ユーザーが認証されていません');
      }

      final path = '${_getUserMemosPath()}/$fileName.tmson';
      final ref = _storage.ref().child(path);

      await ref.putFile(file);
    } on FirebaseException catch (e) {
      log('メモアップロードFirebaseエラー: ${e.code} - ${e.message}');
      throw AuthenticationException('クラウド通信エラーが発生しました', code: e.code);
    } catch (e) {
      log('メモアップロードエラー: $e');
      rethrow;
    }
  }

  /// メモファイルをダウンロード
  static Future<File> downloadMemo(String fileName, String localPath) async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      if (!FirebaseAuthService.isSignedIn) {
        throw Exception('ユーザーが認証されていません');
      }

      final path = '${_getUserMemosPath()}/$fileName.tmson';
      final ref = _storage.ref().child(path);

      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } on FirebaseException catch (e) {
      log('メモダウンロードFirebaseエラー: ${e.code} - ${e.message}');
      throw AuthenticationException('クラウド通信エラーが発生しました', code: e.code);
    } catch (e) {
      log('メモダウンロードエラー: $e');
      rethrow;
    }
  }

  /// ユーザーのメモファイル一覧を取得
  static Future<List<String>> getMemoFileNames() async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      if (!FirebaseAuthService.isSignedIn) {
        throw Exception('ユーザーが認証されていません');
      }

      final ref = _storage.ref().child(_getUserMemosPath());
      final result = await ref.listAll();

      return result.items
          .map((item) => item.name.replaceAll('.tmson', ''))
          .toList();
    } on FirebaseException catch (e) {
      log('メモファイル一覧取得Firebaseエラー: ${e.code} - ${e.message}');
      throw AuthenticationException('クラウド通信エラーが発生しました', code: e.code);
    } catch (e) {
      log('メモファイル一覧取得エラー: $e');
      rethrow;
    }
  }

  /// メモファイルを削除
  static Future<void> deleteMemo(String fileName) async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      if (!FirebaseAuthService.isSignedIn) {
        throw Exception('ユーザーが認証されていません');
      }

      final path = '${_getUserMemosPath()}/$fileName.tmson';
      final ref = _storage.ref().child(path);

      await ref.delete();
    } on FirebaseException catch (e) {
      log('メモファイル削除Firebaseエラー: ${e.code} - ${e.message}');
      throw AuthenticationException('クラウド通信エラーが発生しました', code: e.code);
    } catch (e) {
      log('メモファイル削除エラー: $e');
      rethrow;
    }
  }

  /// メモファイルの存在確認
  static Future<bool> memoExists(String fileName) async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      if (!FirebaseAuthService.isSignedIn) {
        return false;
      }

      final path = '${_getUserMemosPath()}/$fileName.tmson';
      final ref = _storage.ref().child(path);

      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
