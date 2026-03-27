import 'package:flutter/material.dart';
class Contacto {
  final String iniciales;
  final Color color;               
  final String nombre;
  final String cargo;
  final String telefono;
  final String correo;
  final String? ubicacion;
  final String? horario;

  Contacto({
    required this.iniciales,
    required this.color,
    required this.nombre,
    required this.cargo,
    required this.telefono,
    required this.correo,
    this.ubicacion,
    this.horario,
  });
}