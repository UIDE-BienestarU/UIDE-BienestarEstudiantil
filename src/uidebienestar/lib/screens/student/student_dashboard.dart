import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../main.dart';

// Screens
import 'student_home.dart';
import 'student_historial.dart';
import 'student_nueva_solicitud.dart';
import 'student_perfil.dart';
import 'student_notificaciones.dart'; // 👈 NUEVO

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

  List<Widget> _buildScreens() {
    return [
      const StudentHomeScreen(), // 0
      const StudentHistorialScreen(), // 1
      StudentNuevaSolicitudScreen( // 2
        tipoInicial: _tipoDesdeHome,
      ),
      const StudentPerfilScreen(), // 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Bienestar Universitario"),
        actions: [
          // 🔔 BOTÓN DE NOTIFICACIONES
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentNotificacionesScreen(),
                ),
              );
            },
          ),

          // 🚪 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
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
                scale: Tween<double>(
                  begin: 0.96,
                  end: 1.0,
                ).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey(_selectedIndex),
          index: _selectedIndex,
          children: _buildScreens(),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;

            // Limpia tipo si no está en Nueva
            if (index != 2) {
              _tipoDesdeHome = null;
            }
          });
        },
        labelBehavior:
            NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, size: 32),
            label: 'Nueva',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // ================= LOGOUT =================

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Cerrar sesión"),
        content:
            const Text("¿Estás seguro de que deseas salir?"),
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
