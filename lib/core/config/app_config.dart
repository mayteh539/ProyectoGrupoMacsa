import 'package:flutter/foundation.dart';

/// Configuracion central de la aplicacion.
///
/// La URL de la API se puede sobreescribir en tiempo de compilacion:
/// `flutter run --dart-define=API_URL=http://192.168.1.50:3000`
class AppConfig {
  AppConfig._();

  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override.replaceAll(RegExp(r'/+$'), '');
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static String get apiBaseUrl => '$baseUrl/api';
  static String get socketUrl => baseUrl;

  static const String appName = 'Macsa Tickets';
  static const String appVersion = '1.0.0';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
