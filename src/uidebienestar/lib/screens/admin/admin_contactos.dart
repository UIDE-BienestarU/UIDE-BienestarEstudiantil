import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contacto.dart';
import '../../theme/uide_colors.dart';

class AdminContactosScreen extends StatelessWidget {
  const AdminContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Contacto> contactos = [
      Contacto(
        iniciales: "SA",
        color: UIDEColors.conchevino, // color principal para admin
        nombre: "Secretaría Académica",
        cargo: "Administración Académica",
        telefono: "+593 98 888 8888",
        correo: "secretaria@uide.edu.ec",
        ubicacion: "Edificio Administrativo, Planta Baja",
      ),
      Contacto(
        iniciales: "TI",
        color: UIDEColors.azul,
        nombre: "Equipo TI UIDE",
        cargo: "Soporte Técnico y Sistemas",
        telefono: "+593 99 999 9999",
        correo: "ti@uide.edu.ec",
        ubicacion: "Edificio B, Oficina 105",
      ),
      Contacto(
        iniciales: "DF",
        color: UIDEColors.amarillo,
        nombre: "Departamento de Finanzas",
        cargo: "Gestión Financiera y Becas",
        telefono: "+593 97 777 7777",
        correo: "finanzas@uide.edu.ec",
      ),
      // Agrega más contactos aquí si es necesario
    ];

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        title: const Text("Contactos de ayuda"),
        backgroundColor: UIDEColors.conchevino,
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

// Widget reutilizable (puedes moverlo a un archivo aparte como components/contacto_card.dart)
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
                      color: contacto.color, // mismo color que el círculo
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
                      color: contacto.color,
                      onTap: () => _launchTel(contacto.telefono),
                    ),

                  // Correo
                  if (contacto.correo.isNotEmpty)
                    _InfoRow(
                      icon: Icons.email,
                      text: contacto.correo,
                      color: contacto.color,
                      onTap: () => _launchMail(contacto.correo),
                    ),

                  // Ubicación (opcional)
                  if (contacto.ubicacion != null && contacto.ubicacion!.isNotEmpty)
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
    final uri = Uri.parse("tel:${phone.replaceAll(RegExp(r'\s+'), '')}");
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
                style: TextStyle(fontSize: 14, color: UIDEColors.grisTexto),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 18, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}