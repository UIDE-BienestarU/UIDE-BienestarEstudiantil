class Aviso {
  final String titulo;
  final String contenido;
  final String? imagen;
  final bool activo;
  final DateTime fechaCreacion;

  Aviso({
    required this.titulo,
    required this.contenido,
    this.imagen,
    required this.activo,
    required this.fechaCreacion,
  });

  Aviso copyWith({
    String? titulo,
    String? contenido,
    String? imagen,
    bool? activo,
  }) {
    return Aviso(
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      imagen: imagen ?? this.imagen,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion,
    );
  }
}
