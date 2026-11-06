import '../entities/usuario.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String usuario, String password);
  Future<Usuario> me();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> logout();
  Future<String?> readToken();
}
