import 'package:dio/dio.dart';
import '../models/solicitud.dart';

class SolicitudApiService {
  static Future<List<Solicitud>> getSolicitudes() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Solicitud(id: "001", estudiante: "Juan Fuentes", tipo: "Beca Académica", fecha: "15 Nov 2025", estado: "Pendiente"),
      Solicitud(id: "002", estudiante: "María Castro", tipo: "Cita Psicológica", fecha: "14 Nov 2025", estado: "En revisión"),
      Solicitud(id: "003", estudiante: "Mateo Castillo", tipo: "Certificado", fecha: "13 Nov 2025", estado: "Pendiente"),
      Solicitud(id: "004", estudiante: "Virginia Mora", tipo: "Seguro Médico", fecha: "12 Nov 2025", estado: "Aprobada"),
      Solicitud(id: "005", estudiante: "Christian Salinas", tipo: "Beca Deporte", fecha: "10 Nov 2025", estado: "Rechazada"),
    ];
  }
}