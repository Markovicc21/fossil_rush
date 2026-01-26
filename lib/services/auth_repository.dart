class AuthResult {
  final bool ok;
  final String? message;

  const AuthResult._(this.ok, this.message);

  const AuthResult.ok() : this._(true, null);
  const AuthResult.fail(String msg) : this._(false, msg);
}

class AuthSession {
  final String username;
  final String? token; //kasnije JWt / accsess token

  const AuthSession({required this.username, this.token});
}

abstract class AuthRepository {
  Future<AuthResult> register({
    required String username,
    required String password,
    required String confirmPassword,
  });

  Future<AuthResult> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<AuthSession?> session();
  Future<bool> isLoggedIn();
}
