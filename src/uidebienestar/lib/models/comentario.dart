import 'package:uuid/uuid.dart';

class Comentario {
  final String id;
  final String texto;
  final DateTime fecha;

  Comentario({
    String? id,
    required this.texto,
    required this.fecha,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texto': texto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'],
      texto: map['texto'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
