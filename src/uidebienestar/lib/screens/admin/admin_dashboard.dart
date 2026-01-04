import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/uide_colors.dart';
import '../../main.dart';

import '../../models/solicitud.dart';
import '../../services/solicitud_api_service.dart';

import '../../providers/theme_provider.dart';

import 'admin_detalle_solicitud.dart';
import 'admin_avisos.dart'; // import avisos


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int index = 0;

  late final List<Widget> screens = [
    const AdminHomeScreen(),
    const AdminSolicitudesScreen(),
    const AdminAvisosScreen(), // Agrego para el funcionamiento y redirigir.
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.adminPanel),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        actions: [
          // 🔧 BOTÓN TEMPORAL – CAMBIO DE TEMA
          IconButton(
            tooltip: "Cambiar tema (prueba)",
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            tooltip: loc.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        indicatorColor:
            Theme.of(context).colorScheme.secondaryContainer,
        labelBehavior:
            NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: loc.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_open_outlined),
            selectedIcon: const Icon(Icons.folder_open),
            label: loc.requestsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.campaign_outlined),
            selectedIcon: const Icon(Icons.campaign),
            label: loc.newsTab,
          ),
        ],
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(loc.logoutConfirmTitle),
        content: Text(loc.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              logout(context);
            },
            child:
                Text(loc.exit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


/* ======================================================================
 *  ADMIN 
 * ====================================================================== */

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<List<Solicitud>> futureSolicitudes;

  @override
  void initState() {
    super.initState();
    futureSolicitudes = SolicitudApiService.getSolicitudes();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(
          color: UIDEColors.azul,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.welcomeAdmin,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(loc.manageRequests,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white70)),
                ]),
          ),
        ),
        const SizedBox(height: 32),

        FutureBuilder<List<Solicitud>>(
          future: futureSolicitudes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final solicitudes = snapshot.data!;
              final pendientes =
                  solicitudes.where((s) => s.estado == "Pendiente").length;
              final revision =
                  solicitudes.where((s) => s.estado == "En revisión").length;
              final aprobadas =
                  solicitudes.where((s) => s.estado == "Aprobada").length;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _statCard(loc.pending, pendientes, Colors.orange),
                  _statCard(loc.inReview, revision, Colors.blue),
                  _statCard(loc.approved, aprobadas, Colors.green),
                ],
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text(loc.errorLoadingStats));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ]),
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Card(
      elevation: 6,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("$value",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      ),
    );
  }
}

/* ======================================================================
 *  ADMIN SOLICITUDES
 * ====================================================================== */

class AdminSolicitudesScreen extends StatefulWidget {
  const AdminSolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<AdminSolicitudesScreen> createState() =>
      _AdminSolicitudesScreenState();
}

class _AdminSolicitudesScreenState extends State<AdminSolicitudesScreen> {
  late Future<List<Solicitud>> futureSolicitudes;

  @override
  void initState() {
    super.initState();
    futureSolicitudes = SolicitudApiService.getSolicitudes();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<List<Solicitud>>(
      future: futureSolicitudes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final solicitudes = snapshot.data!;
          if (solicitudes.isEmpty) {
            return Center(child: Text(loc.noPendingRequests));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: solicitudes.length,
            itemBuilder: (_, i) {
              final s = solicitudes[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColor(s.estado),
                    child: Text(s.estudiante[0]),
                  ),
                  title: Text(s.estudiante,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${s.tipo} • ${s.fecha}"),
                  trailing: Chip(
                    backgroundColor: _getColor(s.estado),
                    label: Text(s.estado,
                        style: const TextStyle(color: Colors.white)),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminDetalleSolicitudScreen(solicitud: s),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text(loc.errorLoading));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Color _getColor(String estado) {
    switch (estado) {
      case "Pendiente":
        return Colors.orange;
      case "En revisión":
        return Colors.blue;
      case "Aprobada":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
