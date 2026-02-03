import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import './student_dashboard.dart'; //IMPORTS

class StudentSolicitudEnviadaScreen extends StatelessWidget {
  const StudentSolicitudEnviadaScreen({Key? key}) : super(key: key);

  void _irADashboard(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(initialIndex: index),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ❌ CERRAR
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _irADashboard(context, 0),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: UIDEColors.conchevino,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "¡Solicitud enviada con éxito!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: UIDEColors.azul,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Tu solicitud ha sido procesada correctamente.\n"
                      "Recibirás una notificación en breve.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),


                    const SizedBox(height: 32),

                    // 👉 IR A MIS SOLICITUDES (Historial = index 1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIDEColors.conchevino,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _irADashboard(context, 1),
                        child: const Text(
                          "Ir a mis solicitudes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 👉 VOLVER AL INICIO (Home = index 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _irADashboard(context, 0),
                        child: const Text("Volver al inicio"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
