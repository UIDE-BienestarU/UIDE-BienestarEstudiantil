import 'package:flutter/material.dart';
import '../../models/aviso.dart';

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
  CategoriaAviso? categoriaAvisoInicial;

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminHomeScreen(
        onAccesoAvisos: (categoria) {
          setState(() {
            categoriaAvisoInicial = categoria;
            index = 2; // pestaña Avisos
          });
        },
      ),
      const AdminSolicitudesScreen(),
      AdminAvisosScreen(
        categoriaInicial: categoriaAvisoInicial,
      ),
      const AdminPerfilScreen(),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
            if (i != 2) categoriaAvisoInicial = null;
          });
        },
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
