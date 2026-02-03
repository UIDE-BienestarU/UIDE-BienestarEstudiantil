import 'package:dio/dio.dart';
import '../models/solicitud.dart'; //IMPORTS

class SolicitudApiService {
  static Future<List<Solicitud>> getSolicitudes() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Solicitud(id: "001", estudiante: "Juan Fuentes", carrera: "Ingenieria en Sistemas", correo: "jufuentespl@uide.edu.ec", tipo: "Becas", fecha: "15 Nov 2025", estado: "Pendiente"),
      Solicitud(id: "002", estudiante: "Mateo Castillo", carrera: "Arquitectura", correo: "macastillomapl@uide.edu.ec", tipo: "Psicológico", fecha: "14 Nov 2025", estado: "En revisión"),
      Solicitud(id: "003", estudiante: "Cristian Salinas", carrera: "Derecho", correo: "crsalinasgr@uide.edu.ec", tipo: "Académico", fecha: "13 Nov 2025", estado: "Pendiente"),
    ];
  }
}