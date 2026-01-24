import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/uide_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../main.dart';

class StudentPerfilScreen extends StatelessWidget {
  const StudentPerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Contenedor elegante para el header del perfil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar con sombra suave
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: UIDEColors.azul.withOpacity(0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 65,
                      backgroundColor: UIDEColors.azul,
                      child: Icon(Icons.person, size: 75, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Información del estudiante - más equilibrada y estética
                  Column(
                    children: [
                      // Nombre
                      Text(
                        "Juan Esteban Fuentes",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Etiqueta + correo (en una sola línea, sin cortes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Correo:  ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "jufuentespl@uide.edu.ec",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _perfilItem(
              context,
              Icons.language,
              "Idioma",
              onTap: () => context.read<LocaleProvider>().toggleLocale(),
            ),

            _perfilItem(
              context,
              Icons.dark_mode,
              "Tema",
              onTap: () => context.read<ThemeProvider>().toggleTheme(),
            ),

            _perfilItem(
              context,
              Icons.contacts,
              "Contactos",
              onTap: () => _mostrarContactos(context),
            ),

            _perfilItem(
              context,
              Icons.logout,
              "Cerrar sesión",
              isDanger: true,
              onTap: () => _confirmarLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _perfilItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDanger ? Colors.red : UIDEColors.conchevino,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDanger ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _mostrarContactos(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        title: const Center(
          child: Text(
            "Contactos de Ayuda",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _ContactoItem(titulo: "BienestarU", telefono: "0912312321"),
              _ContactoDivider(),
              _ContactoItem(titulo: "Seguro Médico", telefono: "0912312321"),
              _ContactoDivider(),
              _ContactoItem(titulo: "Citas Psicológicas", telefono: "0912312321"),
              _ContactoDivider(),
              _ContactoItem(titulo: "Departamento de Finanzas", telefono: "0912312321"),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Deseas salir de tu cuenta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              logout(context);
            },
            child: const Text(
              "Salir",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactoItem extends StatelessWidget {
  final String titulo;
  final String telefono;

  const _ContactoItem({
    required this.titulo,
    required this.telefono,
  });

  Future<void> _llamar(BuildContext context) async {
    final cleanPhone = telefono.replaceAll(RegExp(r'[\s\-()]+'), '');
    final Uri url = Uri(scheme: 'tel', path: cleanPhone);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo llamar a $telefono')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al intentar llamar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = UIDEColors.azul;

    final primaryLight = isDark
        ? primaryColor.withOpacity(0.25)
        : primaryColor.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  telefono,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: primaryLight,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(
                Icons.phone_rounded,
                color: primaryColor,
                size: 26,
              ),
              tooltip: 'Llamar a $telefono',
              onPressed: () => _llamar(context),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
              splashRadius: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactoDivider extends StatelessWidget {
  const _ContactoDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).dividerColor.withOpacity(0.3),
      ),
    );
  }
}