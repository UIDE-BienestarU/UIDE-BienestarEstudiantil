class TipoSolicitud {
  final int id;
  final String nombre;

  TipoSolicitud({required this.id, required this.nombre});

  factory TipoSolicitud.fromJson(Map<String, dynamic> json) {
    return TipoSolicitud(
      id: (json['id'] as num).toInt(),
      nombre: (json['nombre'] ?? json['nombre_tipo'] ?? '').toString(),
    );
  }
}
