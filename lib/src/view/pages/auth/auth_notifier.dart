import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/src/services/firebase/firebase_auth_service.dart';
import 'package:tree/src/services/firebase/firebase_service.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/util/shared_preference.dart';

import 'auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Firebase を初期化
    FirebaseService.initialize();

    // SharedPreferences を初期化
    SharedPreference.init();

    // 認証状態の監視を開始
    _listenToAuthState();

    // アプリ起動時の自動ログイン処理
    _checkAutoLogin();

    return const AuthState();
  }

  /// 認証状態の監視
  void _listenToAuthState() {
    FirebaseAuthService.authStateChanges.listen((User? user) {
      state = state.copyWith(
        isSignedIn: user != null,
        userId: user?.uid,
        displayName: user?.displayName,
        email: user?.email,
        errorMessage: null,
      );

      // ログイン状態を SharedPreferences に保存
      if (user != null) {
        _saveLoginState(user);
      } else {
        _clearLoginState();
      }
    });
  }

  /// アプリ起動時の自動ログイン処理
  Future<void> _checkAutoLogin() async {
    try {
      // セッションが有効かチェック
      if (!SharedPreference.isSessionValid) {
        await _clearLoginState();
        state = state.copyWith(
          isSignedIn: false,
          userId: null,
          displayName: null,
          email: null,
        );
        return;
      }

      // オフラインなら既存のセッション情報を使用
      final hasNetwork = await _hasInternetConnection();
      if (!hasNetwork) {
        if (SharedPreference.isLoggedIn) {
          // オフラインでもセッションが有効な場合はログイン状態を維持
          state = state.copyWith(
            isSignedIn: true,
            userId: 'offline_user', // オフライン時の仮ID
            displayName: 'オフライン',
            email: null,
          );
        } else {
          state = state.copyWith(
            isSignedIn: false,
            userId: null,
            displayName: null,
            email: null,
          );
        }
        return;
      }

      // SharedPreferences からログイン状態を確認
      if (SharedPreference.isLoggedIn) {
        // Firebase の現在のユーザーを確認
        final currentUser = FirebaseAuthService.currentUser;
        if (currentUser != null) {
          // セッションが有効な場合、状態を更新
          state = state.copyWith(
            isSignedIn: true,
            userId: currentUser.uid,
            displayName: currentUser.displayName,
            email: currentUser.email,
          );
        } else {
          // Firebase セッションが無効な場合、自動ログインを試行
          await _attemptSessionRestore();
        }
      } else {
        // SharedPreferences でログイン状態が false の場合
        state = state.copyWith(
          isSignedIn: false,
          userId: null,
          displayName: null,
          email: null,
        );
      }
    } catch (e) {
      log('自動ログイン処理エラー: $e');
      await _clearLoginState();
      state = state.copyWith(
        isSignedIn: false,
        userId: null,
        displayName: null,
        email: null,
      );
    }
  }

  /// 簡易ネットワーク到達性チェック（依存を増やさず lightweight に判定）
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// ログイン状態を SharedPreferences に保存（ログイン情報は保存しない）
  Future<void> _saveLoginState(User user) async {
    try {
      // 認証プロバイダーを判定
      String? provider;
      for (final providerData in user.providerData) {
        if (providerData.providerId == 'google.com') {
          provider = 'google';
          break;
        } else if (providerData.providerId == 'apple.com') {
          provider = 'apple';
          break;
        }
      }
      
      await SharedPreference.saveLoginState(provider: provider);
    } catch (e) {
      log('ログイン状態保存エラー: $e');
    }
  }

  /// セッション復元を試行
  Future<void> _attemptSessionRestore() async {
    try {
      final lastProvider = SharedPreference.lastLoginProvider;
      if (lastProvider == null) {
        await _clearLoginState();
        return;
      }

      // 最後のログインプロバイダーに基づいて自動ログインを試行
      if (lastProvider == 'google') {
        await _restoreGoogleSession();
      } else if (lastProvider == 'apple') {
        await _restoreAppleSession();
      } else {
        await _clearLoginState();
      }
    } catch (e) {
      log('セッション復元エラー: $e');
      await _clearLoginState();
    }
  }

  /// Google セッション復元
  Future<void> _restoreGoogleSession() async {
    try {
      // Google Sign-in の自動ログインを試行
      final user = await FirebaseAuthService.signInWithGoogle();
      if (user != null) {
        await _saveLoginState(user.user!);
        state = state.copyWith(
          isSignedIn: true,
          userId: user.user!.uid,
          displayName: user.user!.displayName,
          email: user.user!.email,
        );
        log('Google セッション復元成功');
      } else {
        await _clearLoginState();
        state = state.copyWith(
          isSignedIn: false,
          userId: null,
          displayName: null,
          email: null,
        );
      }
    } catch (e) {
      log('Google セッション復元エラー: $e');
      await _clearLoginState();
    }
  }

  /// Apple セッション復元
  Future<void> _restoreAppleSession() async {
    try {
      // Apple Sign-in の自動ログインを試行
      final user = await FirebaseAuthService.signInWithApple();
      if (user != null) {
        await _saveLoginState(user.user!);
        state = state.copyWith(
          isSignedIn: true,
          userId: user.user!.uid,
          displayName: user.user!.displayName,
          email: user.user!.email,
        );
        log('Apple セッション復元成功');
      } else {
        await _clearLoginState();
        state = state.copyWith(
          isSignedIn: false,
          userId: null,
          displayName: null,
          email: null,
        );
      }
    } catch (e) {
      log('Apple セッション復元エラー: $e');
      await _clearLoginState();
    }
  }

  /// ログイン状態を SharedPreferences からクリア
  Future<void> _clearLoginState() async {
    try {
      await SharedPreference.clearLoginState();
    } catch (e) {
      log('ログイン状態クリアエラー: $e');
    }
  }

  /// Google サインイン
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userCredential = await FirebaseAuthService.signInWithGoogle();

      if (userCredential != null) {
        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          userId: userCredential.user?.uid,
          displayName: userCredential.user?.displayName,
          email: userCredential.user?.email,
        );
        AppUtils.showSnackBar('ログインしました');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'サインインがキャンセルされました',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ログインに失敗しました: ${e.toString()}',
      );
      AppUtils.showSnackBar('ログインに失敗しました: ${e.toString()}');
    }
  }

  /// Apple サインイン
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userCredential = await FirebaseAuthService.signInWithApple();

      if (userCredential != null) {
        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          userId: userCredential.user?.uid,
          displayName: userCredential.user?.displayName,
          email: userCredential.user?.email,
        );
        AppUtils.showSnackBar('ログインしました');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'サインインがキャンセルされました',
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'このメールアドレスは既に別の方法で登録されています\n既存の方法でログイン後、アカウント連携してください';
          break;
        case 'invalid-credential':
          errorMessage = '認証情報が無効です。もう一度お試しください。';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Appleサインインが有効化されていません';
          break;
        case 'user-disabled':
          errorMessage = 'このアカウントは無効化されています';
          break;
        case 'user-not-found':
          errorMessage = 'ユーザーが見つかりませんでした';
          break;
        case 'wrong-password':
          errorMessage = 'パスワードが正しくありません';
          break;
        case 'invalid-verification-code':
          errorMessage = '認証コードが無効です';
          break;
        case 'invalid-verification-id':
          errorMessage = '認証IDが無効です';
          break;
        default:
          errorMessage = '登録を完了できませんでした: ${e.code} - ${e.message}';
      }

      log('Apple サインイン Firebase エラー: code=${e.code}, message=${e.message}');

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      AppUtils.showSnackBar(errorMessage);
    } catch (e) {
      log('Apple サインイン予期しないエラー: $e');

      final errorMessage = '登録を完了できませんでした: ${e.toString()}';
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      AppUtils.showSnackBar(errorMessage);
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await FirebaseAuthService.signOut();
      await _clearLoginState();

      state = state.copyWith(
        isLoading: false,
        isSignedIn: false,
        userId: null,
        displayName: null,
        email: null,
      );
      AppUtils.showSnackBar('ログアウトしました');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ログアウトに失敗しました: ${e.toString()}',
      );
      AppUtils.showSnackBar('ログアウトに失敗しました: ${e.toString()}');
    }
  }

  /// Apple サインイン（nonceあり版）
  Future<void> signInWithAppleWithNonce() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userCredential =
          await FirebaseAuthService.signInWithAppleWithNonce();

      if (userCredential != null) {
        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          userId: userCredential.user?.uid,
          displayName: userCredential.user?.displayName,
          email: userCredential.user?.email,
        );
        AppUtils.showSnackBar('ログインしました（nonceあり）');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'サインインがキャンセルされました',
        );
      }
    } catch (e) {
      log('Apple サインイン（nonceあり）予期しないエラー: $e');

      final errorMessage = '登録を完了できませんでした（nonceあり）: ${e.toString()}';
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      AppUtils.showSnackBar(errorMessage);
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
