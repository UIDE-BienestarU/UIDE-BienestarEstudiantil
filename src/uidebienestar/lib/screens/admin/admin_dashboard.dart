import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';

import 'admin_home_screen.dart';
import 'admin_solicitudes_screen.dart';
import 'admin_avisos.dart';
import 'admin_perfil_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int index = 0;

  final screens = const [
    AdminHomeScreen(),
    AdminSolicitudesScreen(),
    AdminAvisosScreen(),
    AdminPerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Inicio"),
          NavigationDestination(icon: Icon(Icons.folder), label: "Solicitudes"),
          NavigationDestination(icon: Icon(Icons.campaign), label: "Avisos"),
          NavigationDestination(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
