import 'package:dio/dio.dart';
import 'api_client.dart';

class PerfilService {
  static Future<Map<String, dynamic>> getPerfil() async {
    try {
      final res = await ApiClient.dio.get('/perfil');
      final body = res.data;
      final data = body['data'] ?? body;
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al cargar perfil';
      throw Exception(msg);
    }
  }
}
