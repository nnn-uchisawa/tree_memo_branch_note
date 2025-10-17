import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tree/src/repositories/firebase_storage_repository.dart';
import 'package:tree/src/repositories/local_file_repository.dart';
import 'package:tree/src/repositories/repository_providers.dart';
import 'package:tree/src/view/pages/auth/auth_notifier.dart';
import 'package:tree/src/view/pages/auth/auth_state.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/home/home_state.dart';

/// テスト用のPageControllerのモック
class MockPageController extends PageController {
  double _mockOffset = 0.0;
  double _mockPage = 0.0;

  @override
  double get offset => _mockOffset;

  @override
  double? get page => _mockPage;

  void setMockOffset(double value) {
    _mockOffset = value;
  }

  void setMockPage(double value) {
    _mockPage = value;
  }
}

/// MaterialAppでラップするテストヘルパー
Widget wrapWithMaterialApp(Widget child, {PageController? pageController}) {
  return MaterialApp(home: Scaffold(body: child));
}

/// テスト用のHomeStateモック
final mockHomeState = HomeState(fileNames: ['test_file1', 'test_file2']);

/// テスト用のAuthStateモック
final mockAuthState = AuthState(
  isSignedIn: false,
  userId: null,
  displayName: null,
  email: null,
  errorMessage: null,
);

/// テスト用のProviderScopeでラップするヘルパー
Widget wrapWithProviderScope(Widget child) {
  return ProviderScope(
    overrides: [
      homeProvider.overrideWithValue(mockHomeState),
      authProvider.overrideWithValue(mockAuthState),
      fileRepositoryProvider.overrideWithValue(LocalFileRepository()),
      storageRepositoryProvider.overrideWithValue(FirebaseStorageRepository()),
    ],
    child: MaterialApp(home: child),
  );
}
