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

  // ✅ Quité "Aprobada" del chip porque ahora las aprobadas se ocultan (desaparecen)
  static const _estados = <String>[
    'Todas',
    'Por revisar',
    'En progreso',
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() => context.read<AdminProvider>().cargarSolicitudes());

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

  // ✅ helper: parsea fecha para ordenar FIFO (más antiguo primero)
  DateTime _parseFechaSafe(String raw) {
    final r = raw.trim();
    final dt = DateTime.tryParse(r);
    if (dt != null) return dt;

    // Si el parse falla, lo mando al final para no romper el orden FIFO real
    return DateTime.fromMillisecondsSinceEpoch(8640000000000000); // muy futuro
  }

  bool _esAprobada(Solicitud s) {
    return s.estado.trim().toLowerCase() == 'aprobada';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);

        if (provider.cargando) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(
              title: const Text('Solicitudes'),
              backgroundColor: UIDEColors.conchevino,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 42, color: Colors.grey.shade500),
                    const SizedBox(height: 12),
                    Text(
                      provider.error!.replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIDEColors.conchevino,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => provider.cargarSolicitudes(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        var solicitudes = provider.solicitudes;

        // ✅ 1) Las aprobadas desaparecen: se ocultan SIEMPRE
        solicitudes = solicitudes.where((s) => !_esAprobada(s)).toList();

        // ✅ 2) Filtro por estado (seguro)
        if (provider.filtro != 'Todas') {
          solicitudes =
              solicitudes.where((s) => s.estado == provider.filtro).toList();
        }

        // 🔎 búsqueda por estudiante / tipo / subtipo
        if (_busqueda.isNotEmpty) {
          solicitudes = solicitudes.where((s) {
            final est = (s.estudiante).toLowerCase();
            final tipo = (s.tipo).toLowerCase();
            final sub = (s.subtipo ?? '').toLowerCase();
            return est.contains(_busqueda) ||
                tipo.contains(_busqueda) ||
                sub.contains(_busqueda);
          }).toList();
        }

        // ✅ FIFO: primero el más antiguo (fecha ASC)
        solicitudes.sort((a, b) {
          final da = _parseFechaSafe(a.fecha);
          final db = _parseFechaSafe(b.fecha);
          return da.compareTo(db); // ASC = FIFO
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F9),
          appBar: AppBar(
            title: const Text('Solicitudes'),
            backgroundColor: UIDEColors.conchevino,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // ======= Header / Search / Chips =======
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBox(theme),
                    const SizedBox(height: 12),
                    _chipsEstados(provider),
                  ],
                ),
              ),

              // ======= Lista =======
              Expanded(
                child: solicitudes.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () =>
                            context.read<AdminProvider>().cargarSolicitudes(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(18),
                          children: [
                            const SizedBox(height: 80),
                            Icon(Icons.inbox_rounded,
                                size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                "No hay solicitudes",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                "Desliza hacia abajo para actualizar.",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<AdminProvider>().cargarSolicitudes(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                          itemCount: solicitudes.length,
                          itemBuilder: (context, index) {
                            final s = solicitudes[index];
                            return _cardSolicitud(context, s);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== UI Pieces =====================

  Widget _searchBox(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Buscar por estudiante, tipo o subtipo…",
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _busqueda.isEmpty
              ? null
              : IconButton(
                  tooltip: "Limpiar",
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _chipsEstados(AdminProvider provider) {
    // ✅ si el provider tenía "Aprobada" guardada, lo regreso a "Todas"
    if (!_estados.contains(provider.filtro)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        provider.cambiarFiltro('Todas');
      });
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _estados.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final estado = _estados[i];
          final selected = provider.filtro == estado;

          return ChoiceChip(
            label: Text(estado),
            selected: selected,
            showCheckmark: false,
            selectedColor: UIDEColors.conchevino,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => provider.cambiarFiltro(estado),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: selected
                    ? Colors.transparent
                    : UIDEColors.conchevino.withOpacity(0.25),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================== Card =====================

  Widget _cardSolicitud(BuildContext context, Solicitud s) {
    final theme = Theme.of(context);

    final estado = (s.estado).trim();
    final badge = _estadoBadge(estado);
    final nombre = (s.estudiante).trim().isEmpty ? "Estudiante" : s.estudiante;
    final inicial = _inicial(nombre);

    final tipo = (s.tipo).trim().isEmpty ? "Tipo" : s.tipo;
    final subtipo = (s.subtipo ?? '').trim();
    final titulo = subtipo.isNotEmpty ? "$tipo • $subtipo" : tipo;

    final fechaUi = _prettyFecha(s.fecha);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDetalleSolicitudScreen(solicitud: s),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: badge.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                inicial,
                style: TextStyle(
                  color: badge.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _badgeChip(badge.label, badge.color),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Enviada: $fechaUi",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.8,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _badgeChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ===================== Helpers =====================

  String _inicial(String nombre) {
    final clean = nombre.trim();
    if (clean.isEmpty) return "?";
    final parts =
        clean.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  String _prettyFecha(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return "Fecha no disponible";
    final dt = DateTime.tryParse(r);
    if (dt == null) return r;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$d/$m/$y";
  }

  _Badge _estadoBadge(String estado) {
    final e = estado.toLowerCase().trim();
    if (e == 'por revisar') return _Badge('PENDIENTE', UIDEColors.amarillo);
    if (e == 'en progreso') return _Badge('EN PROCESO', UIDEColors.azul);
    if (e == 'aprobada') return _Badge('APROBADA', Colors.green.shade700);
    return _Badge(estado.toUpperCase(), UIDEColors.conchevino);
  }
}

class _Badge {
  final String label;
  final Color color;
  _Badge(this.label, this.color);
}
