import 'package:dio/dio.dart';
import 'api_client.dart';

class SolicitudDraftService {
  /// Trae el draft más reciente del usuario (si existe).
  /// Asumimos que listMine devuelve lista ordenada por updatedAt desc.
  static Future<Map<String, dynamic>?> getLatestDraft() async {
    final res = await ApiClient.dio.get('/solicitudes/drafts');

    final body = res.data;
    final List items = (body['data'] ?? []) as List;

    if (items.isEmpty) return null;
    return items.first as Map<String, dynamic>;
  }

  /// Crea draft (backend guarda payload TEXT)
  static Future<Map<String, dynamic>> createDraft({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/solicitudes/draft',
        data: {
          // Ajuste típico: controller guarda esto en `payload` (TEXT)
          'payload': payload,
        },
      );

      final body = res.data;
      return (body['data'] ?? body) as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error creando borrador';
      throw Exception(msg);
    }
  }

  /// Actualiza draft por id
  static Future<Map<String, dynamic>> updateDraft({
    required String draftId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await ApiClient.dio.put(
        '/solicitudes/draft/$draftId',
        data: {'payload': payload},
      );

      final body = res.data;
      return (body['data'] ?? body) as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error actualizando borrador';
      throw Exception(msg);
    }
  }
}
