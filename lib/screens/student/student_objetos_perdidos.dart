import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/uide_colors.dart';
import '../../providers/objetos_perdidos_provider.dart';
import '../../services/api_client.dart';
import '../../services/comentarios_objeto_service.dart';

class StudentObjetosPerdidosScreen extends StatefulWidget {
  const StudentObjetosPerdidosScreen({super.key});

  @override
  State<StudentObjetosPerdidosScreen> createState() =>
      _StudentObjetosPerdidosScreenState();
}

class _StudentObjetosPerdidosScreenState
    extends State<StudentObjetosPerdidosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _load(force: true));
  }

  Future<void> _load({bool force = false}) async {
    await context.read<ObjetosPerdidosProvider>().load(
          force: force,
          limit: 80,
          estado: null, // ✅ sin filtros
        );
  }

  String _toFullUploadsUrl(String pathOrUrl) {
    final p = pathOrUrl.trim();
    if (p.isEmpty) return '';
    if (p.startsWith('http')) return p;

    final u = Uri.parse(ApiClient.baseUrl); // https://.../api
    final hostBase = '${u.scheme}://${u.host}';
    if (p.startsWith('/')) return '$hostBase$p';
    return '$hostBase/$p';
  }

  void _openImage(BuildContext context, String url, {required String heroTag}) {
    if (url.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerScreen(url: url, heroTag: heroTag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ObjetosPerdidosProvider>();

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text('Objetos perdidos'),
        actions: [
          IconButton(
            tooltip: "Refrescar",
            onPressed: prov.loading ? null : () => _load(force: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Text(
                  "Listado completo",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: UIDEColors.conchevino,
                  ),
                ),
              ),
            ),

            // Estados UI
            if (prov.loading && prov.items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(26),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (prov.error != null && prov.items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ErrorBox(
                    message: prov.error!,
                    onRetry: () => _load(force: true),
                  ),
                ),
              )
            else if (prov.items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Center(
                    child: Text(
                      "No hay objetos registrados",
                      style: GoogleFonts.poppins(color: Colors.grey.shade700),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList.separated(
                  itemCount: prov.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final o = prov.items[i];
                    final heroTag = 'objeto-img-${o.id}';
                    final imgUrl =
                        (o.imagen != null && o.imagen!.trim().isNotEmpty)
                            ? _toFullUploadsUrl(o.imagen!)
                            : '';

                    return _ObjetoCard(
                      id: o.id,
                      titulo: o.titulo,
                      descripcion: o.descripcion,
                      estado: o.estado,
                      imagenUrl: imgUrl,
                      heroTag: heroTag,
                      onOpenImage: imgUrl.isEmpty
                          ? null
                          : () => _openImage(context, imgUrl, heroTag: heroTag),
                      onComentarios: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              ComentariosObjetoModal(objetoId: o.id),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ObjetoCard extends StatelessWidget {
  final int id;
  final String titulo;
  final String descripcion;
  final String estado;
  final String imagenUrl;
  final String heroTag;
  final VoidCallback? onOpenImage;
  final VoidCallback onComentarios;

  const _ObjetoCard({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.imagenUrl,
    required this.heroTag,
    required this.onOpenImage,
    required this.onComentarios,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _estadoChip(estado);

    // ✅ Card recorta bien + sombra correcta
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias, // ✅ IMPORTANTÍSIMO: recorte real
      child: InkWell(
        onTap: onOpenImage,
        child: Row(
          children: [
            // ✅ Imagen SIEMPRE recortada al radio de la card (lado izquierdo)
            SizedBox(
              width: 108,
              height: 108,
              child: ClipRRect(
                // Solo redondea las esquinas izquierdas
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: imagenUrl.isEmpty
                    ? Container(
                        color: UIDEColors.conchevino.withOpacity(0.08),
                        child: const Icon(
                          Icons.backpack_rounded,
                          color: UIDEColors.conchevino,
                          size: 34,
                        ),
                      )
                    : Hero(
                        tag: heroTag,
                        child: Image.network(
                          imagenUrl,
                          fit: BoxFit.cover,
                          // ✅ evita que “pinte” fuera
                          filterQuality: FilterQuality.low,
                          errorBuilder: (_, __, ___) => Container(
                            color: UIDEColors.conchevino.withOpacity(0.08),
                            child: const Icon(
                              Icons.broken_image,
                              color: UIDEColors.conchevino,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo.isEmpty ? 'Objeto perdido' : titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(child: chip),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion.isEmpty ? 'Sin descripción' : descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.25,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onComentarios,
                        icon: const Icon(Icons.comment_rounded, size: 18),
                        label: const Text("Comentarios"),
                        style: TextButton.styleFrom(
                          foregroundColor: UIDEColors.azul,
                          textStyle:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
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

  Widget _estadoChip(String estadoRaw) {
    final e = estadoRaw.trim().toLowerCase();
    Color c;
    String label;

    if (e == 'perdido') {
      c = Colors.red.shade700;
      label = 'PERDIDO';
    } else if (e == 'devuelto') {
      c = Colors.green.shade700;
      label = 'DEVUELTO';
    } else {
      c = UIDEColors.azul;
      label = 'ENCONTRADO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          color: c,
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
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
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

// ✅ Pantalla fullscreen con zoom
class _ImageViewerScreen extends StatelessWidget {
  final String url;
  final String heroTag;

  const _ImageViewerScreen({required this.url, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Hero(
                  tag: heroTag,
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
            ),
            Positioned(
              top: 10,
              right: 10,
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
// ✅ Modal Comentarios (REST)
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
