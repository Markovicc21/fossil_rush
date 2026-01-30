import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _KUsersJson = 'users_json'; //{pera , 123}
  static const _KLoggedIn = 'logged_in';
  static const _KUsername = 'logged_username';

  Future<Map<String, String>> _loadUsers() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_KUsersJson);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_KUsersJson, jsonEncode(users));
  }

  @override
  Future<AuthResult> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final u = username.trim();
    if (u.isEmpty) return const AuthResult.fail('Username is empty!');
    if (password.isEmpty) return const AuthResult.fail('Password is empty!');
    if (password != confirmPassword) {
      return const AuthResult.fail('Passwords do not match!');
    }

    final users = await _loadUsers();
    if (users.containsKey(u)) {
      return const AuthResult.fail('Username already exist!');
    }

    users[u] = password;
    await _saveUsers(users);

    return login(username: u, password: password);
  }

  @override
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final u = username.trim();
    if (u.isEmpty) return const AuthResult.fail('Username is empty!');
    if (password.isEmpty) return const AuthResult.fail('Password is empty!');

    final users = await _loadUsers();
    if (!users.containsKey(u)) return const AuthResult.fail('Users not found!');
    if (users[u] != password) return const AuthResult.fail('Wrong Password!');

    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_KLoggedIn, true);
    await sp.setString(_KUsername, u);

    return const AuthResult.ok();
  }

  @override
  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_KLoggedIn, false);
    await sp.remove(_KUsername);
  }

  @override
  Future<AuthSession?> session() async {
    final sp = await SharedPreferences.getInstance();
    final logged = sp.getBool(_KLoggedIn) ?? false;
    if (!logged) return null;

    final username = sp.getString(_KUsername);
    if (username == null || username.isEmpty) return null;

    return AuthSession(username: username, token: null);
  }

  @override
  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_KLoggedIn) ?? false;
  }
}
