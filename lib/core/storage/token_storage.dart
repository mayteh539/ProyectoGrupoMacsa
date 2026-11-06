import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento del token JWT con cache en memoria.
///
/// En web el almacenamiento seguro requiere un contexto seguro (HTTPS o
/// localhost). Si no esta disponible, el token se conserva solo en memoria.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'macsa_access_token';

  final FlutterSecureStorage _storage;
  String? _cached;

  String? get token => _cached;

  Future<String?> read() async {
    if (_cached != null) return _cached;
    try {
      _cached = await _storage.read(key: _tokenKey);
    } catch (_) {
      _cached = null;
    }
    return _cached;
  }

  Future<void> write(String token) async {
    _cached = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // Sin almacenamiento persistente: la sesion vive en memoria.
    }
  }

  Future<void> clear() async {
    _cached = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      // Nada que limpiar.
    }
  }
}
