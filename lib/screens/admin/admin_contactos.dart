import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contacto.dart';
import '../../theme/uide_colors.dart';

class AdminContactosScreen extends StatelessWidget {
  const AdminContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Contacto> contactos = [
      // ✅ Contacto principal (Proyecto)
      Contacto(
        iniciales: "CS",
        color: UIDEColors.conchevino,
        nombre: "Christian Salinas",
        cargo: "Líder del Proyecto",
        telefono: "+593 99 171 3343",
        correo: "chsalinasra@uide.edu.ec",
        ubicacion: "UIDE",
      ),

      Contacto(
        iniciales: "MC",
        color: UIDEColors.azul,
        nombre: "Mateo Castillo",
        cargo: "Encargado de Backend",
        telefono: "+593 98 686 1663",
        correo: "matcastilloma@uide.edu.ec",
        ubicacion: "UIDE",
      ),
    ];

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        title: const Text("Contactos de ayuda"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _AdminHelpBanner(),
          const SizedBox(height: 12),
          ...contactos.map((c) => ContactoCard(contacto: c)).toList(),
        ],
      ),
    );
  }
}

class _AdminHelpBanner extends StatelessWidget {
  const _AdminHelpBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: UIDEColors.conchevino.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.report_problem_rounded,
                color: UIDEColors.conchevino),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Si el administrador tiene alguna duda o detecta un error en la app, "
              "por favor repórtalo a estos contactos.",
              style: TextStyle(
                fontSize: 13.2,
                color: Colors.grey.shade700,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget reutilizable
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

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contacto.nombre,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: contacto.color,
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
                  if (contacto.telefono.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone,
                      text: contacto.telefono,
                      color: contacto.color,
                      onTap: () => _launchTel(contacto.telefono),
                    ),
                  if (contacto.correo.isNotEmpty)
                    _InfoRow(
                      icon: Icons.email,
                      text: contacto.correo,
                      color: contacto.color,
                      onTap: () => _launchMail(contacto.correo),
                    ),
                  if (contacto.ubicacion != null &&
                      contacto.ubicacion!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.location_on,
                      text: contacto.ubicacion!,
                      color: contacto.color,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchTel(String phone) async {
    final uri = Uri.parse("tel:${phone.replaceAll(RegExp(r'\\s+'), '')}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMail(String email) async {
    final uri = Uri.parse("mailto:$email");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
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
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style:
                    const TextStyle(fontSize: 14, color: UIDEColors.grisTexto),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right,
                  size: 18, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
