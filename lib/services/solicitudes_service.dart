import 'package:dio/dio.dart';
import 'api_client.dart';

class SolicitudesService {
  static Future<int> crearSolicitud(Map<String, dynamic> payload) async {
    try {
      final res = await ApiClient.dio.post('/solicitudes', data: payload);

      final body = res.data;
      final data = body['data'] ?? body;

      final rawId = data['id'] ?? data['solicitud_id'];
      if (rawId == null) {
        throw Exception('No se recibió ID de solicitud');
      }

      return rawId is int ? rawId : int.parse(rawId.toString());
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al crear solicitud';
      throw Exception(msg);
    }
  }
}
