import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class AdminPublicacionesService {
  static Future<void> crear({
    required String titulo,
    required String contenido,
    File? imagenFile,
  }) async {
    try {
      if (imagenFile != null) {
        final form = FormData.fromMap({
          'titulo': titulo,
          'contenido': contenido,
          'imagen': await MultipartFile.fromFile(
            imagenFile.path,
            filename: imagenFile.path.split(Platform.pathSeparator).last,
          ),
        });

        await ApiClient.dio.post(
          '/publicaciones/publicaciones-crear',
          data: form,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        // sin imagen igual funciona (tu swagger lo marca opcional)
        await ApiClient.dio.post(
          '/publicaciones/publicaciones-crear',
          data: {'titulo': titulo, 'contenido': contenido},
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map ? data['message'] ?? data['error'] : null) ??
          'Error creando publicación';
      throw Exception(msg.toString());
    }
  }
}
