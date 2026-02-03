import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/uide_colors.dart';
import '../../main.dart';

import 'student_historial.dart';
import 'student_nueva_solicitud.dart';
import 'student_perfil.dart';
import 'student_notificaciones.dart';
import 'student_home.dart';

class StudentDashboard extends StatefulWidget {
  final int initialIndex;
  final String? tipoInicial;

  const StudentDashboard({
    Key? key,
    this.initialIndex = 0,
    this.tipoInicial,
  }) : super(key: key);

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

  List<Widget> _buildScreens() => [
        const StudentHomeScreen(),
        const StudentHistorialScreen(),
        StudentNuevaSolicitudScreen(tipoInicial: _tipoDesdeHome),
        const StudentPerfilScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),

      appBar: _selectedIndex == 1
          ? null
          : AppBar(
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentNotificacionesScreen(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 22),
                  onPressed: () => _confirmarLogout(context),
                ),
              ],
            ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: IndexedStack(
          key: ValueKey(_selectedIndex),
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
            if (index != 2) _tipoDesdeHome = null;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 11, color: Colors.white),
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

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Cerrar sesión", style: GoogleFonts.poppins()),
        content: Text("¿Deseas salir?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UIDEColors.conchevino),
            onPressed: () {
              Navigator.pop(ctx);
              logout(context);
            },
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

