import 'package:dio/dio.dart';
import '../models/solicitud.dart'; //IMPORTS

class SolicitudApiService {
  static Future<List<Solicitud>> getSolicitudes() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Solicitud(id: "001", estudiante: "Juan Fuentes", correo: "jufuentespl@uide.edu.ec", tipo: "Becas", fecha: "15 Nov 2025", estado: "Pendiente"),
      Solicitud(id: "002", estudiante: "María Castro", correo: "macastro@uide.edu.ec", tipo: "Psicológico", fecha: "14 Nov 2025", estado: "En revisión"),
      Solicitud(id: "003", estudiante: "Mateo Castillo", correo: "macastillomapl@uide.edu.ec", tipo: "Académico", fecha: "13 Nov 2025", estado: "Pendiente"),
      Solicitud(id: "004", estudiante: "Virginia Mora", correo: "vimoragu@uide.edu.ec", tipo: "Deportes", fecha: "12 Nov 2025", estado: "Aprobada"),
    ];
  }
}