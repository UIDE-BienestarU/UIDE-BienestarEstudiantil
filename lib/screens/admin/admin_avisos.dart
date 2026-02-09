import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../theme/uide_colors.dart';
import '../../models/aviso.dart';
import '../../providers/avisos_provider.dart';
import '../../providers/objetos_perdidos_provider.dart';
import '../../services/api_client.dart';

class AdminAvisosScreen extends StatefulWidget {
  final CategoriaAviso? categoriaInicial;

  const AdminAvisosScreen({
    super.key,
    this.categoriaInicial,
  });

  @override
  State<AdminAvisosScreen> createState() => _AdminAvisosScreenState();
}

class _AdminAvisosScreenState extends State<AdminAvisosScreen> {
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();

  CategoriaAviso _categoria = CategoriaAviso.comunicado;
  final List<String> _imagenesPaths = [];

  bool _mostrarActivos = true; // solo UI para avisos
  bool _saving = false;

  // UI: formulario colapsable
  bool _formExpanded = true;

  bool get _esObjetos => _categoria == CategoriaAviso.objetosPerdidos;

  @override
  void initState() {
    super.initState();

    if (widget.categoriaInicial != null) {
      _categoria = widget.categoriaInicial!;
    }

    // carga inicial según categoría
    Future.microtask(() => _refreshActual(force: true));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  // =====================
  // Helpers URL uploads
  // =====================
  String _toFullUploadsUrl(String pathOrUrl) {
    final p = (pathOrUrl).trim();
    if (p.isEmpty) return '';
    if (p.startsWith('http')) return p;

    final u = Uri.parse(ApiClient.baseUrl);
    final hostBase = '${u.scheme}://${u.host}';

    if (p.startsWith('/')) return '$hostBase$p';
    return '$hostBase/$p';
  }

  // =====================
  // Refresh actual
  // =====================
  Future<void> _refreshActual({bool force = false}) async {
    if (_esObjetos) {
      await context
          .read<ObjetosPerdidosProvider>()
          .load(force: force, limit: 50);
    } else {
      await context.read<AvisosProvider>().adminRefresh();
    }
  }

  // =====================
  // Imagen
  // =====================
  Future<void> _seleccionarImagen() async {
    if (_saving) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imagenesPaths.add(pickedFile.path));
    }
  }

  void _eliminarImagen(int index) {
    if (_saving) return;
    setState(() => _imagenesPaths.removeAt(index));
  }

  // =====================
  // Guardar (según categoría)
  // =====================
  Future<void> _guardar() async {
    if (_saving) return;

    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (titulo.isEmpty || contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y contenido son obligatorios')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      File? img;
      if (_imagenesPaths.isNotEmpty) img = File(_imagenesPaths.first);

      if (_esObjetos) {
        await context.read<ObjetosPerdidosProvider>().adminReportar(
              titulo: titulo,
              descripcion: contenido,
              foto: img,
              estado: 'encontrado',
            );
      } else {
        await context.read<AvisosProvider>().adminCrearSegunCategoria(
              categoria: _categoria,
              titulo: titulo,
              contenido: contenido,
              imagen: img,
            );
      }

      _tituloController.clear();
      _contenidoController.clear();
      setState(() {
        _imagenesPaths.clear();
        _formExpanded = false; // colapsa al publicar (se siente “pro”)
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicado ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // =====================
  // Acciones Objetos Perdidos
  // =====================
  Future<void> _cambiarEstadoObjeto({
    required int id,
    required String estadoActual,
  }) async {
    if (_saving) return;

    const estados = ['perdido', 'encontrado', 'devuelto'];

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            const Text(
              "Cambiar estado",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            ...estados.map(
              (e) => ListTile(
                title: Text(e.toUpperCase()),
                trailing: e == estadoActual ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, e),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null && selected != estadoActual) {
      try {
        setState(() => _saving = true);
        await context.read<ObjetosPerdidosProvider>().adminCambiarEstado(
              id: id,
              estado: selected,
            );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  Future<void> _eliminarObjeto({required int id}) async {
    if (_saving) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar objeto"),
        content: const Text("¿Seguro? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        setState(() => _saving = true);
        await context.read<ObjetosPerdidosProvider>().adminEliminar(id: id);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  void _onCategoriaChanged(CategoriaAviso value) {
    if (_saving) return;
    if (widget.categoriaInicial != null) return;

    setState(() {
      _categoria = value;
      _formExpanded = true;
      _imagenesPaths.clear();
      _tituloController.clear();
      _contenidoController.clear();
    });

    _refreshActual(force: true);
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoriaInicial != null
              ? "Nuevo ${widget.categoriaInicial == CategoriaAviso.objetosPerdidos ? 'Objeto perdido' : 'Comunicado'}"
              : "Publicaciones",
        ),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Refrescar",
            onPressed: _saving ? null : () => _refreshActual(force: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshActual(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.categoriaInicial == null) _categoriaSegmentada(),
                    if (widget.categoriaInicial == null)
                      const SizedBox(height: 10),
                    _formularioCard(),
                    const SizedBox(height: 12),
                    Text(
                      _esObjetos ? "Objetos perdidos" : "Publicaciones",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: UIDEColors.conchevino,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!_esObjetos) _filtroActivos(),
                  ],
                ),
              ),
            ),

            // LISTA
            if (_esObjetos) _sliverObjetos() else _sliverAvisos(),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
          ],
        ),
      ),
    );
  }

  // =====================
  // Segmentado (categoría)
  // =====================
  Widget _categoriaSegmentada() {
    final isCom = _categoria == CategoriaAviso.comunicado;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segBtn(
              active: isCom,
              icon: Icons.campaign_rounded,
              label: "Comunicados",
              onTap: () => _onCategoriaChanged(CategoriaAviso.comunicado),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _segBtn(
              active: !isCom,
              icon: Icons.backpack_rounded,
              label: "Objetos",
              onTap: () => _onCategoriaChanged(CategoriaAviso.objetosPerdidos),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segBtn({
    required bool active,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _saving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? UIDEColors.conchevino : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : Colors.black54),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // Formulario
  // =====================
  Widget _formularioCard() {
    final titulo = _esObjetos ? "Reportar objeto perdido" : "Crear comunicado";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _formExpanded = !_formExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: UIDEColors.conchevino,
                      ),
                    ),
                  ),
                  Icon(
                    _formExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _formExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _tituloController,
                    enabled: !_saving,
                    decoration: InputDecoration(
                      labelText: "Título",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contenidoController,
                    enabled: !_saving,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _esObjetos ? "Descripción" : "Contenido",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Imagen
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_photo_alternate, size: 20),
                          label: Text(
                            _imagenesPaths.isEmpty
                                ? "Agregar imagen"
                                : "${_imagenesPaths.length} imagen seleccionada",
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: UIDEColors.conchevino,
                            side:
                                const BorderSide(color: UIDEColors.conchevino),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saving ? null : _seleccionarImagen,
                        ),
                      ),
                    ],
                  ),

                  if (_imagenesPaths.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _previewImagen(),
                  ],

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIDEColors.conchevino,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saving ? null : _guardar,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _esObjetos ? "Publicar objeto" : "Publicar aviso",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewImagen() {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagenesPaths.length,
        itemBuilder: (_, i) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(_imagenesPaths[i]),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: _saving ? null : () => _eliminarImagen(i),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================
  // Filtro Activos/Inactivos (solo avisos)
  // =====================
  Widget _filtroActivos() {
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 10,
        children: [
          ChoiceChip(
            label: const Text("Activos"),
            selected: _mostrarActivos,
            selectedColor: UIDEColors.conchevino.withOpacity(0.15),
            onSelected: (_) => setState(() => _mostrarActivos = true),
          ),
          ChoiceChip(
            label: const Text("Inactivos"),
            selected: !_mostrarActivos,
            selectedColor: Colors.grey.withOpacity(0.2),
            onSelected: (_) => setState(() => _mostrarActivos = false),
          ),
        ],
      ),
    );
  }

  // =====================
  // Sliver Avisos
  // =====================
  Widget _sliverAvisos() {
    final avisos = context.watch<AvisosProvider>().avisos;
    final avisosFiltrados =
        avisos.where((a) => a.activo == _mostrarActivos).toList();

    if (avisosFiltrados.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Center(
            child: Text(
              "No hay publicaciones aún",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: avisosFiltrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = avisosFiltrados[i];
        final first = (a.imagen ?? '').split(',').first.trim();
        final imgUrl = first.isNotEmpty ? _toFullUploadsUrl(first) : '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 1.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: _thumbNetwork(imgUrl),
              title: Text(
                a.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                a.contenido,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline,
                    color: UIDEColors.conchevino),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Edición/eliminación de avisos aún no está en móvil.",
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================
  // Sliver Objetos Perdidos
  // =====================
  Widget _sliverObjetos() {
    final objProv = context.watch<ObjetosPerdidosProvider>();

    if (objProv.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (objProv.error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(objProv.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saving ? null : () => _refreshActual(force: true),
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    if (objProv.items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text("No hay objetos perdidos")),
        ),
      );
    }

    return SliverList.separated(
      itemCount: objProv.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final o = objProv.items[i];
        final imgUrl = (o.imagen != null && o.imagen!.trim().isNotEmpty)
            ? _toFullUploadsUrl(o.imagen!)
            : '';

        final chip = _estadoChip(o.estado);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 1.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: _thumbNetwork(imgUrl, fallback: Icons.backpack_rounded),
              title: Text(
                o.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    chip,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        o.descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: PopupMenuButton<String>(
                enabled: !_saving,
                onSelected: (v) async {
                  if (v == 'estado') {
                    await _cambiarEstadoObjeto(
                        id: o.id, estadoActual: o.estado);
                  }
                  if (v == 'delete') {
                    await _eliminarObjeto(id: o.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'estado', child: Text("Cambiar estado")),
                  PopupMenuItem(value: 'delete', child: Text("Eliminar")),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================
  // UI bits
  // =====================
  Widget _thumbNetwork(String url, {IconData fallback = Icons.image}) {
    if (url.isEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: UIDEColors.conchevino.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(fallback, color: UIDEColors.conchevino),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: UIDEColors.conchevino.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.broken_image, color: UIDEColors.conchevino),
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
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          color: c,
        ),
      ),
    );
  }
}
