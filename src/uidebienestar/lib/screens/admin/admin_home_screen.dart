import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../services/solicitud_api_service.dart';
import '../../models/solicitud.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienestar Universitario"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Solicitud>>(
        future: SolicitudApiService.getSolicitudes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay solicitudes"));
          }

          final data = snapshot.data!;
          final pendientes =
              data.where((s) => s.estado == "Pendiente").length;
          final revision =
              data.where((s) => s.estado == "En revisión").length;
          final aprobadas =
              data.where((s) => s.estado == "Aprobada").length;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _saludoAdmin(),
                const SizedBox(height: 24),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.2,
                    children: [
                      _stat(
                        "Pendientes",
                        pendientes,
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _stat(
                        "En revisión",
                        revision,
                        Icons.remove_red_eye,
                        Colors.blue,
                      ),
                      _stat(
                        "Aprobadas",
                        aprobadas,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------ WIDGETS ------------------

  Widget _saludoAdmin() {
    return Card(
      color: UIDEColors.azul,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, administrador",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Aquí tienes un resumen general de las solicitudes",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String titulo, int valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.white, size: 32),
          const Spacer(),
          Text(
            "$valor",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
