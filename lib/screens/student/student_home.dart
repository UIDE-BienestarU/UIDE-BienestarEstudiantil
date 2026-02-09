import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/session_provider.dart';
import '../../providers/avisos_provider.dart';
import '../../models/aviso.dart';

import '../../theme/uide_colors.dart';
import '../../services/comentarios_objeto_service.dart';
import '../../services/api_client.dart';

import 'student_dashboard.dart';

// ✅ provider de objetos perdidos
import '../../providers/objetos_perdidos_provider.dart';

// ✅ NUEVO: pantalla para ver todos los objetos perdidos
import 'student_objetos_perdidos.dart';

// ✅ NUEVO: navegar directo a crear solicitud
import 'student_nueva_solicitud.dart'; // <-- IMPORTA TU SCREEN REAL

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();

    // Cargas iniciales (no bloquean UI)
    Future.microtask(() => context.read<AvisosProvider>().loadPublicaciones());
    Future.microtask(
        () => context.read<ObjetosPerdidosProvider>().load(limit: 5));
  }

  // ✅ construye URL completa para /Uploads/...
  String _toFullUploadsUrl(String pathOrUrl) {
    final p = pathOrUrl.trim();
    if (p.isEmpty) return '';
    if (p.startsWith('http')) return p;

    final u = Uri.parse(ApiClient.baseUrl); // https://.../api
    final hostBase = '${u.scheme}://${u.host}';

    if (p.startsWith('/')) return '$hostBase$p';
    return '$hostBase/$p';
  }

  Future<void> _refreshAll() async {
    await context.read<AvisosProvider>().loadPublicaciones();
    await context.read<ObjetosPerdidosProvider>().load(force: true, limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    final avisosProvider = context.watch<AvisosProvider>();
    final comunicados =
        avisosProvider.avisosPorCategoria(CategoriaAviso.comunicado);

    final objProv = context.watch<ObjetosPerdidosProvider>();
    final objetos = objProv.items;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _saludo(context),
                  const SizedBox(height: 18),

                  _seccionHeader(
                    title: "Acciones rápidas",
                    subtitle: "Solicita ayuda en 1 toque",
                    icon: Icons.flash_on_rounded,
                    trailing: null,
                  ),
                  const SizedBox(height: 10),
                  _accionesRapidas(context),

                  const SizedBox(height: 20),

                  // ================= OBJETOS =================
                  _seccionHeader(
                    title: "Objetos perdidos",
                    subtitle: "Lo más reciente reportado",
                    icon: Icons.backpack_rounded,
                    trailing: TextButton(
                      onPressed: () {
                        // ✅ Ahora navega a la pantalla correcta
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const StudentObjetosPerdidosScreen(),
                          ),
                        );
                      },
                      child: const Text("Ver todo"),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (objProv.loading)
                    const _LoadingCard(height: 230)
                  else if (objProv.error != null)
                    _ErrorBox(
                      message: objProv.error!,
                      onRetry: () => context
                          .read<ObjetosPerdidosProvider>()
                          .load(force: true, limit: 5),
                    )
                  else if (objetos.isEmpty)
                    _EmptyBox(text: "No hay objetos perdidos por ahora")
                  else
                    _objetoDestacado(context, objetos.first),

                  const SizedBox(height: 22),

                  // ================= NOTICIAS =================
                  _seccionHeader(
                    title: "Noticias",
                    subtitle: "Comunicados de Bienestar",
                    icon: Icons.campaign_rounded,
                    trailing: IconButton(
                      tooltip: "Actualizar",
                      onPressed: avisosProvider.loading
                          ? null
                          : () => context
                              .read<AvisosProvider>()
                              .loadPublicaciones(),
                      icon: const Icon(Icons.refresh,
                          color: UIDEColors.conchevino),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (avisosProvider.loading)
                    const _LoadingList(count: 3)
                  else if (avisosProvider.error != null)
                    _ErrorBox(
                      message: avisosProvider.error!,
                      onRetry: () =>
                          context.read<AvisosProvider>().loadPublicaciones(),
                    )
                  else if (comunicados.isEmpty)
                    _EmptyBox(text: "No hay noticias publicadas")
                  else
                    Column(
                      children: comunicados
                          .take(5)
                          .map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _noticiaCard(context, a),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _saludo(BuildContext context) {
    final nombre =
        context.watch<SessionProvider>().nombreCompleto ?? 'Estudiante';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIDEColors.azul.withOpacity(0.98),
            UIDEColors.azul.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¡Hola, $nombre!",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bienestar está aquí para ayudarte.",
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.waving_hand_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECCION HEADER =================
  Widget _seccionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: UIDEColors.conchevino.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: UIDEColors.conchevino),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: UIDEColors.conchevino,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12.8,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ================= ACCIONES RÁPIDAS =================
  Widget _accionesRapidas(BuildContext context) {
    final items = [
      _QuickAction(
        icon: Icons.health_and_safety_rounded,
        label: "Salud",
        color: Colors.green,
        tipoReal: "Salud y bienestar físico",
      ),
      _QuickAction(
        icon: Icons.psychology_rounded,
        label: "Psicológico",
        color: Colors.purple,
        tipoReal: "Apoyo psicológico y psicopedagógico",
      ),
      _QuickAction(
        icon: Icons.school_rounded,
        label: "Becas",
        color: Colors.orange,
        tipoReal: "Becas y ayudas financieras",
      ),
      _QuickAction(
        icon: Icons.admin_panel_settings_rounded,
        label: "Académico",
        color: Colors.blue,
        tipoReal: "Gestión académica y administrativa",
      ),
      _QuickAction(
        icon: Icons.sports_soccer_rounded,
        label: "Deportes",
        color: Colors.redAccent,
        tipoReal: "Deportes y cultura",
      ),
    ];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final a = items[i];
          return _accionPill(
            context,
            icon: a.icon,
            color: a.color,
            label: a.label,
            tipoReal: a.tipoReal,
          );
        },
      ),
    );
  }

  Widget _accionPill(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String tipoReal,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      // ✅ CAMBIO: ahora abre NuevaSolicitudScreen con el tipo ya seleccionado
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentNuevaSolicitudScreen(
              tipoInicial: tipoReal, // ✅ aquí viaja el tipo elegido
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= OBJETO DESTACADO =================
  Widget _objetoDestacado(BuildContext context, dynamic obj) {
    final titulo = (obj.titulo ?? '').toString();
    final desc = (obj.descripcion ?? '').toString();
    final img = (obj.imagen ?? '').toString().trim();
    final fullImg = img.isEmpty ? '' : _toFullUploadsUrl(img);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 210,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (fullImg.isNotEmpty)
                  GestureDetector(
                    onTap: () => _verImagenFullscreen(context, fullImg),
                    child: Image.network(
                      fullImg,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgFallback(),
                    ),
                  )
                else
                  _imgFallback(),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "Reciente",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: IconButton(
                      icon: const Icon(Icons.comment_rounded,
                          color: UIDEColors.azul),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              ComentariosObjetoModal(objetoId: obj.id),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo.isEmpty ? "Objeto perdido" : titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc.isEmpty ? "Sin descripción" : desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.backpack_rounded, size: 64, color: Colors.grey),
        ),
      );

  void _verImagenFullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NOTICIAS =================
  Widget _noticiaCard(BuildContext context, Aviso aviso) {
    final imagenes = _imagenesAviso(aviso);
    final hasImg = imagenes.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _verNoticiaModal(context, aviso),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 92,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: UIDEColors.conchevino.withOpacity(0.08),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImg
                  ? Image.network(
                      imagenes.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        color: UIDEColors.conchevino,
                        size: 34,
                      ),
                    )
                  : const Icon(
                      Icons.campaign_rounded,
                      color: UIDEColors.conchevino,
                      size: 34,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aviso.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14.8,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      aviso.contenido,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.25,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: UIDEColors.conchevino.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "Leer",
                            style: GoogleFonts.poppins(
                              color: UIDEColors.conchevino,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _imagenesAviso(Aviso aviso) {
    final img = (aviso.imagen ?? '').trim();
    if (img.isEmpty) return [];
    final parts =
        img.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.map(_toFullUploadsUrl).toList();
  }

  void _verNoticiaModal(BuildContext context, Aviso aviso) {
    final imagenes = _imagenesAviso(aviso);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagenes.isNotEmpty)
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: imagenes.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _verImagenesFullscreen(
                                context, imagenes,
                                inicial: index),
                            child: Image.network(
                              imagenes[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported,
                                    size: 50),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(999),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
                  color: UIDEColors.conchevino.withOpacity(0.06),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_rounded,
                          color: UIDEColors.conchevino),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Comunicado",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: UIDEColors.conchevino,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aviso.titulo,
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        aviso.contenido,
                        style: GoogleFonts.poppins(fontSize: 14, height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verImagenesFullscreen(BuildContext context, List<String> imagenes,
      {int inicial = 0}) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: inicial),
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      imagenes[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// ✅ Modal Comentarios (REST) - mantiene APIs
// ======================================================
class ComentariosObjetoModal extends StatefulWidget {
  final int objetoId;
  const ComentariosObjetoModal({super.key, required this.objetoId});

  @override
  State<ComentariosObjetoModal> createState() => _ComentariosObjetoModalState();
}

class _ComentariosObjetoModalState extends State<ComentariosObjetoModal> {
  bool _loading = false;
  String? _error;
  List<ComentarioObjetoDto> _items = [];

  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items =
          await ComentariosObjetoService.list(objetoId: widget.objetoId);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _iniciales(String nombre) {
    final parts =
        nombre.trim().split(RegExp(r'\s+')).where((x) => x.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await ComentariosObjetoService.create(
        objetoId: widget.objetoId,
        mensaje: text,
      );
      _controller.clear();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.70,
        width: MediaQuery.of(context).size.width * 0.92,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: UIDEColors.azul.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.comment_rounded,
                        color: UIDEColors.azul),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Comentarios",
                      style: GoogleFonts.poppins(
                          fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: "Actualizar",
                    icon: const Icon(Icons.refresh),
                    onPressed: _loading ? null : _load,
                  ),
                  IconButton(
                    tooltip: "Cerrar",
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (_loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _load,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIDEColors.conchevino,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Reintentar"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_items.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay comentarios aún",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = _items[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                UIDEColors.conchevino.withOpacity(0.12),
                            child: Text(
                              _iniciales(c.autorNombre),
                              style: const TextStyle(
                                color: UIDEColors.conchevino,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.04)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.autorNombre,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    c.mensaje,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13.5, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sending ? null : _send(),
                      decoration: InputDecoration(
                        hintText: "Escribe un comentario...",
                        hintStyle:
                            GoogleFonts.poppins(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIDEColors.azul,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ======================================================
// UI Helpers
// ======================================================
class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  final int count;
  const _LoadingList({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 92,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                  color: Colors.red.shade700, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(Icons.inbox_rounded, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String tipoReal;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.tipoReal,
  });
}
