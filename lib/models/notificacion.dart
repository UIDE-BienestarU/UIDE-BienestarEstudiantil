class Notificacion {
  final String id;
  final String? titulo;
  final String mensaje;
  final bool leido;
  final DateTime fechaEnvio;
  final Map<String, dynamic>? data;

  Notificacion({
    required this.id,
    this.titulo,
    required this.mensaje,
    required this.leido,
    required this.fechaEnvio,
    this.data,
  });

  static String _s(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static bool _b(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    // Sequelize: fecha_envio o createdAt
    final rawDate =
        json['fecha_envio'] ?? json['createdAt'] ?? json['fecha'] ?? '';
    final dt = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();

    Map<String, dynamic>? parsedData;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    } else if (rawData is String && rawData.trim().isNotEmpty) {
      // si backend guarda JSON stringify en TEXT
      try {
        parsedData = Map<String, dynamic>.from(
          (rawData.startsWith('{') ? _tryJson(rawData) : {}) as Map,
        );
      } catch (_) {}
    }

    return Notificacion(
      id: _s(json['id']),
      titulo: _s(json['titulo'], '').isEmpty ? null : _s(json['titulo']),
      mensaje: _s(json['mensaje']),
      leido: _b(json['leido']),
      fechaEnvio: dt,
      data: parsedData,
    );
  }

  // Helper local: evita importar dart:convert si no quieres en todo el archivo
  static dynamic _tryJson(String s) {
    // ignore: avoid_dynamic_calls
    return (s); // lo parsea el service si quieres; aquí lo dejamos simple
  }
}
