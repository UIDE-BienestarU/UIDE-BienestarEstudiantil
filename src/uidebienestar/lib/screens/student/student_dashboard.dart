import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../main.dart';

// Screens
import 'student_home.dart';
import 'student_historial.dart';
import 'student_nueva_solicitud.dart';
import 'student_perfil.dart';

class StudentDashboard extends StatefulWidget {
  final int initialIndex;

  const StudentDashboard({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    StudentHomeScreen(),           // 0
    StudentHistorialScreen(),      // 1
    StudentNuevaSolicitudScreen(), // 2
    StudentPerfilScreen(),         // 3
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Bienestar Universitario"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
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
