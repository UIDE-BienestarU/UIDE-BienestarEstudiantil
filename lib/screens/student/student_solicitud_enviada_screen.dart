import 'package:flutter/material.dart';
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ===== Fondo bonito (sin romper modo oscuro) =====
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UIDEColors.conchevino.withOpacity(0.10),
                      UIDEColors.azul.withOpacity(0.08),
                      cs.surface,
                    ],
                  ),
                ),
              ),
            ),

            // “Blobs” decorativos
            Positioned(
              top: -60,
              left: -50,
              child: _blob(
                size: 180,
                color: UIDEColors.conchevino.withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: -70,
              right: -50,
              child: _blob(
                size: 220,
                color: UIDEColors.azul.withOpacity(0.14),
              ),
            ),

            // ===== Cerrar =====
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                tooltip: 'Cerrar',
                icon: Icon(Icons.close_rounded, color: cs.onSurface),
                onPressed: () => _irADashboard(context, 0),
              ),
            ),

            // ===== Contenido =====
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Check animado simple
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 550),
                          curve: Curves.easeOutBack,
                          builder: (_, v, child) {
                            return Transform.scale(
                              scale: v,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: UIDEColors.conchevino,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      UIDEColors.conchevino.withOpacity(0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 54,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          "¡Solicitud enviada con éxito!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: UIDEColors.azul,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Tu solicitud fue enviada correctamente.\n"
                          "Te notificaremos cuando haya novedades.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.35,
                            color: cs.onSurface.withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Tip tipo “pill”
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: UIDEColors.conchevino.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: UIDEColors.conchevino.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded,
                                  size: 18, color: UIDEColors.conchevino),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Revisa Notificaciones para ver respuestas del equipo.",
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.75),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botones
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIDEColors.conchevino,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _irADashboard(context, 1),
                            icon: const Icon(Icons.folder_open_rounded),
                            label: const Text(
                              "Ir a mis solicitudes",
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: UIDEColors.conchevino,
                              side: const BorderSide(
                                  color: UIDEColors.conchevino),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _irADashboard(context, 0),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text(
                              "Volver al inicio",
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
