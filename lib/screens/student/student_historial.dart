import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/uide_colors.dart';
import 'student_nueva_solicitud.dart';

import '../../services/api_client.dart';
import '../../models/solicitud.dart';
import '../../providers/solicitud_provider.dart';

class StudentHistorialScreen extends StatefulWidget {
  const StudentHistorialScreen({super.key});

  @override
  State<StudentHistorialScreen> createState() => _StudentHistorialScreenState();
}

class _StudentHistorialScreenState extends State<StudentHistorialScreen> {
  // ✅ Mejor por estabilidad: expand por ID (no por index)
  int? _solicitudExpandidaId;

  // UI chips
  String _estadoSeleccionado = 'Todas';

  // ✅ Tipos desde BD
  Map<int, String> _tipoNombreById = {};
  bool _tiposLoading = false;

  // ✅ Para mostrar spinner solo en el footer cuando “cargar más”
  bool _loadingMoreLocal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadTipos();
      if (!mounted) return;
      await context.read<SolicitudProvider>().loadSolicitudes(reset: true);
    });
  }

  // =============================
  // ✅ Orden: más reciente primero
  // =============================
  DateTime _sortDate(Solicitud s) {
    final raw = (s.fecha).trim();
    if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    final dt = DateTime.tryParse(raw);
    if (dt != null) return dt;

    try {
      return DateFormat('yyyy-MM-dd').parse(raw);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  // =============================
  // Carga tipos desde backend
  // =============================
  Future<void> _loadTipos() async {
    if (_tiposLoading) return;

    setState(() => _tiposLoading = true);

    try {
      final res = await ApiClient.dio.get('/tiposolicitudes');

      final body = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final data = List<Map<String, dynamic>>.from(body['data'] ?? const []);

      final map = <int, String>{};
      for (final t in data) {
        final rawId = t['id'];
        final id = (rawId is int) ? rawId : int.tryParse('$rawId') ?? 0;

        final nombre =
            (t['nombre'] ?? t['nombre_tipo'] ?? t['titulo'] ?? 'Tipo')
                .toString();

        if (id != 0) map[id] = nombre;
      }

      _tipoNombreById = map;
    } catch (_) {
      _tipoNombreById = {};
    } finally {
      if (mounted) setState(() => _tiposLoading = false);
    }
  }

  // =============================
  // Helpers de estado (API -> UI)
  // =============================
  String _estadoUi(Solicitud s) {
    final raw = (s.estado).trim();

    if (raw.toLowerCase() == 'por revisar') return 'Pendiente';
    if (raw.toLowerCase() == 'en progreso') return 'En Progreso';
    if (raw.toLowerCase() == 'aprobada') return 'Aprobada';

    if (raw.toLowerCase() == 'observada') return 'Observada';
    if (raw.toLowerCase() == 'derivada a becas') return 'Derivada a becas';
    if (raw.toLowerCase() == 'rechazada') return 'Rechazada';

    return raw;
  }

  bool _matchesFilter(Solicitud s) {
    if (_estadoSeleccionado == 'Todas') return true;
    if (_estadoSeleccionado == 'Pendientes') return _estadoUi(s) == 'Pendiente';
    if (_estadoSeleccionado == 'Aprobadas') return _estadoUi(s) == 'Aprobada';
    return true;
  }

  // =============================
  // Comentario admin: UI friendly
  // =============================
  String _comentarioAdminUi(Solicitud s) {
    final c = (s.comentario ?? '').trim();

    if (c.isEmpty) return 'Sin comentario';
    if (c.toLowerCase() == 'enviado desde la app') return 'Sin comentario';

    return c;
  }

  // =============================
  // Fecha bonita
  // =============================
  String _prettyDate(String raw) {
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt != null) return DateFormat('dd MMM yyyy', 'es_ES').format(dt);

    try {
      final d2 = DateFormat('yyyy-MM-dd').parse(raw);
      return DateFormat('dd MMM yyyy', 'es_ES').format(d2);
    } catch (_) {
      return raw;
    }
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SolicitudProvider>();
    final items = prov.items;

    // ✅ Ordenadas: más reciente primero
    final filtradas = items.where(_matchesFilter).toList()
      ..sort((a, b) => _sortDate(b).compareTo(_sortDate(a)));

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        title: Text(
          'Mis Solicitudes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top filtros + mini status (tipos)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _filtrosEstado(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tiposLoading
                            ? 'Cargando tipos…'
                            : 'Toca una solicitud para ver su estado y comentario.',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (_) {
                // Loading inicial
                if (prov.loading && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error inicial
                if (prov.error != null && items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prov.error!.replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context
                                .read<SolicitudProvider>()
                                .loadSolicitudes(reset: true, force: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIDEColors.conchevino,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty
                if (filtradas.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<SolicitudProvider>()
                        .refreshSolicitudes(limit: prov.limit),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 180),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.folder_open_rounded,
                                  size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(
                                'No hay solicitudes',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Desliza hacia abajo para actualizar.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context
                      .read<SolicitudProvider>()
                      .refreshSolicitudes(limit: prov.limit),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: filtradas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filtradas.length) {
                        return _footerPaginacion(prov);
                      }
                      return _cardSolicitud(filtradas[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: UIDEColors.conchevino,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const StudentNuevaSolicitudScreen()),
          );

          if (!mounted) return;
          await context.read<SolicitudProvider>().loadSolicitudes(
                reset: true,
                force: false,
              );
        },
      ),
    );
  }

  Widget _footerPaginacion(SolicitudProvider prov) {
    if (_loadingMoreLocal) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!prov.canLoadMore) return const SizedBox(height: 12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () async {
            setState(() => _loadingMoreLocal = true);
            try {
              await context
                  .read<SolicitudProvider>()
                  .loadSolicitudes(reset: false, force: true);
            } finally {
              if (mounted) setState(() => _loadingMoreLocal = false);
            }
          },
          icon: const Icon(Icons.expand_more),
          label: const Text('Cargar más'),
        ),
      ),
    );
  }

  // ================= FILTROS =================
  Widget _filtrosEstado() {
    final estados = ['Todas', 'Pendientes', 'Aprobadas'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: estados.map((e) {
          final activo = _estadoSeleccionado == e;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(e),
              selected: activo,
              selectedColor: UIDEColors.conchevino,
              backgroundColor: Colors.white,
              showCheckmark: false,
              labelStyle: GoogleFonts.poppins(
                color: activo ? Colors.white : UIDEColors.conchevino,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: UIDEColors.conchevino.withOpacity(activo ? 0 : 0.35),
              ),
              onSelected: (_) => setState(() => _estadoSeleccionado = e),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= CARD SOLICITUD =================
  Widget _cardSolicitud(Solicitud s) {
    final expandida = _solicitudExpandidaId == s.id;
    final estadoUi = _estadoUi(s);

    Color colorEstado = estadoUi == "Pendiente"
        ? UIDEColors.amarillo
        : estadoUi == "En Progreso"
            ? UIDEColors.azul
            : estadoUi == "Aprobada"
                ? Colors.green.shade700
                : UIDEColors.conchevino;

    final tipoNombre =
        (s.tipoId != null) ? (_tipoNombreById[s.tipoId!] ?? 'Tipo') : 'Tipo';
    final subtipoNombre =
        s.subtipoTitle.isNotEmpty ? s.subtipoTitle : 'Subtipo';
    final titulo = "$tipoNombre • $subtipoNombre";

    final fecha = _prettyDate(s.fecha);

    // ✅ comentario del admin: siempre muestra algo
    final comentarioAdmin = _comentarioAdminUi(s);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: expandida
              ? UIDEColors.conchevino.withOpacity(0.25)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _solicitudExpandidaId = expandida ? null : s.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  // indicador lateral
                  Container(
                    width: 10,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${s.id}",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              fecha.isEmpty ? "Fecha no disponible" : fecha,
                              style: GoogleFonts.poppins(
                                fontSize: 12.8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          estadoUi.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: colorEstado,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        expandida
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: expandida
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  _timelineEstado(estadoUi),
                  const SizedBox(height: 10),
                  _adminComentarioBox(comentarioAdmin),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _adminComentarioBox(String comentario) {
    final sinComentario = comentario.trim().toLowerCase() == 'sin comentario';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sinComentario
            ? Colors.grey.withOpacity(0.06)
            : UIDEColors.conchevino.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sinComentario
              ? Colors.black.withOpacity(0.10)
              : UIDEColors.conchevino.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            sinComentario
                ? Icons.chat_bubble_outline
                : Icons.chat_bubble_outline,
            size: 18,
            color: sinComentario ? Colors.grey.shade700 : UIDEColors.conchevino,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Comentario del administrador",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: sinComentario
                        ? Colors.grey.shade800
                        : UIDEColors.conchevino,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comentario,
                  style: GoogleFonts.poppins(
                    fontSize: 13.2,
                    height: 1.35,
                    color:
                        sinComentario ? Colors.grey.shade800 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TIMELINE =================
  Widget _timelineEstado(String estadoUi) {
    final pasos = ['Pendiente', 'En Progreso', 'Aprobada'];

    int indexActual = pasos.indexOf(estadoUi);
    if (indexActual == -1) indexActual = 1;

    Color colorPaso(String paso) {
      if (paso == 'Pendiente') return UIDEColors.amarillo;
      if (paso == 'En Progreso') return UIDEColors.azul;
      return Colors.green.shade700;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progreso",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: pasos.asMap().entries.map((e) {
              final i = e.key;
              final paso = e.value;
              final activo = i <= indexActual;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 14,
                          color:
                              activo ? colorPaso(paso) : Colors.grey.shade300,
                        ),
                        if (i < pasos.length - 1)
                          Container(
                            width: 2,
                            height: 22,
                            color:
                                activo ? colorPaso(paso) : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        paso,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight:
                              activo ? FontWeight.w700 : FontWeight.w400,
                          color: activo ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (estadoUi != 'Pendiente' &&
              estadoUi != 'En Progreso' &&
              estadoUi != 'Aprobada')
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: UIDEColors.conchevino.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: UIDEColors.conchevino.withOpacity(0.22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: UIDEColors.conchevino),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Estado actual: $estadoUi",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: UIDEColors.conchevino,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
