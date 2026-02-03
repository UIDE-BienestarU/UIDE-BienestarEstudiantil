import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ← AGREGADO

import '../../theme/uide_colors.dart';
import './student_dashboard.dart';

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

                    Text(
                      "¡Solicitud enviada con éxito!",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: UIDEColors.azul,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Tu solicitud ha sido procesada correctamente.\n"
                      "Recibirás una notificación en breve.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 👉 IR A MIS SOLICITUDES (Historial = index 1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIDEColors.conchevino,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _irADashboard(context, 1),
                        child: Text(
                          "Ir a mis solicitudes",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 👉 VOLVER AL INICIO (Home = index 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: UIDEColors.conchevino),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _irADashboard(context, 0),
                        child: Text(
                          "Volver al inicio",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: UIDEColors.conchevino,
                          ),
                        ),
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