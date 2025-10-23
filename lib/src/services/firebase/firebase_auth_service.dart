import 'dart:convert';
import 'dart:developer';
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

  /// 認証状態を完全にクリア（アカウント削除後用）
  static Future<void> clearAuthState() async {
    try {
      // Firebase認証からサインアウト
      await _auth.signOut();

      // Google Sign-inからもサインアウト
      await _googleSignIn.signOut();

      // Google Sign-inのキャッシュをクリア
      await _googleSignIn.disconnect();

      log('認証状態を完全にクリアしました');
    } catch (e) {
      log('認証状態クリアエラー: $e');
      // エラーが発生しても処理を続行
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
      await user
          .getIdToken(true)
          .timeout(
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

  /// アカウント削除
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      log('アカウント削除開始: ${user.uid}');

      try {
        // アカウント削除を実行
        await user.delete();

        log('アカウント削除完了: ${user.uid}');

        // 削除後の確認（少し待ってから確認）
        await Future.delayed(const Duration(seconds: 1));

        // 削除が成功したか確認
        final currentUserAfterDelete = currentUser;
        if (currentUserAfterDelete != null) {
          log('警告: アカウント削除後もユーザーが存在します: ${currentUserAfterDelete.uid}');
        } else {
          log('アカウント削除確認: ユーザーが正常に削除されました');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          log('再認証が必要です。自動で再認証を実行します。');
          await _reauthenticateUser(user);

          // 再認証後、再度削除を試行
          log('再認証後、アカウント削除を再試行');
          await user.delete();

          log('再認証後のアカウント削除完了: ${user.uid}');
        } else {
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      log('Firebase認証エラー: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'ユーザーが見つかりません。既に削除されている可能性があります。';
          break;
        case 'invalid-user-token':
          errorMessage = '認証トークンが無効です。再度ログインしてください。';
          break;
        case 'user-token-expired':
          errorMessage = '認証トークンが期限切れです。再度ログインしてください。';
          break;
        case 'network-request-failed':
          errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
          break;
        default:
          errorMessage = 'アカウント削除に失敗しました: ${e.code} - ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      log('アカウント削除エラー: $e');
      rethrow;
    }
  }

  /// ユーザーの再認証
  static Future<void> _reauthenticateUser(User user) async {
    try {
      // ユーザーのプロバイダー情報を取得
      final providerData = user.providerData;

      for (final provider in providerData) {
        try {
          if (provider.providerId == 'google.com') {
            log('Google再認証を実行');
            await _reauthenticateWithGoogle();
            return;
          } else if (provider.providerId == 'apple.com') {
            log('Apple再認証を実行');
            await _reauthenticateWithApple();
            return;
          }
        } catch (e) {
          log('${provider.providerId}再認証エラー: $e');
          continue;
        }
      }

      throw Exception('再認証に失敗しました。対応する認証プロバイダーが見つかりません。');
    } catch (e) {
      log('再認証エラー: $e');
      rethrow;
    }
  }

  /// Google再認証
  static Future<void> _reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google再認証がキャンセルされました');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        credential,
      );
      log('Google再認証完了');
    } catch (e) {
      log('Google再認証エラー: $e');
      rethrow;
    }
  }

  /// Apple再認証
  static Future<void> _reauthenticateWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Apple認証でidentityTokenが取得できませんでした');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        oauthCredential,
      );
      log('Apple再認証完了');
    } catch (e) {
      log('Apple再認証エラー: $e');
      rethrow;
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
