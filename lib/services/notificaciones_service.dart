import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/notificacion.dart';
import 'api_client.dart';

class NotificacionesService {
  static Future<List<Notificacion>> fetch({
    int page = 1,
    int limit = 20,
    bool unread = false,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/notificaciones',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (unread) 'unread': true,
        },
      );

      final body = res.data;
      final data = body['data'] ?? body;

      List list = [];

      // puede venir data como List o como {rows: []}
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        final rows = data['rows'] ?? data['items'] ?? data['data'];
        if (rows is List) list = rows;
      }

      // parse y además intenta parsear json string en "data"
      return list.map((e) {
        final m = Map<String, dynamic>.from(e);

        final rawData = m['data'];
        if (rawData is String && rawData.trim().isNotEmpty) {
          try {
            m['data'] = jsonDecode(rawData);
          } catch (_) {
            // si no es json, lo dejamos como string
          }
        }

        return Notificacion.fromJson(m);
      }).toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al cargar notificaciones';
      throw Exception(msg);
    }
  }

  static Future<void> markAsRead(String id) async {
    try {
      await ApiClient.dio.put('/notificaciones/$id/leido');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'No se pudo marcar como leída';
      throw Exception(msg);
    }
  }
}
