class ObjetoPerdido {
  final int id;
  final String titulo;
  final String descripcion;
  final String? imagen;
  final String? lugarEncontrado;
  final String estado;
  final String createdAt;

  ObjetoPerdido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.lugarEncontrado,
    required this.estado,
    required this.createdAt,
  });

  factory ObjetoPerdido.fromJson(Map<String, dynamic> json) {
    final created = (json['createdAt'] ??
            json['created_at'] ??
            json['fecha'] ??
            json['created'] ??
            '')
        .toString();

    return ObjetoPerdido(
      id: int.tryParse('${json['id']}') ?? 0,
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      imagen: (json['imagen'] ?? json['foto'] ?? json['url_foto'])?.toString(),
      lugarEncontrado:
          (json['lugar_encontrado'] ?? json['lugarEncontrado'])?.toString(),
      estado: (json['estado'] ?? '').toString(),
      createdAt: created,
    );
  }

  ObjetoPerdido copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? imagen,
    String? lugarEncontrado,
    String? estado,
    String? createdAt,
  }) {
    return ObjetoPerdido(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagen: imagen ?? this.imagen,
      lugarEncontrado: lugarEncontrado ?? this.lugarEncontrado,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
