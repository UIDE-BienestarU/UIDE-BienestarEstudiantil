import 'package:uuid/uuid.dart';
// mejora
class Comentario {
  final String id;
  final String texto;
  final DateTime fecha;

  // NUEVO
  final String autorNombre;
  final String autorIniciales;

  Comentario({
    String? id,
    required this.texto,
    required this.fecha,
    required this.autorNombre,
    required this.autorIniciales,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texto': texto,
      'fecha': fecha.toIso8601String(),
      'autorNombre': autorNombre,
      'autorIniciales': autorIniciales,
    };
  }

  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'],
      texto: map['texto'],
      fecha: DateTime.parse(map['fecha']),
      autorNombre: map['autorNombre'],
      autorIniciales: map['autorIniciales'],
    );
  }
}
