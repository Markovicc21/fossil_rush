import 'auth_repository.dart';
import 'firebase_auth_repository.dart';

class AuthService {
  AuthService._();

  // Sada
  static final AuthRepository repo = FirebaseAuthRepository();

  // Kad se uvede bekend menjanje linije u:
  // static final AuthRepository repo = ApiAuthRepository();
}
