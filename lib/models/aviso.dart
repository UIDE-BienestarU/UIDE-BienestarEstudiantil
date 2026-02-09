import 'comentario.dart';

enum CategoriaAviso {
  comunicado,
  objetosPerdidos,
}

// Helpers API
String buildFileUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return 'https://api-prod.uidehub.tech$path';
}

class Aviso {
  final String id;
  final String titulo;
  final String contenido;
  final String? imagen; // URL absoluta o null
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
  }) : comentarios = comentarios ?? const [];

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
}

extension AvisoFromApi on Aviso {
  static String _s(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static bool _b(dynamic v, [bool fallback = true]) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'activo') return true;
    if (s == 'false' || s == '0' || s == 'inactivo') return false;
    return fallback;
  }

  /// ✅ Mapper robusto para tu GET: /publicaciones/ver-publicaciones
  /// En móvil: todo lo que venga de publicaciones es "Publicación institucional"
  /// => CategoriaAviso.comunicado
  static Aviso fromPublicacionApi(Map<String, dynamic> json) {
    return Aviso(
      id: _s(json['id']),
      titulo: _s(json['titulo']),
      contenido: _s(json['contenido']),
      imagen: (json['imagen'] == null || _s(json['imagen']).isEmpty)
          ? null
          : buildFileUrl(_s(json['imagen'])),
      // si tu backend tiene 'activo', lo lee; si no, queda true
      activo: _b(json['activo'], true),
      fechaCreacion: DateTime.tryParse(_s(json['createdAt'])) ?? DateTime.now(),
      categoria:
          CategoriaAviso.comunicado, // ✅ publicaciones siempre comunicado
      comentarios: const [],
    );
  }
}
