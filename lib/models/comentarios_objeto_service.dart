import 'package:dio/dio.dart';
import 'api_client.dart';

class ComentarioObjeto {
  final int id;
  final int objetoId;
  final String mensaje;
  final DateTime createdAt;
  final String autorNombre;

  ComentarioObjeto({
    required this.id,
    required this.objetoId,
    required this.mensaje,
    required this.createdAt,
    required this.autorNombre,
  });

  factory ComentarioObjeto.fromJson(Map<String, dynamic> json) {
    final autor = json['autor'];
    final autorNombre =
        (autor is Map ? autor['nombre_completo'] : null)?.toString() ??
            'Estudiante';

    return ComentarioObjeto(
      id: int.tryParse('${json['id']}') ?? 0,
      objetoId: int.tryParse(
              '${json['objeto_id'] ?? json['objetoId'] ?? json['objeto_perdido_id']}') ??
          0,
      mensaje: (json['mensaje'] ?? '').toString(),
      createdAt: DateTime.tryParse(
              (json['createdAt'] ?? json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      autorNombre: autorNombre,
    );
  }
}

class ComentariosObjetoPage {
  final List<ComentarioObjeto> items;

  ComentariosObjetoPage({required this.items});
}

class ComentariosObjetoService {
  static Future<ComentariosObjetoPage> list({
    required int objetoId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/objetos-perdidos/$objetoId/comentarios',
        queryParameters: {'page': page, 'limit': limit},
      );

      final body = res.data;
      final data = (body is Map && body['data'] != null) ? body['data'] : body;

      // soporta: { data: { rows: [...] } } o { data: [...] }
      final rowsRaw = (data is Map) ? data['rows'] : data;
      final rows = (rowsRaw is List) ? rowsRaw : const [];

      final items = rows
          .whereType<Map>()
          .map((j) => ComentarioObjeto.fromJson(Map<String, dynamic>.from(j)))
          .toList();

      return ComentariosObjetoPage(items: items);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al cargar comentarios';
      throw Exception(msg);
    }
  }

  static Future<void> create({
    required int objetoId,
    required String mensaje,
    bool esReclamo = false,
  }) async {
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
