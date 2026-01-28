import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/uide_colors.dart';
import '../../providers/theme_provider.dart';
import '../../main.dart';
import 'admin_contactos.dart'; //NUEVA 

class AdminPerfilScreen extends StatelessWidget {
  const AdminPerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienestar Universitario"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header del perfil
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: UIDEColors.conchevino.withOpacity(0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 65,
                      backgroundColor: UIDEColors.conchevino,
                      child: Icon(Icons.admin_panel_settings, size: 75, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Column(
                    children: [
                      Text(
                        "Diana Castro Guerrero",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Correo: ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "cadiana@uide.edu.ec",
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
              Icons.dark_mode,
              "Tema",
              onTap: () => context.read<ThemeProvider>().toggleTheme(),
            ),

            // ✅ BOTÓN CONTACTOS → NUEVA PANTALLA
            _perfilItem(
              context,
              Icons.contacts,
              "Contactos de ayuda",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminContactosScreen(),
                ),
              ),
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

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Deseas salir de tu cuenta de administrador?"),
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
