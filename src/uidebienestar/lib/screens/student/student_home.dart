import 'package:flutter/material.dart';

import '../../theme/uide_colors.dart';
import 'student_nueva_solicitud.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> comunicados = const [
    {
      "fuente": "Bienestar UIDE",
      "titulo": "Feria de Becas 2025: ¡Inscríbete antes del 5 de diciembre!",
      "icono": Icons.school_outlined,
      "color": UIDEColors.amarillo,
    },
    {
      "fuente": "Depto. Psicología",
      "titulo": "Nuevos horarios de atención psicológica disponibles desde el lunes",
      "icono": Icons.psychology_outlined,
      "color": Colors.purple,
    },
    {
      "fuente": "Seguros UIDE",
      "titulo": "Seguro médico estudiantil ya activado para el período 2025-1",
      "icono": Icons.local_hospital_outlined,
      "color": Colors.red,
    },
    {
      "fuente": "Registro Académico",
      "titulo": "Solicita tu certificado de estudios en línea desde la app",
      "icono": Icons.description_outlined,
      "color": Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: UIDEColors.azul,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¡Hola, Juan Fuentes!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Aquí puedes gestionar todas tus solicitudes de bienestar",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "Accesos rápidos",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: UIDEColors.conchevino,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _quickCard(
                context,
                "Solicitar Beca",
                Icons.school,
                UIDEColors.amarillo,
                "Beca",
              ),
              _quickCard(
                context,
                "Cita Psicológica",
                Icons.psychology,
                Colors.purple,
                "Cita Psicológica",
              ),
              _quickCard(
                context,
                "Certificado",
                Icons.description,
                Colors.teal,
                "Certificado",
              ),
              _quickCard(
                context,
                "Seguro Médico",
                Icons.local_hospital,
                Colors.red,
                "Seguro Médico",
              ),
            ],
          ),

          const SizedBox(height: 40),

          const Text(
            "Comunicados importantes",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: UIDEColors.conchevino,
            ),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comunicados.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 32, thickness: 0.5),
            itemBuilder: (context, index) {
              final noticia = comunicados[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noticia["fuente"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          noticia["titulo"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "8h",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          (noticia["color"] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      noticia["icono"],
                      size: 40,
                      color: noticia["color"],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _quickCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String tipoSolicitud,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                StudentNuevaSolicitudScreen(tipoInicial: tipoSolicitud),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
