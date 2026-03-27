import 'package:dio/dio.dart';
import 'api_client.dart';

class SugerenciasService {
  /// Backend: POST /sugerencias/enviar-sugerencia
  static Future<void> enviarSugerencia({required String mensaje}) async {
    try {
      await ApiClient.dio.post(
        '/sugerencias/enviar-sugerencia',
        data: {'mensaje': mensaje},
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map ? data['message'] ?? data['error'] : null) ??
          'Error al enviar sugerencia';
      throw Exception(msg.toString());
    }
  }
}
