import 'package:flutter/material.dart';

class Notificacion {
  final String titulo;
  final String subtitulo;
  final String mensaje;
  final String tiempo;
  bool esNueva;
  final IconData icono;
  final Color color;

  Notificacion({
    required this.titulo,
    required this.subtitulo,
    required this.mensaje,
    required this.tiempo,
    required this.esNueva,
    required this.icono,
    required this.color,
  });
}