import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/src/repositories/repository_providers.dart';
import 'package:tree/src/services/firebase/firebase_auth_service.dart';
import 'package:tree/src/services/firebase/firebase_service.dart';
import 'package:tree/src/services/firebase/firebase_storage_service.dart';
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

    // 既存ユーザー向けのマイグレーション処理
    SharedPreference.migrateFromOldProviderFlags();

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

      log('ログイン時のUID保存: ${user.uid}');

      // プロバイダー連携フラグを設定（後方互換性のため）
      if (provider == 'apple') {
        await SharedPreference.setAppleLinked(true);
        await SharedPreference.addAppleLinkedUserId(user.uid);
        log('Apple UIDを保存: ${user.uid}');
      } else if (provider == 'google') {
        await SharedPreference.setGoogleLinked(true);
        await SharedPreference.addGoogleLinkedUserId(user.uid);
        log('Google UIDを保存: ${user.uid}');
      }
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
    } on Exception catch (e) {
      String errorMessage;
      if (e.toString().contains('network_error')) {
        errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'サインインに失敗しました。もう一度お試しください。';
      } else {
        errorMessage = 'ログインに失敗しました: ${e.toString()}';
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      AppUtils.showSnackBar(errorMessage);
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

  /// 個別アカウントを削除（認証→削除）
  Future<void> deleteIndividualAccount(String provider) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      log('個別アカウント削除開始: $provider');

      // 現在の認証状態を確認
      final isCurrentlySignedIn = FirebaseAuthService.isSignedIn;
      log('現在の認証状態: $isCurrentlySignedIn');

      if (!isCurrentlySignedIn) {
        // ログアウト状態の場合は、まずログインを促す
        throw Exception('アカウント削除にはログインが必要です。先にログインしてください。');
      }

      // 現在のユーザーIDを取得
      final currentUserId = FirebaseAuthService.userId;
      if (currentUserId == null) {
        throw Exception('ユーザーIDが取得できません');
      }

      log('現在のユーザーID: $currentUserId');

      // SharedPreferenceに保存されているUIDを確認
      final savedAppleIds = await SharedPreference.getAppleLinkedUserIds();
      final savedGoogleIds = await SharedPreference.getGoogleLinkedUserIds();
      log('SharedPreferenceに保存されているUID:');
      log('- Apple: $savedAppleIds');
      log('- Google: $savedGoogleIds');

      // 現在のユーザーIDがリストに含まれているか確認
      bool isCurrentUserInList = false;
      if (provider.toLowerCase() == 'apple') {
        isCurrentUserInList = savedAppleIds.contains(currentUserId);
      } else if (provider.toLowerCase() == 'google') {
        isCurrentUserInList = savedGoogleIds.contains(currentUserId);
      }

      if (!isCurrentUserInList) {
        throw Exception('現在のアカウントが連携リストに含まれていません');
      }

      // 1. 現在のアカウントのクラウドメモを削除
      log('現在のアカウントのクラウドメモ削除開始');
      await _deleteAllCloudMemos();
      log('現在のアカウントのクラウドメモ削除完了');

      // 2. 現在のアカウントを削除（再認証が必要な場合は自動で実行される）
      await FirebaseAuthService.deleteAccount();
      log('個別アカウント削除完了: $provider');

      // 3. 認証状態を完全にクリア（自動ログインを防ぐため）
      await FirebaseAuthService.clearAuthState();
      log('認証状態を完全にクリアしました');

      await _clearLoginState();

      // 4. 現在のユーザーIDをリストから削除
      if (provider.toLowerCase() == 'apple') {
        await SharedPreference.removeAppleLinkedUserId(currentUserId);
        // リストが空になったらフラグもクリア
        final remainingIds = await SharedPreference.getAppleLinkedUserIds();
        if (remainingIds.isEmpty) {
          await SharedPreference.setAppleLinked(false);
        }
        log('Apple連携から現在のユーザーIDを削除');
      } else if (provider.toLowerCase() == 'google') {
        await SharedPreference.removeGoogleLinkedUserId(currentUserId);
        // リストが空になったらフラグもクリア
        final remainingIds = await SharedPreference.getGoogleLinkedUserIds();
        if (remainingIds.isEmpty) {
          await SharedPreference.setGoogleLinked(false);
        }
        log('Google連携から現在のユーザーIDを削除');
      }

      state = state.copyWith(
        isLoading: false,
        isSignedIn: false,
        userId: null,
        displayName: null,
        email: null,
      );

      AppUtils.showSnackBar('$provider認証を解除しました（このアカウントのクラウドメモは削除されました）');
    } catch (e) {
      log('個別アカウント削除エラー: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '認証解除に失敗しました: ${e.toString()}',
      );
      AppUtils.showSnackBar('認証解除に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  /// 現在のアカウントのクラウドメモを削除
  Future<void> _deleteAllCloudMemos() async {
    try {
      final cloudFileNames = await FirebaseStorageService.getMemoFileNames();
      for (final fileName in cloudFileNames) {
        await FirebaseStorageService.deleteMemo(fileName);
      }
    } catch (e) {
      log('クラウドメモ削除エラー: $e');
      // クラウド削除エラーは致命的ではないため、続行
    }
  }

  /// アカウントとメモを完全削除（現在のアカウントのみ）
  Future<void> deleteAccountWithMemos() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      log('アカウント完全削除開始');

      // 現在のアカウントのクラウドメモを削除
      log('現在のアカウントのクラウドメモ削除開始');
      await _deleteAllCloudMemos();
      log('現在のアカウントのクラウドメモ削除完了');

      // ローカルのメモを全て削除
      log('ローカルメモ削除開始');
      await _deleteAllLocalMemos();
      log('ローカルメモ削除完了');

      // Firebaseアカウントを削除
      log('Firebaseアカウント削除開始');
      await FirebaseAuthService.deleteAccount();
      log('Firebaseアカウント削除完了');

      await _clearLoginState();

      // 現在のユーザーIDを全プロバイダーから削除
      final currentUserId = state.userId;
      if (currentUserId != null) {
        await SharedPreference.removeAppleLinkedUserId(currentUserId);
        await SharedPreference.removeGoogleLinkedUserId(currentUserId);

        // 各プロバイダーのリストが空になったらフラグもクリア
        final remainingAppleIds =
            await SharedPreference.getAppleLinkedUserIds();
        final remainingGoogleIds =
            await SharedPreference.getGoogleLinkedUserIds();

        if (remainingAppleIds.isEmpty) {
          await SharedPreference.setAppleLinked(false);
        }
        if (remainingGoogleIds.isEmpty) {
          await SharedPreference.setGoogleLinked(false);
        }
      }
      log('プロバイダー連携から現在のユーザーIDを削除');

      state = state.copyWith(
        isLoading: false,
        isSignedIn: false,
        userId: null,
        displayName: null,
        email: null,
      );

      AppUtils.showSnackBar('アカウントとメモを完全削除しました');
      log('アカウント完全削除完了');
    } catch (e) {
      log('アカウント完全削除エラー: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'アカウント削除に失敗しました: ${e.toString()}',
      );
      AppUtils.showSnackBar('アカウント削除に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  /// ローカルのメモを全て削除
  Future<void> _deleteAllLocalMemos() async {
    try {
      final fileRepository = ref.read(fileRepositoryProvider);
      final fileNames = await fileRepository.getAllDisplayNames();
      for (final fileName in fileNames) {
        await fileRepository.deleteFileByDisplayName(fileName);
      }
    } catch (e) {
      log('ローカルメモ削除エラー: $e');
      // ローカル削除エラーは致命的ではないため、続行
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
