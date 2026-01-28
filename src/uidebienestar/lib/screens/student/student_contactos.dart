import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contacto.dart';
import '../../theme/uide_colors.dart';
//IMPORTS
class StudentContactosScreen extends StatelessWidget {
  const StudentContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Contacto> contactos = [
      // CONTACTOS
      Contacto(
        nombre: "BienestarU",
        cargo: "Asistencia General", 
        telefono: "0912312321",
        correo: "bienestar@uide.edu.ec",
      ),
      Contacto(
        nombre: "Seguro Médico",
        cargo: "Atención Médica",
        telefono: "0912312321",
        correo: "seguro@uide.edu.ec",
      ),
      Contacto(
        nombre: "Citas Psicológicas",
        cargo: "Salud Mental",
        telefono: "0912312321", 
        correo: "psicologia@uide.edu.ec",
      ),
      Contacto(
        nombre: "Departamento de Finanzas",
        cargo: "Ayudas Económicas",
        telefono: "0912312321",
        correo: "finanzas@uide.edu.ec",
      ),
    ];

    return Scaffold(
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
          return _ContactoCard(contacto: contactos[index]);
        },
      ),
    );
  }
}

class _ContactoCard extends StatelessWidget {
  final Contacto contacto;

  const _ContactoCard({required this.contacto});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacto.nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: UIDEColors.azul,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contacto.cargo,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.call,
                    label: "Llamar",
                    color: UIDEColors.azul,
                    onPressed: () => _llamar(contacto.telefono),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.email,
                    label: "Correo",
                    color: UIDEColors.azul,
                    onPressed: () => _correo(contacto.correo),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _llamar(String telefono) async {
    final uri = Uri.parse("tel:$telefono");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _correo(String email) async {
    final uri = Uri.parse("mailto:$email");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onPressed,
    );
  }
}
