import 'package:flutter/material.dart';

class Solicitud {
  final String id;
  final String estudiante;
  final String correo;
  final String tipo;
  final String? subtipo;
  final String fecha;
  final String estado;
  final String? descripcion;
  final List<String>? documentos;

  Solicitud({
    required this.id,
    required this.estudiante,
    required this.correo,
    required this.tipo,
    this.subtipo,
    required this.fecha,
    required this.estado,
    this.descripcion,
    this.documentos,
  });


  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id'] as String,
      estudiante: json['estudiante'] as String,
      correo: json['correo'] as String,
      tipo: json['tipo'] as String,
      subtipo: json['subtipo'] as String?,
      fecha: json['fecha'] as String,
      estado: json['estado'] as String,
      descripcion: json['descripcion'] as String?,
      documentos: (json['documentos'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudiante': estudiante,
      'correo': correo,
      'tipo': tipo,
      'subtipo': subtipo,
      'fecha': fecha,
      'estado': estado,
      'descripcion': descripcion,
      'documentos': documentos,
    };
  }
}