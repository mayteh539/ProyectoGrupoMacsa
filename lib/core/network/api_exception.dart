import 'package:dio/dio.dart';

/// Error de negocio o de red normalizado para toda la aplicacion.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (data is Map) {
      final errorBody = data['error'];
      if (errorBody is Map) {
        final message = errorBody['message'];
        final code = errorBody['code'];
        if (message is String && message.isNotEmpty) {
          return ApiException(
            message,
            statusCode: response?.statusCode,
            code: code is String ? code : null,
          );
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'El servidor tardo demasiado en responder. Intente de nuevo.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No se pudo conectar con el servidor. Verifique su red y la configuracion de la API.',
        );
      case DioExceptionType.cancel:
        return const ApiException('La solicitud fue cancelada.');
      default:
        return ApiException(
          'Ocurrio un error inesperado al comunicarse con el servidor.',
          statusCode: response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
