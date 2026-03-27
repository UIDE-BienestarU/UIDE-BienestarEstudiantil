import 'dart:io';

import 'package:dio/dio.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'correo_institucional': email,
          'contrasena': password,
        },
      );

      final body = res.data;
      if (body is! Map || body['data'] is! Map) {
        throw Exception('Respuesta inválida del servidor');
      }

      final data = body['data'] as Map<String, dynamic>;

      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      final user = data['user'];

      if (accessToken == null || refreshToken == null || user == null) {
        throw Exception('Datos incompletos en login');
      }

      await TokenStorage.saveTokens(accessToken, refreshToken);

      return user as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map ? data['message'] ?? data['error'] : null) ??
          'Error de inicio de sesión';
      throw Exception(msg);
    }
  }

  /// 🚪 Logout seguro (no depende del interceptor)
  static Future<void> logout() async {
    final refresh = await TokenStorage.getRefreshToken();

    try {
      if (refresh != null && refresh.isNotEmpty) {
        // ⚠️ Usamos Dio "raw" para evitar interceptor
        final raw = Dio(
          BaseOptions(
            baseUrl: ApiClient.baseUrl,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.acceptHeader: 'application/json',
            },
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 12),
          ),
        );

        await raw.post(
          '/auth/logout',
          data: {'refreshToken': refresh},
        );
      }
    } catch (_) {
      // aunque falle el backend, seguimos
    } finally {
      // ✅ SIEMPRE limpiamos local
      await TokenStorage.clear();
    }
  }
}
