import 'package:dio/dio.dart';
import '../models/solicitud.dart';
import 'api_client.dart';

/// ===============================
/// 📦 Wrapper de paginación
/// ===============================
class SolicitudPage {
  final List<Solicitud> items;
  final int page;
  final int limit;
  final int total;

  const SolicitudPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });
}

class SolicitudApiService {
  static int _asInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static String _asStr(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  /// ===============================
  /// ✅ Estados válidos backend
  /// enum: [Por revisar, En progreso, Observada, Derivada a becas, Aprobada, Rechazada]
  /// ===============================
  static String _normalizeEstadoForBackend(String estado) {
    final e = estado.trim().toLowerCase();

    if (e == 'por revisar') return 'Por revisar';
    if (e == 'en progreso') return 'En progreso';
    if (e == 'observada') return 'Observada';
    if (e == 'derivada a becas') return 'Derivada a becas';
    if (e == 'aprobada' || e == 'aprobado') return 'Aprobada';
    if (e == 'rechazada' || e == 'rechazado') return 'Rechazada';

    // Compat con estados antiguos en tu UI
    if (e == 'pendiente' || e == 'en revisión' || e == 'en revision') {
      return 'Por revisar';
    }

    // Fallback seguro
    return 'Por revisar';
  }

  /// =========================================
  /// 📄 Devuelve solicitudes PAGINADAS
  /// =========================================
  static Future<SolicitudPage> getSolicitudes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/ver-solicitudes',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final body = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final dataRaw = body['data'];
      final metaRaw = body['meta'];

      final list = (dataRaw is List)
          ? dataRaw
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList()
          : <Map<String, dynamic>>[];

      final meta = (metaRaw is Map)
          ? Map<String, dynamic>.from(metaRaw)
          : <String, dynamic>{};

      // Parse normal
      final parsed = list.map((j) => Solicitud.fromJson(j)).toList();

      // ✅ Anti-duplicados por ID
      final seen = <int>{};
      final unique = <Solicitud>[];
      for (final s in parsed) {
        if (seen.add(s.id)) unique.add(s);
      }

      return SolicitudPage(
        items: unique,
        page: _asInt(meta['page'], page),
        limit: _asInt(meta['limit'], limit),
        total: _asInt(meta['total'], unique.length),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map ? (data['message'] ?? data['error']) : null) ??
          'Error al cargar solicitudes';
      throw Exception(msg.toString());
    }
  }

  /// =========================================
  /// 🔁 Helper opcional (lista plana)
  /// =========================================
  static Future<List<Solicitud>> getSolicitudesFlat({
    int page = 1,
    int limit = 50,
  }) async {
    final paged = await getSolicitudes(page: page, limit: limit);
    return paged.items;
  }

  /// =========================================
  /// ✅ Actualizar estado (ADMIN)
  /// Ruta real (tu backend):
  /// PUT /solicitudes/:id/estado
  /// body: { estado_actual: "...", comentario?: "..." }
  /// =========================================
  static Future<Solicitud?> updateEstadoSolicitud({
    required int solicitudId,
    required String estado,
    String? comentario,
  }) async {
    try {
      final endpoint = '/solicitudes/$solicitudId/estado';

      final estadoBackend = _normalizeEstadoForBackend(estado);
      final comentarioLimpio = (comentario ?? '').trim();

      final res = await ApiClient.dio.put(
        endpoint,
        data: {
          // ✅ IMPORTANTE: el backend espera estado_actual (NO "estado")
          'estado_actual': estadoBackend,
          if (comentarioLimpio.isNotEmpty) 'comentario': comentarioLimpio,
        },
      );

      final body = res.data;

      // Tu middleware ok(res,{message,data}) suele devolver { data: ... }
      if (body is Map) {
        final data = body['data'];

        // Si el backend devuelve la solicitud actualizada
        if (data is Map) {
          return Solicitud.fromJson(Map<String, dynamic>.from(data));
        }

        // Si devuelve algo distinto (success / message), simplemente null
        return null;
      }

      return null;
    } on DioException catch (e) {
      final data = e.response?.data;

      // Mensajes típicos:
      final msg = (data is Map ? (data['message'] ?? data['error']) : null) ??
          _asStr(e.response?.statusMessage, 'Error al actualizar estado');

      throw Exception(msg.toString());
    }
  }
}
