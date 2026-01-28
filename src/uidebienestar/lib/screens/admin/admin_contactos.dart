import 'package:flutter/material.dart'; //IMPORTS
import 'package:url_launcher/url_launcher.dart';
import '../../models/contacto.dart';
import '../../theme/uide_colors.dart';

class AdminContactosScreen extends StatelessWidget {
  const AdminContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Contacto> contactos = [
      Contacto(
        nombre: "Secretaría Académica",
        cargo: "Administración",
        telefono: "0988888888",
        correo: "secretaria@uide.edu.ec",
      ),
      // CONTACTOS
      Contacto(
        nombre: "Equipo TI UIDE",
        cargo: "Soporte Técnico", 
        telefono: "0999999999",
        correo: "ti@uide.edu.ec",
      ),
      Contacto(
        nombre: "Departamento de Finanzas",
        cargo: "Gestión Financiera",
        telefono: "0988888888",
        correo: "finanzas@uide.edu.ec",
      ),
    ];

    return Scaffold(
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
                color: UIDEColors.conchevino,
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
                    onPressed: () => _llamar(contacto.telefono),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.email,
                    label: "Correo", 
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
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: UIDEColors.conchevino.withOpacity(0.1),
        foregroundColor: UIDEColors.conchevino,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onPressed,
    );
  }
}
