/// 認証エラーを表すカスタム例外
class AuthenticationException implements Exception {
  final String message;
  final String? code;

  const AuthenticationException(this.message, {this.code});

  @override
  String toString() =>
      'AuthenticationException: $message${code != null ? ' (code: $code)' : ''}';
}
