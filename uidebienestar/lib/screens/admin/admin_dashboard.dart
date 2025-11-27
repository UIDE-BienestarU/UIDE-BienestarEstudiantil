import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../main.dart'; 
import '../../services/solicitud_api_service.dart';
import '../../models/solicitud.dart';

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
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 90, color: UIDEColors.conchevino),
          SizedBox(height: 20),
          Text("Noticias", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
          SizedBox(height: 10),
          Text("Próximamente", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Panel Administrativo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.folder_open_outlined), selectedIcon: Icon(Icons.folder_open), label: 'Solicitudes'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Noticias'),
        ],
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que deseas salir?"),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bienvenida
          Card(
            color: UIDEColors.azul,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("¡Hola, Administrador!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Gestiona todas las solicitudes de los estudiantes", style: TextStyle(fontSize: 16, color: Colors.white70)),
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
                    childAspectRatio: 1.25,   // ← MÁS ALTA
                  ),
                  itemCount: 4,
                  itemBuilder: (context, i) {
                    return [
                      _statCard("Pendientes", "$pendientes", Colors.orange),
                      _statCard("Revisión", "$enRevision", Colors.blue),
                      _statCard("Aprobadas", "$aprobadas", Colors.green),
                      _statCard("Rechazadas", "$rechazadas", Colors.red),
                    ][i];
                  },
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error al cargar estadísticas"));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(height: 40),

          const Text("Última solicitud", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    leading: CircleAvatar(backgroundColor: _getColor(ultima.estado), child: Text(ultima.estudiante[0])),
                    title: Text(ultima.estudiante, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${ultima.tipo} • ${ultima.fecha}"),
                    trailing: Chip(
                      label: Text(ultima.estado, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: _getColor(ultima.estado),
                    ),
                  ),
                );
              }
              return const Card(
                child: ListTile(leading: Icon(Icons.info_outline), title: Text("No hay solicitudes aún")),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --------- CARD ESTADÍSTICAS (SIN OVERFLOW) ----------
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
          mainAxisSize: MainAxisSize.min,   // ← SOLUCIÓN DEL OVERFLOW
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
      case "Pendiente": return Colors.orange;
      case "En revisión": return Colors.blue;
      case "Aprobada": return Colors.green;
      case "Rechazada": return Colors.red;
      default: return Colors.grey;
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
    return FutureBuilder<List<Solicitud>>(
      future: futureSolicitudes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final solicitudes = snapshot.data!;
          if (solicitudes.isEmpty) {
            return const Center(child: Text("No hay solicitudes pendientes"));
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
                  leading: CircleAvatar(backgroundColor: _getColor(s.estado), child: Text(s.estudiante[0])),
                  title: Text(s.estudiante, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${s.tipo} • ${s.fecha}"),
                  trailing: Chip(
                    label: Text(s.estado, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: _getColor(s.estado),
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar"));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Color _getColor(String estado) {
    switch (estado) {
      case "Pendiente": return Colors.orange;
      case "En revisión": return Colors.blue;
      case "Aprobada": return Colors.green;
      case "Rechazada": return Colors.red;
      default: return Colors.grey;
    }
  }
}
