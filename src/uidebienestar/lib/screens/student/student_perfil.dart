import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

            const CircleAvatar(
              radius: 60,
              backgroundColor: UIDEColors.azul,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),

            const SizedBox(height: 20),

            const Text(
              "Juan Esteban Fuentes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "jufuentespl@uide.edu.ec",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            _perfilItem(
              context,
              Icons.language,
              "Idioma",
              onTap: () =>
                  context.read<LocaleProvider>().toggleLocale(),
            ),

            _perfilItem(
              context,
              Icons.dark_mode,
              "Tema",
              onTap: () =>
                  context.read<ThemeProvider>().toggleTheme(),
            ),

            _perfilItem(
              context,
              Icons.help_outline,
              "Ayuda",
              onTap: () => _mostrarAyuda(context),
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

  //  POPUP DE AYUDA
  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Contactos de ayuda"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ContactoItem(
                titulo: "BienestarU", telefono: "0912312321"),
            _ContactoItem(
                titulo: "Seguro Médico", telefono: "0912312321"),
            _ContactoItem(
                titulo: "Citas Psicológicas", telefono: "0912312321"),
            _ContactoItem(
                titulo: "Departamento de Finanzas",
                telefono: "0912312321"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  // 🚪 LOGOUT
  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content:
            const Text("¿Deseas salir de tu cuenta?"),
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

// 📱 Widget limpio para contactos
class _ContactoItem extends StatelessWidget {
  final String titulo;
  final String telefono;

  const _ContactoItem({
    required this.titulo,
    required this.telefono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.phone, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$titulo: $telefono",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
