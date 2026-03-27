import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class AdminObjetosPerdidosService {
  static Future<void> reportar({
    required String titulo,
    required String descripcion,
    String? lugarEncontrado,
    String? estado, // perdido|encontrado|devuelto
    File? foto,
  }) async {
    try {
      final form = FormData.fromMap({
        'titulo': titulo,
        'descripcion': descripcion,
        if (lugarEncontrado != null && lugarEncontrado.isNotEmpty)
          'lugar_encontrado': lugarEncontrado,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
        if (foto != null)
          'foto': await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split(Platform.pathSeparator).last,
          ),
      });

      await ApiClient.dio.post(
        '/objetos-perdidos/reportar-objetos-perdidos',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al reportar objeto perdido';
      throw Exception(msg);
    }
  }

  static Future<void> actualizarEstado({
    required int id,
    required String estado,
  }) async {
    try {
      await ApiClient.dio.put(
        '/objetos-perdidos/$id/estado',
        data: {'estado': estado},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al actualizar estado';
      throw Exception(msg);
    }
  }

  static Future<void> eliminar({required int id}) async {
    try {
      await ApiClient.dio.delete('/objetos-perdidos/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al eliminar objeto perdido';
      throw Exception(msg);
    }
  }
}
