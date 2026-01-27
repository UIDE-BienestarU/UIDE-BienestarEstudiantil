import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';

class StudentNotificacionesScreen extends StatelessWidget {
  const StudentNotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Notificaciones"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: UIDEColors.conchevino.withOpacity(0.15),
                  child: Icon(
                    Icons.notifications,
                    color: UIDEColors.conchevino,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tu solicitud fue revisada",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bienestar Universitario revisó tu solicitud. Revisa el estado.",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Hace 2 horas",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
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
}
