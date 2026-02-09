class Solicitud {
  final int id;
  final int estudianteId;
  final int subtipoId;

  final String estado;
  final String fecha;
  final String nivelUrgencia;
  final String? observaciones;
  final String? comentario;

  final int? tipoId;
  final String? subtipoNombre;
  final String? estudianteNombre;
  final String? estudianteMatricula;

  // ✅ NUEVO: correo si viene embebido
  final String? estudianteCorreo;

  final List<dynamic> documentos;

  Solicitud({
    required this.id,
    required this.estudianteId,
    required this.subtipoId,
    required this.estado,
    required this.fecha,
    required this.nivelUrgencia,
    this.observaciones,
    this.comentario,
    this.tipoId,
    this.subtipoNombre,
    this.estudianteNombre,
    this.estudianteMatricula,
    this.estudianteCorreo,
    this.documentos = const [],
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    final subtipo = (json['subtipo'] is Map) ? (json['subtipo'] as Map) : null;
    final estudiante =
        (json['estudiante'] is Map) ? (json['estudiante'] as Map) : null;

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Solicitud(
      id: parseInt(json['id']) ?? 0,
      estudianteId: parseInt(json['estudiante_id']) ?? 0,
      subtipoId: parseInt(json['subtipo_id']) ?? 0,
      estado: (json['estado_actual'] ?? '').toString(),
      fecha: (json['fecha_solicitud'] ?? json['createdAt'] ?? '').toString(),
      nivelUrgencia: (json['nivel_urgencia'] ?? 'Normal').toString(),
      observaciones: json['observaciones']?.toString(),
      comentario: json['comentario']?.toString(),
      tipoId: parseInt(subtipo?['tipo_id']),
      subtipoNombre: subtipo?['nombre_sub']?.toString(),
      estudianteNombre: estudiante?['nombre_completo']?.toString(),
      estudianteMatricula: estudiante?['matricula']?.toString(),

      // ✅ intenta varias claves comunes
      estudianteCorreo: (estudiante?['correo_institucional'] ??
              estudiante?['correo'] ??
              estudiante?['email'])
          ?.toString(),

      documentos: (json['documentos'] is List)
          ? (json['documentos'] as List)
          : const [],
    );
  }

  // =========================================================
  // ✅ GETTERS COMPATIBLES PARA NO ROMPER PANTALLAS DE ADMIN
  // =========================================================

  /// Admin usa s.estudiante
  String get estudiante => (estudianteNombre?.trim().isNotEmpty ?? false)
      ? estudianteNombre!.trim()
      : 'Estudiante';

  /// ✅ ahora sí muestra algo si viene del backend
  String get correo => (estudianteCorreo?.trim().isNotEmpty ?? false)
      ? estudianteCorreo!.trim()
      : '';

  /// Admin usa s.carrera (tu endpoint no lo manda, devolvemos vacío para no romper UI)
  String get carrera => '';

  /// Admin usa s.descripcion
  String? get descripcion => observaciones;

  /// Admin usa s.subtipo
  String? get subtipo => subtipoNombre;

  /// Admin usa s.tipo (como el backend no manda nombre del tipo, devolvemos “Tipo #id”)
  String get tipo => (tipoId != null) ? 'Tipo #$tipoId' : 'Tipo';

  /// StudentHistorial usa subtipoTitle
  String get subtipoTitle => (subtipoNombre ?? 'Sin subtipo').trim();

  /// Alias por compatibilidad si algún archivo usa otro nombre
  List<dynamic> get documentosCompat => documentos;

  /// copyWith útil para cambios locales (ej: aprobar/rechazar)
  Solicitud copyWith({
    String? estado,
    String? fecha,
    String? nivelUrgencia,
    String? observaciones,
    String? comentario,
    int? tipoId,
    String? subtipoNombre,
    String? estudianteNombre,
    String? estudianteMatricula,
    String? estudianteCorreo,
    List<dynamic>? documentos,
  }) {
    return Solicitud(
      id: id,
      estudianteId: estudianteId,
      subtipoId: subtipoId,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      nivelUrgencia: nivelUrgencia ?? this.nivelUrgencia,
      observaciones: observaciones ?? this.observaciones,
      comentario: comentario ?? this.comentario,
      tipoId: tipoId ?? this.tipoId,
      subtipoNombre: subtipoNombre ?? this.subtipoNombre,
      estudianteNombre: estudianteNombre ?? this.estudianteNombre,
      estudianteMatricula: estudianteMatricula ?? this.estudianteMatricula,
      estudianteCorreo: estudianteCorreo ?? this.estudianteCorreo,
      documentos: documentos ?? this.documentos,
    );
  }
}
