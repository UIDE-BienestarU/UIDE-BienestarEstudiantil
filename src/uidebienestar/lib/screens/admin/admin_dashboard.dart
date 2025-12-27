import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/uide_colors.dart';
import '../../main.dart';
import '../../services/solicitud_api_service.dart';
import '../../models/solicitud.dart';
import 'admin_detalle_solicitud.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int index = 0;

  final screens = [
    const AdminHomeScreen(),
    const AdminSolicitudesScreen(),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined, size: 90, color: UIDEColors.conchevino),
          const SizedBox(height: 20),
          Text("Noticias", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final loc = AppLocalizations.of(context)!;
              return Text(loc.comingSoon, style: const TextStyle(fontSize: 18, color: Colors.grey));
            },
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: Text(loc.adminPanel),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: loc.logout,
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        backgroundColor: Colors.white,
        indicatorColor: UIDEColors.amarillo.withOpacity(0.3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.logoutConfirmTitle),
        content: Text(loc.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UIDEColors.conchevino),
            onPressed: () {
              Navigator.pop(ctx);
              logout(context);
            },
            child: Text(loc.exit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// ADMIN HOME SCREEN
// ======================================================================

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bienvenida
          Card(
            color: UIDEColors.azul,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.welcomeAdmin, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(loc.manageRequests, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Estadísticas
          FutureBuilder<List<Solicitud>>(
            future: futureSolicitudes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final solicitudes = snapshot.data!;
                final pendientes = solicitudes.where((s) => s.estado == "Pendiente").length;
                final enRevision = solicitudes.where((s) => s.estado == "En revisión").length;
                final aprobadas = solicitudes.where((s) => s.estado == "Aprobada").length;
                final rechazadas = solicitudes.where((s) => s.estado == "Rechazada").length;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, i) {
                    return [
                      _statCard(loc.pending, "$pendientes", Colors.orange),
                      _statCard(loc.inReview, "$enRevision", Colors.blue),
                      _statCard(loc.approved, "$aprobadas", Colors.green),
                      _statCard(loc.rejected, "$rechazadas", Colors.red),
                    ][i];
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(loc.errorLoadingStats));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(height: 40),

          Text(loc.latestRequest, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          FutureBuilder<List<Solicitud>>(
            future: futureSolicitudes,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final ultima = snapshot.data!.first;
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColor(ultima.estado),
                      child: Text(ultima.estudiante[0]),
                    ),
                    title: Text(ultima.estudiante, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${ultima.tipo} • ${ultima.fecha}"),
                    trailing: Chip(
                      label: Text(ultima.estado, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: _getColor(ultima.estado),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminDetalleSolicitudScreen(solicitud: ultima),
                        ),
                      );
                    },
                  ),
                );
              }
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(loc.noRequestsYet),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
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
      case "Rechazada":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ======================================================================
// ADMIN SOLICITUDES SCREEN
// ======================================================================

class AdminSolicitudesScreen extends StatefulWidget {
  const AdminSolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<AdminSolicitudesScreen> createState() => _AdminSolicitudesScreenState();
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
            itemBuilder: (ctx, i) {
              final s = solicitudes[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColor(s.estado),
                    child: Text(s.estudiante[0]),
                  ),
                  title: Text(s.estudiante, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${s.tipo} • ${s.fecha}"),
                  trailing: Chip(
                    label: Text(s.estado, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: _getColor(s.estado),
                  ),
                  onTap: () {
                    // Puedes navegar al detalle aquí si quieres
                  },
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
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
      case "Rechazada":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}