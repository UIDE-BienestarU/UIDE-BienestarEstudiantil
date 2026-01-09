import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';

class StudentPerfilScreen extends StatelessWidget {
  const StudentPerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            const CircleAvatar(
              radius: 60,
              backgroundColor: UIDEColors.azul,
              child: Icon(
                Icons.person,
                size: 70,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Juan Esteban Fuentes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "jufuentespl@uide.edu.ec",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            _perfilItem(Icons.settings, "Configuración"),
            _perfilItem(Icons.language, "Idioma"),
            _perfilItem(Icons.dark_mode, "Tema"),
            _perfilItem(Icons.help_outline, "Ayuda"),
            _perfilItem(Icons.logout, "Cerrar sesión", isDanger: true),
          ],
        ),
      ),
    );
  }

  Widget _perfilItem(IconData icon, String label, {bool isDanger = false}) {
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
            color: isDanger ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Acción futura
        },
      ),
    );
  }
}
