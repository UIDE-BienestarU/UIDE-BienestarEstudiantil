import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contacto.dart';
import '../../theme/uide_colors.dart';

class StudentContactosScreen extends StatelessWidget {
  const StudentContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Puedes mover esta lista a un provider o archivo aparte más adelante
    final List<Contacto> contactos = [
      Contacto(
        iniciales: "CR",
        color: const Color(0xFF8B1538), // conchevino
        nombre: "Carlos Rodríguez Pérez",
        cargo: "Psicólogo\nBienestar Universitario",
        telefono: "+57 300 234 5678",
        correo: "carlos.rodriguez@universidad.edu.ec",
      ),
      Contacto(
        iniciales: "MG",
        color: const Color(0xFF003B7A), // azul
        nombre: "María García López",
        cargo: "Coordinadora de Bienestar\nBienestar Universitario",
        telefono: "+593 99 123 4567",
        correo: "maria.garcia@uide.edu.ec",
      ),
      Contacto(
        iniciales: "AM",
        color: const Color(0xFFFDB913), // amarillo
        nombre: "Ana Martínez Silva",
        cargo: "Asesora Académica\nAsesoría Estudiantil",
        telefono: "+593 98 765 4321",
        correo: "ana.martinez@uide.edu.ec",
      ),
      // ... agrega los demás siguiendo el mismo patrón
    ];

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        title: const Text("Contactos"),
        backgroundColor: UIDEColors.azul,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contactos.length,
        itemBuilder: (context, index) {
          return ContactoCard(contacto: contactos[index]);
        },
      ),
    );
  }
}

class ContactoCard extends StatelessWidget {
  final Contacto contacto;

  const ContactoCard({super.key, required this.contacto});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Círculo con iniciales
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: contacto.color,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                contacto.iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Contenido principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contacto.nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: UIDEColors.azul,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contacto.cargo,
                    style: TextStyle(
                      fontSize: 14,
                      color: UIDEColors.grisTexto,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Teléfono
                  if (contacto.telefono.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone,
                      text: contacto.telefono,
                      onTap: () => _launchTel(contacto.telefono),
                    ),

                  // Correo
                  if (contacto.correo.isNotEmpty)
                    _InfoRow(
                      icon: Icons.email,
                      text: contacto.correo,
                      onTap: () => _launchMail(contacto.correo),
                    ),

                  // Ubicación
                  if (contacto.ubicacion != null && contacto.ubicacion!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.location_on,
                      text: contacto.ubicacion!,
                      // Podrías abrir maps si quieres
                    ),

                  // Horario (solo si existe)
                  if (contacto.horario != null && contacto.horario!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Horario de atención",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: UIDEColors.grisTexto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contacto.horario!,
                      style: TextStyle(
                        fontSize: 13,
                        color: UIDEColors.grisTexto,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchTel(String phone) async {
    final uri = Uri.parse("tel:${phone.replaceAll(' ', '')}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMail(String email) async {
    final uri = Uri.parse("mailto:$email");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: UIDEColors.azul),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: UIDEColors.grisTexto),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}