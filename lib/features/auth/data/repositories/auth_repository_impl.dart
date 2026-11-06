import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login(String usuario, String password) async {
    final response = await _remote.login(usuario, password);
    final token = response['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('La respuesta del servidor no incluyo el token');
    }

    await _tokenStorage.write(token);
    final user = UsuarioModel.fromJson(
      Map<String, dynamic>.from(response['user'] as Map),
    );

    return AuthSession(token: token, user: user);
  }

  @override
  Future<Usuario> me() => _remote.me();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  @override
  Future<String?> readToken() => _tokenStorage.read();
}
