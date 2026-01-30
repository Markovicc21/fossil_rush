import 'auth_repository.dart';
import 'local_auth_repository.dart';

class AuthService {
  AuthService._();

  // Sada
  static final AuthRepository repo = LocalAuthRepository();

  // Kad se uvede bekend menjanje linije u:
  // static final AuthRepository repo = ApiAuthRepository();
}
