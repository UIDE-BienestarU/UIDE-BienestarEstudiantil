import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._();

  static const String baseUrl = 'https://api-prod.uidehub.tech/api';

  // 🔒 Lock para evitar múltiples refresh al mismo tiempo
  static Completer<bool>? _refreshCompleter;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await TokenStorage.getAccessToken();
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          final req = e.requestOptions;

          // ✅ evita retry infinito
          final alreadyRetried = req.extra['retried'] == true;

          if (e.response?.statusCode == 401 && !alreadyRetried) {
            // 🔒 Si ya hay refresh en curso, espera ese resultado.
            final refreshed = await _refreshWithLock();

            if (refreshed) {
              // marcamos que ya se reintentó
              req.extra['retried'] = true;

              final newAccess = await TokenStorage.getAccessToken();
              if (newAccess != null && newAccess.isNotEmpty) {
                req.headers['Authorization'] = 'Bearer $newAccess';
              }

              try {
                final cloneResponse = await dio.fetch(req);
                return handler.resolve(cloneResponse);
              } catch (_) {
                // si vuelve a fallar, cae al handler.next(e)
              }
            } else {
              // refresh falló → tokens fuera, deja pasar el error
              await TokenStorage.clear();
            }
          }

          return handler.next(e);
        },
      ),
    );

  /// 🔒 Ejecuta refresh con “candado”: si ya hay uno corriendo, lo espera.
  static Future<bool> _refreshWithLock() async {
    // Si hay refresh en curso, esperamos su resultado
    final existing = _refreshCompleter;
    if (existing != null) return existing.future;

    _refreshCompleter = Completer<bool>();

    try {
      final ok = await _tryRefreshToken();
      _refreshCompleter!.complete(ok);
      return ok;
    } catch (_) {
      // Por seguridad, si algo raro pasa
      if (!(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter!.complete(false);
      }
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  // ✅ Refresh token usando tu JSON real: { success, data: { accessToken, refreshToken } }
  static Future<bool> _tryRefreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      // NO uses ApiClient.dio aquí (evitas loop del interceptor)
      final raw = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: 'application/json',
          },
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );

      final resp = await raw.post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );

      final body = resp.data;
      final map = (body is Map) ? body : <String, dynamic>{};
      final data =
          (map['data'] is Map) ? (map['data'] as Map) : <String, dynamic>{};

      final newAccess = data['accessToken']?.toString();
      final newRefresh = data['refreshToken']?.toString();

      if (newAccess == null ||
          newAccess.isEmpty ||
          newRefresh == null ||
          newRefresh.isEmpty) {
        await TokenStorage.clear();
        return false;
      }

      await TokenStorage.saveTokens(newAccess, newRefresh);
      return true;
    } catch (_) {
      await TokenStorage.clear();
      return false;
    }
  }
}
