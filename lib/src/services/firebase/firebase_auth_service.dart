import 'dart:convert';
import 'dart:math' show Random;

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tree/src/services/firebase/firebase_service.dart';

/// Firebase 認証サービス
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 現在のユーザーを取得
  static User? get currentUser => _auth.currentUser;

  /// 認証状態のストリーム
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ログイン済みかどうか
  static bool get isSignedIn => currentUser != null;

  /// Google サインイン
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      // Google サインインのトリガー
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // ユーザーがサインインをキャンセル
      }

      // 認証の詳細を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 新しい認証情報を作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase にサインイン
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// Apple サインイン
  static Future<UserCredential?> signInWithApple() async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      // Apple Sign-inの可用性をチェック
      final isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        throw Exception('Apple Sign-in is not available on this device');
      }

      // シンプルなApple Sign-in（nonceなしで試行）

      AuthorizationCredentialAppleID appleCredential;
      try {
        appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
      } catch (e) {
        rethrow;
      }

      // identityTokenの存在確認
      if (appleCredential.identityToken == null) {
        throw Exception('Apple認証でidentityTokenが取得できませんでした');
      }

      // Firebase 用の認証情報を作成（nonceなし）
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase にサインイン
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // ユーザーキャンセル (1001)
        return null;
      }
      // 具体的なエラーメッセージをユーザーに表示
      throw Exception('Apple認証エラー: ${e.message}');
    } on FirebaseAuthException catch (e) {
      // 既存メールが他プロバイダで登録済みの典型ケース
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('このメールアドレスは既に別の方法で登録されています。既存の方法でログイン後、アカウント連携してください。');
      } else if (e.code == 'invalid-credential') {
        throw Exception('認証情報が無効です。もう一度お試しください。');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Appleサインインが有効化されていません。Firebase Consoleで設定を確認してください。');
      } else {
        throw Exception('Firebase認証エラー: ${e.code} - ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ランダムな nonce を生成
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// サインアウト
  static Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザーIDを取得
  static String? get userId => currentUser?.uid;

  /// ユーザー表示名を取得
  static String? get displayName => currentUser?.displayName;

  /// ユーザーメールアドレスを取得
  static String? get email => currentUser?.email;

  /// トークンの有効性をチェック（Firebase に実リクエストを送って確認）
  static Future<bool> validateToken() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      // ネットワークエラーを考慮してタイムアウトを設定
      await user.getIdToken(true).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Token validation timeout');
        },
      );
      return true;
    } on FirebaseAuthException {
      // トークン切れや認証エラー
      return false;
    } catch (e) {
      // ネットワークエラーやタイムアウトの場合は既存セッションを維持
      // ログアウトは行わない
      return true;
    }
  }

  /// Apple サインイン（nonceあり版 - デバッグ用）
  static Future<UserCredential?> signInWithAppleWithNonce() async {
    try {
      if (!FirebaseService.isInitialized) {
        await FirebaseService.initialize();
      }

      // Firebase 連携に必要な nonce を生成 (raw と SHA256)
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // Apple サインインのトリガー（Apple へは SHA256 済みの nonce を渡す）
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Firebase 用の認証情報を作成（Firebase へは生の nonce を渡す）
      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Firebase にサインイン
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('このメールアドレスは既に別の方法で登録されています。既存の方法でログイン後、アカウント連携してください。');
      } else if (e.code == 'invalid-credential') {
        throw Exception('認証情報が無効です。もう一度お試しください。');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Appleサインインが有効化されていません。Firebase Consoleで設定を確認してください。');
      } else {
        throw Exception('Firebase認証エラー: ${e.code} - ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
