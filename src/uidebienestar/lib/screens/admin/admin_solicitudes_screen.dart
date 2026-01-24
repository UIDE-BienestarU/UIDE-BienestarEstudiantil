import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/uide_colors.dart';
import '../../models/solicitud.dart';
import 'admin_detalle_solicitud.dart';

class AdminSolicitudesScreen extends StatefulWidget {
  const AdminSolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<AdminSolicitudesScreen> createState() => _AdminSolicitudesScreenState();
}

class _AdminSolicitudesScreenState extends State<AdminSolicitudesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _busqueda = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.cargando) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bienestar Universitario'),
              backgroundColor: UIDEColors.conchevino,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.cargarSolicitudes,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        var solicitudes = provider.solicitudes;
        if (provider.filtro != 'Todas') {
          solicitudes = solicitudes.where((s) => s.estado == provider.filtro).toList();
        }
        if (_busqueda.isNotEmpty) {
          solicitudes = solicitudes.where((s) {
            return s.estudiante.toLowerCase().contains(_busqueda) ||
                s.tipo.toLowerCase().contains(_busqueda);
          }).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Bienestar Universitario'),
            backgroundColor: UIDEColors.conchevino,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar por estudiante o tipo...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final estados = ['Todas', 'Pendiente', 'En revisión', 'Aprobada'];
                    final estado = estados[index];
                    final seleccionado = provider.filtro == estado;
                    return ChoiceChip(
                      label: Text(estado),
                      selected: seleccionado,
                      selectedColor: UIDEColors.conchevino,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: seleccionado
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium!.color,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => provider.cambiarFiltro(estado),
                    );
                  },
                ),
              ),
              Expanded(
                child: solicitudes.isEmpty
                    ? const Center(child: Text("No hay solicitudes", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: solicitudes.length,
                        itemBuilder: (context, index) {
                          final s = solicitudes[index];
                          return _cardSolicitud(s);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardSolicitud(Solicitud s) {
    final Color colorPrincipal = UIDEColors.conchevino;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminDetalleSolicitudScreen(solicitud: s)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colorPrincipal.withOpacity(0.15),
              child: Text(
                s.estudiante[0].toUpperCase(),
                style: TextStyle(color: colorPrincipal, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.tipo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.estudiante,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
                    ),
                  ),
                  // ✅ CORREO AGREGADO
                  const SizedBox(height: 2),
                  Text(
                    s.correo,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Enviada: ${s.fecha}",
                    style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorPrincipal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                s.estado,
                style: TextStyle(
                  color: colorPrincipal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
