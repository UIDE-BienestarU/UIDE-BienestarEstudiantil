// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import 'admin_solicitudes_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Panel Administrativo"),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [UIDEColors.conchevino, UIDEColors.conchevino.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¡Bienvenido, Administrador!",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bienestar Estudiantil UIDE",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Estadísticas rápidas
            const Text("Resumen del día", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard("Pendientes", "12", Icons.pending_actions, Colors.orange),
                _buildStatCard("En revisión", "8", Icons.remove_red_eye, Colors.blue),
                _buildStatCard("Aprobadas", "25", Icons.check_circle, Colors.green),
                _buildStatCard("Rechazadas", "3", Icons.cancel, Colors.red),
              ],
            ),
            const SizedBox(height: 32),

            // Acceso rápido
            const Text("Acciones rápidas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
            const SizedBox(height: 16),
            _buildQuickAction(
              context,
              title: "Ver todas las solicitudes",
              icon: Icons.folder_open,
              color: UIDEColors.amarillo,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSolicitudesScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              context,
              title: "Generar reporte mensual",
              icon: Icons.description,
              color: UIDEColors.azul,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reporte generado"))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}