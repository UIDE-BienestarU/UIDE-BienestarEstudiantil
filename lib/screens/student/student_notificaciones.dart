import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../models/notificacion.dart';
import '../student/student_dashboard.dart';

class StudentNotificacionesScreen extends StatefulWidget {
  const StudentNotificacionesScreen({super.key});

  @override
  State<StudentNotificacionesScreen> createState() =>
      _StudentNotificacionesScreenState();
}

class _StudentNotificacionesScreenState
    extends State<StudentNotificacionesScreen> {
  final List<Notificacion> _notificaciones = [
    Notificacion(
      titulo: 'Aviso de objetos perdidos publicado',
      subtitulo: 'Objetos perdidos',
      mensaje: 'Se ha publicado un nuevo aviso sobre objetos perdidos.',
      tiempo: 'Hace 45 min',
      esNueva: true,
      icono: Icons.inventory_2_outlined,
      color: UIDEColors.conchevino,
    ),
    Notificacion(
      titulo: 'Solicitud aprobada con éxito',
      subtitulo: 'Beca de deportes - Aprobada',
      mensaje: 'Tu solicitud de beca de deportes ha sido aprobada.',
      tiempo: 'Hace 2 horas',
      esNueva: false,
      icono: Icons.check_circle_outline,
      color: const Color(0xFF20A201),
    ),
    Notificacion(
      titulo: 'Aviso de objetos perdidos publicado',
      subtitulo: 'Objetos perdidos',
      mensaje:
          'Nuevo aviso publicado sobre objetos perdidos en biblioteca.',
      tiempo: 'Ayer 16:30',
      esNueva: true,
      icono: Icons.laptop_mac_outlined,
      color: UIDEColors.amarillo,
    ),
  ];

  void _marcarTodasComoLeidas() {
    setState(() {
      for (var n in _notificaciones) {
        n.esNueva = false;
      }
    });
  }

  void _mostrarDetalleNotificacion(Notificacion noti) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: noti.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(noti.icono,
                        color: noti.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noti.titulo,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          noti.subtitulo,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                noti.mensaje,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    noti.tiempo,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIDEColors.conchevino,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentDashboard(),
                      ),
                      (_) => false,
                    );
                  },
                  child: const Text(
                    'Volver a Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Marcar todas como leídas',
            onPressed: _marcarTodasComoLeidas,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _notificaciones.length,
        itemBuilder: (_, index) {
          final noti = _notificaciones[index];

          return GestureDetector(
            onTap: () => _mostrarDetalleNotificacion(noti),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: noti.esNueva
                      ? UIDEColors.conchevino
                      : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: noti.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(noti.icono,
                            color: noti.color, size: 24),
                      ),
                      if (noti.esNueva)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: UIDEColors.conchevino,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noti.titulo,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          noti.subtitulo,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 18, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}