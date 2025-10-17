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
      // オフラインなら即座に未ログイン状態にして起動を継続
      final hasNetwork = await _hasInternetConnection();
      if (!hasNetwork) {
        if (FirebaseAuthService.isSignedIn) {
          await FirebaseAuthService.signOut();
        }
        await _clearLoginState();
        state = state.copyWith(
          isSignedIn: false,
          userId: null,
          displayName: null,
          email: null,
        );
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
          // セッションが無効な場合、SharedPreferences をクリア
          await _clearLoginState();
        }
      }
    } catch (e) {
      log('自動ログイン確認エラー: $e');
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
      await SharedPreference.saveLoginState();
    } catch (e) {
      log('ログイン状態保存エラー: $e');
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
