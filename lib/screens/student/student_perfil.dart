import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/uide_colors.dart';
import '../../providers/session_provider.dart';
import '../../services/perfil_service.dart';
import '../../services/auth_service.dart';
import '../../services/sugerencias_service.dart';
import '../../services/push_service.dart';
import '../../main.dart';
import 'student_contactos.dart';

class StudentPerfilScreen extends StatefulWidget {
  const StudentPerfilScreen({Key? key}) : super(key: key);

  @override
  State<StudentPerfilScreen> createState() => _StudentPerfilScreenState();
}

class _StudentPerfilScreenState extends State<StudentPerfilScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = PerfilService.getPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // fallback sesión si falla API
          if (snap.hasError) {
            final session = context.watch<SessionProvider>();
            final nombreFallback = session.nombreCompleto ?? 'Estudiante';
            final correoFallback = session.correo ?? '';

            return _buildPerfilUI(
              context,
              nombre: nombreFallback,
              correo: correoFallback,
              error: snap.error.toString(),
            );
          }

          final data = snap.data ?? {};
          final nombre = (data['nombre_completo'] ?? '').toString();
          final correo = (data['correo_institucional'] ?? '').toString();

          // refresca sesión con datos frescos
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<SessionProvider>().setUser(data);
          });

          return _buildPerfilUI(
            context,
            nombre: nombre.isNotEmpty ? nombre : 'Estudiante',
            correo: correo,
          );
        },
      ),
    );
  }

  Widget _buildPerfilUI(
    BuildContext context, {
    required String nombre,
    required String correo,
    String? error,
  }) {
    final initials = _initials(nombre);

    return CustomScrollView(
      slivers: [
        // ✅ FIX: SliverAppBar sin título para que no se duplique "perfil"
        SliverAppBar(
          backgroundColor: UIDEColors.conchevino,
          foregroundColor: Colors.white,
          pinned: true,
          centerTitle: false,
          title: const SizedBox.shrink(), // <-- elimina el texto "Mi perfil"
          actions: [
            IconButton(
              tooltip: "Refrescar",
              onPressed: () =>
                  setState(() => _future = PerfilService.getPerfil()),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                if (error != null) ...[
                  _errorBanner(error),
                  const SizedBox(height: 12),
                ],
                _profileHeader(
                  nombre: nombre,
                  correo: correo,
                  initials: initials,
                ),
                const SizedBox(height: 16),
                _sectionTitle("Acciones"),
                const SizedBox(height: 10),
                _actionCard(
                  icon: Icons.edit_note_rounded,
                  title: "Sugerencias anónimas",
                  subtitle: "Envía ideas o mejoras para Bienestar",
                  color: UIDEColors.azul,
                  onTap: () => _abrirSugerenciaAnonima(context),
                ),
                _actionCard(
                  icon: Icons.contacts_rounded,
                  title: "Contactos",
                  subtitle: "Teléfonos y canales de apoyo",
                  color: UIDEColors.conchevino,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentContactosScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _sectionTitle("Cuenta"),
                const SizedBox(height: 10),
                _dangerCard(
                  icon: Icons.logout_rounded,
                  title: "Cerrar sesión",
                  subtitle: "Salir de la cuenta en este dispositivo",
                  onTap: () => _confirmarLogout(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileHeader({
    required String nombre,
    required String correo,
    required String initials,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            UIDEColors.azul.withOpacity(0.95),
            UIDEColors.azul.withOpacity(0.70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.28)),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.mail_outline,
                          size: 16, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          correo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: UIDEColors.conchevino,
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _dangerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              // ✅ FIX: antes estaba hardcodeado a logout
              child: Icon(icon, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.8,
                      color: Colors.red.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(String err) {
    final msg = err.replaceFirst('Exception: ', '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.poppins(fontSize: 13.2),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String nombre) {
    final parts =
        nombre.trim().split(RegExp(r'\s+')).where((x) => x.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    final a = parts.first[0].toUpperCase();
    final b = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    return '$a$b';
  }

  // =======================
  // Sugerencia anónima
  // =======================
  void _abrirSugerenciaAnonima(BuildContext context) {
    final controller = TextEditingController();
    bool sending = false;

    showDialog(
      context: context,
      barrierDismissible: !sending,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text(
                "Sugerencia anónima",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Escribe tu sugerencia. No se mostrará tu nombre.",
                    style: GoogleFonts.poppins(
                        fontSize: 13.2, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Ej: Mejorar horario, más eventos, etc.",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: UIDEColors.conchevino),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: sending ? null : () => Navigator.pop(ctx),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: UIDEColors.conchevino),
                  onPressed: sending
                      ? null
                      : () async {
                          final text = controller.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Escribe una sugerencia primero"),
                              ),
                            );
                            return;
                          }

                          setLocal(() => sending = true);
                          try {
                            await SugerenciasService.enviarSugerencia(
                                mensaje: text);

                            if (!context.mounted) return;
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Sugerencia enviada ✅")),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          } finally {
                            setLocal(() => sending = false);
                          }
                        },
                  child: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Enviar",
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =======================
  // LOGOUT (con unregister)
  // =======================
  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Cerrar sesión",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content:
            Text("¿Deseas salir de tu cuenta?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: UIDEColors.conchevino),
            onPressed: () async {
              Navigator.pop(ctx);

              // 1) Desregistrar token
              try {
                await PushService.unregister();
              } catch (_) {}

              // 2) Limpiar sesión + logout backend
              context.read<SessionProvider>().clear();
              try {
                await AuthService.logout();
              } catch (_) {}

              // 3) Navegar a login (global)
              logout();
            },
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
