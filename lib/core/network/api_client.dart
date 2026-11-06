import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/upload_file.dart';
import 'api_exception.dart';

/// Envoltorio de Dio que normaliza errores y expone las operaciones usadas.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> patch(String path, {Object? data}) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete<dynamic>(path);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// Envia un formulario multipart con una imagen opcional.
  Future<dynamic> upload(
    String path, {
    Map<String, String> fields = const {},
    UploadFile? image,
    String fileField = 'imagen',
  }) async {
    try {
      final formData = FormData();
      fields.forEach((key, value) {
        if (value.isNotEmpty) {
          formData.fields.add(MapEntry(key, value));
        }
      });

      if (image != null) {
        formData.files.add(
          MapEntry(
            fileField,
            MultipartFile.fromBytes(image.bytes, filename: image.name),
          ),
        );
      }

      final response = await _dio.post<dynamic>(path, data: formData);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// Normaliza la URL de un archivo servido por la API.
  ///
  /// El backend devuelve URLs absolutas con su propio host; en el emulador de
  /// Android ese host no es accesible, por lo que se reemplaza por el de la app.
  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;
    final uploadsIndex = url.indexOf('/uploads/');
    if (uploadsIndex >= 0) {
      return '${AppConfig.baseUrl}${url.substring(uploadsIndex)}';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${AppConfig.baseUrl}$url';
  }
}
