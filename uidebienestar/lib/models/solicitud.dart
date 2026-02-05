import 'package:flutter/material.dart';

class Solicitud {
  final String id;
  final String estudiante;
  final String tipo;
  final String fecha;
  final String estado;

  Solicitud({
    required this.id,
    required this.estudiante,
    required this.tipo,
    required this.fecha,
    required this.estado,
  });

  Color get colorEstado {
    switch (estado) {
      case 'Pendiente': return Colors.orange;
      case 'En revisión': return Colors.blue;
      case 'Aprobada': return Colors.green;
      case 'Rechazada': return Colors.red;
      default: return Colors.grey;
    }
  }

  factory Solicitud.fromJson(Map<String, dynamic> json) => Solicitud(
        id: json['id'],
        estudiante: json['estudiante'],
        tipo: json['tipo'],
        fecha: json['fecha'],
        estado: json['estado'],
      );
}