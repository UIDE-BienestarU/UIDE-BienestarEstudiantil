import 'package:dio/dio.dart';
import 'api_client.dart';

class ComentariosService {
  // GET /api/objetos-perdidos/:id/comentarios
  static Future<List<dynamic>> fetch(
      {required String objetoId, int page = 1, int limit = 50}) async {
    final res = await ApiClient.dio.get(
      '/objetos-perdidos/$objetoId/comentarios',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = res.data;
    return (body['data'] as List? ?? []);
  }

  // POST /api/objetos-perdidos/:id/comentarios
  static Future<Map<String, dynamic>> crear(
      {required String objetoId,
      required String mensaje,
      bool esReclamo = false}) async {
    final res = await ApiClient.dio.post(
      '/objetos-perdidos/$objetoId/comentarios',
      data: {'mensaje': mensaje, 'es_reclamo': esReclamo},
    );

    final body = res.data;
    final data = body['data'] ?? {};
    return Map<String, dynamic>.from(data);
  }
}
