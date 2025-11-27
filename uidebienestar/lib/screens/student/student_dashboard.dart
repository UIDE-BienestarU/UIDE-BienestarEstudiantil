import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../main.dart'; // para logout

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const MisSolicitudesScreen(),
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
    const NuevaSolicitudScreen(),
    const PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Bienestar Estudiantil"),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}, tooltip: "Notificaciones"),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _confirmarLogout(context), tooltip: "Cerrar sesión"),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: UIDEColors.amarillo.withOpacity(0.3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.folder_open_outlined), selectedIcon: Icon(Icons.folder_open), label: 'Mis solicitudes'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Noticias'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, size: 32), label: 'Nueva'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
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
            onPressed: () { Navigator.pop(ctx); logout(context); },
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
//Pantalla inicio
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> comunicados = const [
  {
    "fuente": "Bienestar UIDE",
    "titulo": "Feria de Becas 2025: ¡Inscríbete antes del 5 de diciembre!",
    "icono": Icons.school_outlined,
    "color": UIDEColors.amarillo,
  },
  {
    "fuente": "Depto. Psicología",
    "titulo": "Nuevos horarios de atención psicológica disponibles desde el lunes",
    "icono": Icons.psychology_outlined,
    "color": Colors.purple,
  },
  {
    "fuente": "Seguros UIDE",
    "titulo": "Seguro médico estudiantil ya activado para el período 2025-1",
    "icono": Icons.local_hospital_outlined,
    "color": Colors.red,
  },
  {
    "fuente": "Registro Académico",
    "titulo": "Solicita tu certificado de estudios en línea desde la app",
    "icono": Icons.description_outlined,
    "color": Colors.teal,
  },
];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: UIDEColors.azul,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("¡Hola, Juan Fuentes!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Aquí puedes gestionar todas tus solicitudes de bienestar", style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Accesos rápidos
          const Text("Accesos rápidos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _quickCard("Solicitar Beca", Icons.school, UIDEColors.amarillo, (c) => _navegarNuevaSolicitud(c, "Beca")),
              _quickCard("Cita Psicológica", Icons.psychology, Colors.purple, (c) => _navegarNuevaSolicitud(c, "Cita Psicológica")),
              _quickCard("Certificado", Icons.description, Colors.teal, (c) => _navegarNuevaSolicitud(c, "Certificado")),
              _quickCard("Seguro Médico", Icons.local_hospital, Colors.red, (c) => _navegarNuevaSolicitud(c, "Seguro Médico")),
            ],
          ),

          const SizedBox(height: 40),

          const Text("Comunicados importantes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comunicados.length,
            separatorBuilder: (context, index) => const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E5)),
           itemBuilder: (context, index) {
              final noticia = comunicados[index];
              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noticia["fuente"],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              noticia["titulo"],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text("8h", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // ← ÍCONO BONITO EN LUGAR DE IMAGEN
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: (noticia["color"] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          noticia["icono"] as IconData,
                          size: 48,
                          color: noticia["color"] as Color,
                        ),
                      ),

                      const SizedBox(width: 12),
                      const Icon(Icons.more_horiz, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static void _navegarNuevaSolicitud(BuildContext context, String tipo) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NuevaSolicitudScreen(tipoInicial: tipo)));
  }

  static Widget _quickCard(String title, IconData icon, Color color, Function(BuildContext) onTap) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => onTap(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

//mis solicitudes
class MisSolicitudesScreen extends StatelessWidget {
  const MisSolicitudesScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> solicitudes = const [
    {"tipo": "Beca Académica", "fecha": "15 Nov 2025", "estado": "Pendiente", "color": Colors.orange},
    {"tipo": "Cita Psicológica", "fecha": "10 Nov 2025", "estado": "Aprobada", "color": Colors.green},
    {"tipo": "Certificado", "fecha": "05 Nov 2025", "estado": "En revisión", "color": Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return solicitudes.isEmpty
        ? const Center(child: Text("Aún no tienes solicitudes"))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: solicitudes.length,
            itemBuilder: (ctx, i) {
              final s = solicitudes[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.description, color: s["color"]),
                  title: Text(s["tipo"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Enviada: ${s["fecha"]}"),
                  trailing: Chip(label: Text(s["estado"], style: const TextStyle(color: Colors.white)), backgroundColor: s["color"]),
                ),
              );
            },
          );
  }
}

// ============================
// NUEVA SOLICITUD
// ============================
class NuevaSolicitudScreen extends StatelessWidget {
  final String? tipoInicial;
  const NuevaSolicitudScreen({Key? key, this.tipoInicial}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Solicitud"), backgroundColor: UIDEColors.conchevino, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tipo de solicitud", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(tipoInicial ?? "General", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const TextField(decoration: InputDecoration(labelText: "Motivo / Descripción", border: OutlineInputBorder(), hintText: "Explica por qué necesitas esta solicitud..."), maxLines: 6),
            const SizedBox(height: 24),
            const Text("Adjuntar documentos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ListTile(leading: const Icon(Icons.cloud_upload, color: UIDEColors.azul), title: const Text("Toca para subir archivos"), trailing: const Icon(Icons.arrow_forward_ios), onTap: null),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Solicitud enviada con éxito!"), backgroundColor: Colors.green));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: UIDEColors.conchevino, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("ENVIAR SOLICITUD", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// PERFIL
// ============================
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil"), backgroundColor: UIDEColors.conchevino, foregroundColor: Colors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, child: Icon(Icons.person, size: 80)),
            SizedBox(height: 20),
            Text("Juan Fuentes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("jufuentespl@uide.edu.ec", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 40),
            Text("Pantalla de perfil y configuración", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}