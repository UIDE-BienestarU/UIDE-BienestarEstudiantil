import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/uide_colors.dart';
import '../../main.dart';

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
      const StudentHomeScreen(), // 0
      const StudentHistorialScreen(), // 1
      StudentNuevaSolicitudScreen(
        // 2
        tipoInicial: _tipoDesdeHome,
      ),
      const StudentPerfilScreen(), // 3
    ];
  }

  String _titleForIndex(int i) {
    switch (i) {
      case 0:
        return "Bienestar Universitario";
      case 1:
        return "Mis Solicitudes";
      case 2:
        return "Nueva Solicitud";
      case 3:
        return "Perfil";
      default:
        return "Bienestar Universitario";
    }
  }

  bool get _showAppBar => _selectedIndex != 1; // como lo querías

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: _showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: UIDEColors.conchevino,
              foregroundColor: Colors.white,
              centerTitle: false,
              titleSpacing: 16,
              title: Text(
                _titleForIndex(_selectedIndex),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: "Notificaciones",
                  icon: const Icon(Icons.notifications_none_rounded, size: 22),
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
                  tooltip: "Cerrar sesión",
                  icon: const Icon(Icons.logout_rounded, size: 22),
                  onPressed: () => _confirmarLogout(context),
                ),
                const SizedBox(width: 6),
              ],
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,

        // ✅ evita “saltos” al medir tamaños distintos entre pantallas
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },

        transitionBuilder: (child, animation) {
          final fade =
              CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final slide = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(fade);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },

        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: IndexedStack(
            index: _selectedIndex,
            children: _buildScreens(),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: UIDEColors.conchevino,
        indicatorColor: Colors.white.withOpacity(0.18),
        height: 66,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;

            // ✅ tu lógica original: si sales de "Nueva solicitud", limpia tipoInicial
            if (index != 2) _tipoDesdeHome = null;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 22, color: Colors.white70),
            selectedIcon:
                Icon(Icons.home_rounded, size: 22, color: Colors.white),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined,
                size: 22, color: Colors.white70),
            selectedIcon:
                Icon(Icons.folder_open_rounded, size: 22, color: Colors.white),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded,
                size: 28, color: Colors.white70),
            selectedIcon:
                Icon(Icons.add_circle_rounded, size: 32, color: Colors.white),
            label: 'Nueva',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded,
                size: 22, color: Colors.white70),
            selectedIcon:
                Icon(Icons.person_rounded, size: 22, color: Colors.white),
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
        title: Text(
          "Cerrar sesión",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "¿Deseas salir de tu cuenta?",
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              logout();
            },
            child: Text("Salir", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
