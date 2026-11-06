import '../../../../core/network/api_client.dart';
import '../models/usuario_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login(String usuario, String password) async {
    final response = await _client.post(
      '/auth/login',
      data: {'usuario': usuario, 'password': password},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<UsuarioModel> me() async {
    final response = await _client.get('/auth/me');
    final data = Map<String, dynamic>.from(response as Map);
    return UsuarioModel.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
