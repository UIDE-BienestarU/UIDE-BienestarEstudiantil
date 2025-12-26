// lib/screens/admin/admin_solicitudes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/uide_colors.dart';
import '../../models/solicitud.dart';
import 'admin_detalle_solicitud.dart';

class AdminSolicitudesScreen extends StatelessWidget {
  const AdminSolicitudesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.cargando) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(onPressed: provider.cargarSolicitudes, child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Solicitudes'), backgroundColor: UIDEColors.conchevino, foregroundColor: Colors.white),
          body: Column(
            children: [
              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: ['Todas', 'Pendiente', 'En revisión', 'Aprobada', 'Rechazada']
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(e),
                              selected: provider.filtro == e,
                              onSelected: (_) => provider.cambiarFiltro(e),
                              selectedColor: UIDEColors.conchevino,
                            ),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.solicitudes.length,
                  itemBuilder: (_, i) {
                    final s = provider.solicitudes[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(s.estudiante[0])),
                      title: Text(s.estudiante),
                      subtitle: Text(s.tipo),
                      trailing: Chip(label: Text(s.estado), backgroundColor: s.colorEstado.withOpacity(0.2)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminDetalleSolicitudScreen(solicitud: s)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}