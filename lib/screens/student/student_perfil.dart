import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // ← AGREGADO

import '../../theme/uide_colors.dart';
import '../../providers/theme_provider.dart';
import '../../main.dart';
import 'student_contactos.dart';

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

                  // Información del estudiante
                  Column(
                    children: [
                      // Nombre
                      Text(
                        "Juan Esteban Fuentes",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Etiqueta + correo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Correo: ",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "jufuentespl@uide.edu.ec",
                              style: GoogleFonts.poppins(
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

            _perfilItem(
              context,
              Icons.contacts,
              "Contactos",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentContactosScreen(),
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
          style: GoogleFonts.poppins(
            fontSize: 16,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Cerrar sesión",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "¿Deseas salir de tu cuenta?",
          style: GoogleFonts.poppins(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancelar",
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              logout(context);
            },
            child: Text(
              "Salir",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}