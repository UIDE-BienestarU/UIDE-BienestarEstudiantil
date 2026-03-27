import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contacto.dart';
import '../../theme/uide_colors.dart';

class StudentContactosScreen extends StatelessWidget {
  const StudentContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Contacto> contactos = [
      // ✅ Principal (Bienestar) primero
      Contacto(
        iniciales: "DC",
        color: UIDEColors.conchevino,
        nombre: "Diana Castro Guerrero",
        cargo: "Bienestar Universitario",
        telefono: "+593 99 676 3210",
        correo: "dcastro@uide.edu.ec",
        ubicacion: "UIDE",
        horario: "Lunes a Viernes • 08:00 - 17:00",
      ),

      Contacto(
        iniciales: "DO",
        color: UIDEColors.azul,
        nombre: "Daniela Ordoñez",
        cargo: "Asesora Estudiantil",
        telefono: "+593 99 988 6854",
        correo: "",
      ),

      Contacto(
        iniciales: "HC",
        color: UIDEColors.amarillo,
        nombre: "Henri Cueva",
        cargo: "Soporte TI",
        telefono: "093 994 3822",
        correo: "hcueva@uide.edu.ec",
      ),

      Contacto(
        iniciales: "RR",
        color: Colors.deepPurple,
        nombre: "Rodrigo Ríos",
        cargo: "Psicólogo",
        telefono: "+593 98 421 4149",
        correo: "roriosco@uide.edu.ec",
      ),

      Contacto(
        iniciales: "PM",
        color: Colors.green.shade700,
        nombre: "Paulina Muñoz",
        cargo: "Finanzas",
        telefono: "+593 98 296 4661",
        correo: "",
      ),
    ];

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        title: const Text("Contactos"),
        backgroundColor: UIDEColors.azul,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeaderInfo(),
          const SizedBox(height: 14),

          // ✅ Diana destacada
          ContactoCard(
            contacto: contactos.first,
            destacado: true,
            badgeText: "Principal",
          ),

          const SizedBox(height: 10),

          // resto
          ...contactos.skip(1).map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ContactoCard(
                    contacto: c,
                    destacado: false,
                    badgeText: c.cargo.toLowerCase().contains("soporte")
                        ? "TI"
                        : (c.cargo.toLowerCase().contains("psic")
                            ? "Apoyo"
                            : (c.cargo.toLowerCase().contains("finan")
                                ? "Finanzas"
                                : null)),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
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
            child:
                const Icon(Icons.support_agent, color: UIDEColors.conchevino),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contactos de apoyo",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: UIDEColors.conchevino,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Toca un número para llamar o un correo para escribir.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactoCard extends StatelessWidget {
  final Contacto contacto;
  final bool destacado;
  final String? badgeText;

  const ContactoCard({
    super.key,
    required this.contacto,
    this.destacado = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = destacado
        ? UIDEColors.conchevino.withOpacity(0.35)
        : Colors.black.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(destacado ? 0.07 : 0.04),
            blurRadius: destacado ? 14 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarIniciales(
            iniciales: contacto.iniciales,
            color: contacto.color,
            grande: destacado,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contacto.nombre,
                        style: TextStyle(
                          fontSize: destacado ? 17.5 : 16.5,
                          fontWeight: FontWeight.w800,
                          color: UIDEColors.azul,
                        ),
                      ),
                    ),
                    if (badgeText != null)
                      _Badge(text: badgeText!, color: UIDEColors.conchevino),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  contacto.cargo,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if ((contacto.ubicacion ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.location_on,
                    text: contacto.ubicacion!.trim(),
                  ),
                ],

                if ((contacto.horario ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.schedule,
                    text: contacto.horario!.trim(),
                  ),
                ],

                const SizedBox(height: 12),

                // Acciones rápidas (chips)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (contacto.telefono.trim().isNotEmpty)
                      _ActionChip(
                        icon: Icons.phone,
                        label: "Llamar",
                        onTap: () => _launchTel(contacto.telefono),
                      ),
                    if (contacto.correo.trim().isNotEmpty)
                      _ActionChip(
                        icon: Icons.email,
                        label: "Email",
                        onTap: () => _launchMail(contacto.correo),
                      ),
                    if (contacto.telefono.trim().isNotEmpty)
                      _MiniChip(
                        icon: Icons.call,
                        text: contacto.telefono,
                      ),
                    if (contacto.correo.trim().isNotEmpty)
                      _MiniChip(
                        icon: Icons.alternate_email,
                        text: contacto.correo,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchTel(String phone) async {
    final clean = phone.replaceAll(' ', '');
    final uri = Uri.parse("tel:$clean");
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

class _AvatarIniciales extends StatelessWidget {
  final String iniciales;
  final Color color;
  final bool grande;

  const _AvatarIniciales({
    required this.iniciales,
    required this.color,
    required this.grande,
  });

  @override
  Widget build(BuildContext context) {
    final size = grande ? 64.0 : 56.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        iniciales,
        style: TextStyle(
          color: Colors.white,
          fontSize: grande ? 22 : 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: UIDEColors.conchevino,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: UIDEColors.azul),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: UIDEColors.azul),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade800,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
