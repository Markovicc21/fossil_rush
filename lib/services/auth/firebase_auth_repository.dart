import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  static const String _fallbackDomain = 'fossil.local';

  String _toEmail(String username) {
    final u = username.trim();
    if (u.contains('@')) return u;
    return '$u@$_fallbackDomain';
  }

  String _fromUser(fb.User user) {
    final name = user.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = user.email;
    if (email == null || email.isEmpty) return 'user';
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Username already exists!';
      case 'invalid-email':
        return 'Invalid username!';
      case 'weak-password':
        return 'Password is too weak!';
      case 'user-not-found':
        return 'User not found!';
      case 'wrong-password':
        return 'Wrong password!';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Auth failed';
    }
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

    final email = _toEmail(u);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _auth.currentUser;
      if (user != null && !u.contains('@')) {
        await user.updateDisplayName(u);
        await user.reload();
      }
      return const AuthResult.ok();
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapError(e));
    } catch (_) {
      return const AuthResult.fail('Auth failed');
    }
  }

  @override
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final u = username.trim();
    if (u.isEmpty) return const AuthResult.fail('Username is empty!');
    if (password.isEmpty) return const AuthResult.fail('Password is empty!');

    final email = _toEmail(u);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const AuthResult.ok();
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapError(e));
    } catch (_) {
      return const AuthResult.fail('Auth failed');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<AuthSession?> session() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthSession(
      userId: user.uid,
      username: _fromUser(user),
      email: user.email,
      token: null,
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}
