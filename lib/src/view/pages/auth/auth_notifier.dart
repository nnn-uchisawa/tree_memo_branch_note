import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> signOut() async {
    state = const AuthState();
  }

  Future<void> deleteIndividualAccount(String provider) async {}
}
