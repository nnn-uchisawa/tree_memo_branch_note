import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isSignedIn,
    String? userId,
    String? displayName,
    String? email,
    String? errorMessage,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);
}
