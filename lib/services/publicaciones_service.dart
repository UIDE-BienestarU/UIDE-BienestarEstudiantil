import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/aviso.dart';

class PublicacionesService {
  static Future<List<Aviso>> fetchPublicaciones({
    int page = 1,
    int limit = 20,
    bool? activo, // opcional: filtrar en backend si lo soporta
  }) async {
    try {
      final qp = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (activo != null) 'activo': activo,
      };

      final res = await ApiClient.dio.get(
        '/publicaciones/ver-publicaciones',
        queryParameters: qp,
      );

      final body = res.data;
      final data = (body is Map) ? body['data'] : null;

      // Algunos backends devuelven data: [] o data: {rows: []}
      final List list = (data is List)
          ? data
          : (data is Map && data['rows'] is List)
              ? (data['rows'] as List)
              : const [];

      return list
          .whereType<Map>()
          .map((e) => AvisoFromApi.fromPublicacionApi(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al cargar publicaciones';
      throw Exception(msg);
    }
  }
}
