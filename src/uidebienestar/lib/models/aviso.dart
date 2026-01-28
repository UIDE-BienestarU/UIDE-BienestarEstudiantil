import 'dart:convert';
import 'comentario.dart';
// mejora
enum CategoriaAviso {
  comunicado,
  objetosPerdidos,
}

class Aviso {
  final String id;
  final String titulo;
  final String contenido;
  final String? imagen;
  final bool activo;
  final DateTime fechaCreacion;
  final CategoriaAviso categoria;
  final List<Comentario> comentarios;

  Aviso({
    required this.id,
    required this.titulo,
    required this.contenido,
    this.imagen,
    required this.activo,
    required this.fechaCreacion,
    required this.categoria,
    List<Comentario>? comentarios,
  }) : comentarios = comentarios ?? [];

  Aviso copyWith({
    String? id,
    String? titulo,
    String? contenido,
    String? imagen,
    bool? activo,
    DateTime? fechaCreacion,
    CategoriaAviso? categoria,
    List<Comentario>? comentarios,
  }) {
    return Aviso(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      imagen: imagen ?? this.imagen,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      categoria: categoria ?? this.categoria,
      comentarios: comentarios ?? this.comentarios,
    );
  }

  //  PARA PERSISTENCIA (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'imagen': imagen,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'categoria': categoria.name,
      'comentarios': comentarios.map((c) => c.toMap()).toList(),
    };
  }

  factory Aviso.fromMap(Map<String, dynamic> map) {
    return Aviso(
      id: map['id'],
      titulo: map['titulo'],
      contenido: map['contenido'],
      imagen: map['imagen'],
      activo: map['activo'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      categoria: CategoriaAviso.values.firstWhere(
        (e) => e.name == map['categoria'],
      ),
      comentarios: (map['comentarios'] as List)
          .map((c) => Comentario.fromMap(c))
          .toList(),
    );
  }
}
