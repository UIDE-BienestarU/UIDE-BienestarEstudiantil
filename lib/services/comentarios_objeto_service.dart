import 'package:dio/dio.dart';
import '../services/api_client.dart';

class ComentarioObjetoDto {
  final int id;
  final String mensaje;
  final DateTime createdAt;
  final String autorNombre;

  ComentarioObjetoDto({
    required this.id,
    required this.mensaje,
    required this.createdAt,
    required this.autorNombre,
  });

  factory ComentarioObjetoDto.fromJson(Map<String, dynamic> json) {
    final autor =
        (json['autor'] ?? json['reportador'] ?? json['usuario'] ?? {}) as Map;
    final nombre = (autor['nombre_completo'] ?? autor['nombre'] ?? 'Estudiante')
        .toString();

    return ComentarioObjetoDto(
      id: int.tryParse('${json['id']}') ?? 0,
      mensaje: (json['mensaje'] ?? json['texto'] ?? '').toString(),
      createdAt: DateTime.tryParse(
              '${json['createdAt'] ?? json['created_at'] ?? ''}') ??
          DateTime.now(),
      autorNombre: nombre,
    );
  }
}

class ComentariosObjetoService {
  static Future<List<ComentarioObjetoDto>> list(
      {required int objetoId, int page = 1, int limit = 50}) async {
    try {
      final res = await ApiClient.dio.get(
        '/objetos-perdidos/$objetoId/comentarios',
        queryParameters: {'page': page, 'limit': limit},
      );

      final body = res.data;
      final data = (body is Map) ? body['data'] : null;

      // Puede venir data: { rows: [...] } o data: [...]
      final rows = (data is Map && data['rows'] is List)
          ? List<Map<String, dynamic>>.from(data['rows'])
          : (data is List
              ? List<Map<String, dynamic>>.from(data)
              : <Map<String, dynamic>>[]);

      return rows.map((e) => ComentarioObjetoDto.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al cargar comentarios';
      throw Exception(msg);
    }
  }

  static Future<void> create(
      {required int objetoId,
      required String mensaje,
      bool esReclamo = false}) async {
    try {
      await ApiClient.dio.post(
        '/objetos-perdidos/$objetoId/comentarios',
        data: {'mensaje': mensaje, 'es_reclamo': esReclamo},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al enviar comentario';
      throw Exception(msg);
    }
  }
}
