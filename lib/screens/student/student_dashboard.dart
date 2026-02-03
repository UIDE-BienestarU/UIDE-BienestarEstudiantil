import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/uide_colors.dart';
import '../../main.dart'; // contiene logout(context)

// Screens
import 'student_home.dart';
import 'student_historial.dart';
import 'student_nueva_solicitud.dart';
import 'student_perfil.dart';
import 'student_notificaciones.dart';

class StudentDashboard extends StatefulWidget {
  final int initialIndex;
  final String? tipoInicial;

  const StudentDashboard({
    super.key,
    this.initialIndex = 0,
    this.tipoInicial,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late int _selectedIndex;
  String? _tipoDesdeHome;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tipoDesdeHome = widget.tipoInicial;
  }

  List<Widget> _buildScreens() {
    return [
      const StudentHomeScreen(), // 0 - Inicio
      const StudentHistorialScreen(), // 1 - Historial
      StudentNuevaSolicitudScreen( // 2 - Nueva solicitud
        tipoInicial: _tipoDesdeHome,
      ),
      const StudentPerfilScreen(), // 3 - Perfil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9), // fondo claro general

      // AppBar SIEMPRE visible (eliminada la condición de ocultarlo en Historial)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: Text(
          "Bienestar Universitario",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentNotificacionesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: _buildScreens(),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: UIDEColors.conchevino,
        indicatorColor: Colors.white.withOpacity(0.18),
        height: 64,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            // Limpia tipoInicial si salimos de "Nueva solicitud"
            if (index != 2) {
              _tipoDesdeHome = null;
            }
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 22, color: Colors.white70),
            selectedIcon: Icon(Icons.home, size: 22, color: Colors.white),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined, size: 22, color: Colors.white70),
            selectedIcon: Icon(Icons.folder_open, size: 22, color: Colors.white),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 26, color: Colors.white70),
            selectedIcon: Icon(Icons.add_circle, size: 30, color: Colors.white),
            label: 'Nueva',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 22, color: Colors.white70),
            selectedIcon: Icon(Icons.person, size: 22, color: Colors.white),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // Diálogo de logout con estilo moderno y Google Fonts
  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Cerrar sesión",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "¿Estás seguro de que deseas salir?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancelar",
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              logout(context);
            },
            child: Text(
              "Salir",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}