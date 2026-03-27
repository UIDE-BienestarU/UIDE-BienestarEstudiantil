class SubtipoSolicitud {
  final int id;
  final int tipoId;
  final String nombre;

  SubtipoSolicitud(
      {required this.id, required this.tipoId, required this.nombre});

  factory SubtipoSolicitud.fromJson(Map<String, dynamic> json) {
    return SubtipoSolicitud(
      id: (json['id'] as num).toInt(),
      tipoId: (json['tipo_id'] as num).toInt(),
      nombre: (json['nombre_sub'] ?? json['nombre'] ?? '').toString(),
    );
  }
}
