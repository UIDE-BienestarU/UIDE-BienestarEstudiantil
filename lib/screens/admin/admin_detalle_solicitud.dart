import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/solicitud.dart';
import '../../providers/admin_provider.dart';
import '../../theme/uide_colors.dart';
import '../../services/api_client.dart';

class AdminDetalleSolicitudScreen extends StatefulWidget {
  final Solicitud solicitud;

  const AdminDetalleSolicitudScreen({
    super.key,
    required this.solicitud,
  });

  @override
  State<AdminDetalleSolicitudScreen> createState() =>
      _AdminDetalleSolicitudScreenState();
}

class _AdminDetalleSolicitudScreenState
    extends State<AdminDetalleSolicitudScreen> {
  bool _mostrarMotivoPosponer = false;
  final TextEditingController _motivoController = TextEditingController();

  // ✅ Comentarios
  final TextEditingController _comentarioController = TextEditingController();

  bool _working = false;

  // ✅ Estado editable en pantalla
  late String _estadoSeleccionadoUi;

  // ✅ Estados válidos backend (Swagger)
  static const List<String> _estadosBackend = <String>[
    'Por revisar',
    'En progreso',
    'Observada',
    'Derivada a becas',
    'Aprobada',
    'Rechazada',
  ];

  @override
  void initState() {
    super.initState();
    _estadoSeleccionadoUi = _estadoParaBackend(widget.solicitud.estado);
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  // =======================
  // Helpers UI
  // =======================
  Color _estadoColor(String estadoRaw) {
    final e = estadoRaw.trim().toLowerCase();
    if (e == 'aprobada' || e == 'aprobado') return Colors.green.shade700;
    if (e == 'en progreso' || e == 'en revisión' || e == 'en revision') {
      return UIDEColors.azul;
    }
    if (e == 'rechazada' || e == 'rechazado') return Colors.red.shade700;
    if (e == 'observada') return Colors.orange.shade800;
    if (e == 'derivada a becas') return Colors.deepPurple.shade700;
    return UIDEColors.conchevino;
  }

  bool get _puedeActuar {
    final e = widget.solicitud.estado.trim().toLowerCase();
    return e == "pendiente" ||
        e == "por revisar" ||
        e == "en revisión" ||
        e == "en revision" ||
        e == "en progreso" ||
        e == "observada" ||
        e == "derivada a becas";
  }

  // =======================
  // Estados (UI -> Backend)
  // =======================
  String _estadoParaBackend(String estadoUi) {
    final e = estadoUi.trim().toLowerCase();

    if (e == 'por revisar') return 'Por revisar';
    if (e == 'en progreso') return 'En progreso';
    if (e == 'observada') return 'Observada';
    if (e == 'derivada a becas') return 'Derivada a becas';
    if (e == 'aprobada' || e == 'aprobado') return 'Aprobada';
    if (e == 'rechazada' || e == 'rechazado') return 'Rechazada';

    // compat con estados viejos
    if (e == 'pendiente' || e == 'en revisión' || e == 'en revision') {
      return 'Por revisar';
    }

    return 'Por revisar';
  }

  // =======================
  // URL builders (robusto)
  // =======================
  Uri _hostBaseUri() {
    // ApiClient.baseUrl = https://api-prod.uidehub.tech/api
    final base = Uri.parse(ApiClient.baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );
  }

  String _normalizePath(String p) {
    var x = p.trim();
    if (x.isEmpty) return '';
    x = x.replaceAll('"', '').replaceAll("'", "").trim();
    x = x.replaceAll(RegExp(r'\/{2,}'), '/');
    return x;
  }

  String _toFullUrl(String maybeUrlOrPath) {
    final raw = _normalizePath(maybeUrlOrPath);
    if (raw.isEmpty) return '';

    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('www.')) return 'https://$raw';

    final hostBase = _hostBaseUri();

    if (raw.startsWith('/')) return hostBase.resolve(raw).toString();
    return hostBase.resolve('/$raw').toString();
  }

  Future<void> _openDocUrl(String urlOrPath) async {
    final fixed = _toFullUrl(urlOrPath);

    if (fixed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay URL/ruta para descargar")),
      );
      return;
    }

    final uri = Uri.tryParse(fixed);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL inválida del documento")),
      );
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir el archivo")),
      );
    }
  }

  ({String name, String url}) _docInfo(dynamic d) {
    if (d is String) {
      final raw = _normalizePath(d);
      final nameGuess = raw.isEmpty ? 'Documento' : raw.split('/').last.trim();
      return (name: nameGuess.isEmpty ? 'Documento' : nameGuess, url: raw);
    }

    if (d is Map) {
      final map = Map<String, dynamic>.from(d);

      final name = (map['nombre_documento'] ??
              map['nombreDocumento'] ??
              map['originalName'] ??
              map['name'] ??
              map['filename'] ??
              map['titulo'] ??
              map['nombre'] ??
              'Documento')
          .toString()
          .trim();

      final rawUrl = (map['url_archivo'] ??
              map['url'] ??
              map['link'] ??
              map['path'] ??
              map['ruta'] ??
              '')
          .toString()
          .trim();

      return (name: name.isEmpty ? 'Documento' : name, url: rawUrl);
    }

    return (name: 'Documento', url: '');
  }

  // =======================
  // ✅ Actualizar estado (endpoint real)
  // PUT /solicitudes/:id/estado
  // body: { estado_actual, comentario? }
  // =======================
  Future<void> _actualizarEstado({
    required String estadoBackend,
    String? comentario,
    bool cerrarAlFinal = false,
  }) async {
    if (_working) return;
    setState(() => _working = true);

    try {
      await ApiClient.dio.put(
        '/solicitudes/${widget.solicitud.id}/estado',
        data: {
          'estado_actual': estadoBackend,
          if (comentario != null && comentario.trim().isNotEmpty)
            'comentario': comentario.trim(),
        },
      );

      // ✅ actualiza UI local
      setState(() {
        _estadoSeleccionadoUi = estadoBackend;
      });

      // ✅ refresca lista admin si quieres (ignora cache)
      try {
        await context.read<AdminProvider>().refresh();
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Estado actualizado: $estadoBackend ✅"),
          backgroundColor: UIDEColors.conchevino,
        ),
      );

      if (cerrarAlFinal && mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  // =======================
  // ✅ Comentario (funcional)
  // reutiliza el endpoint de estado
  // =======================
  Future<void> _enviarComentario() async {
    final txt = _comentarioController.text.trim();
    if (txt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe un comentario primero")),
      );
      return;
    }

    final estadoActual = _estadoSeleccionadoUi; // lo que esté seleccionado

    await _actualizarEstado(
      estadoBackend: estadoActual,
      comentario: txt,
      cerrarAlFinal: false,
    );

    if (mounted) _comentarioController.clear();
  }

  // =======================
  // Posponer (sin endpoint)
  // =======================
  Future<void> _posponer(AdminProvider provider) async {
    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe especificar el motivo")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Posponer se gestiona desde la web de administración."),
      ),
    );

    setState(() => _mostrarMotivoPosponer = false);
    _motivoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminProvider>();
    final estadoColor = _estadoColor(_estadoSeleccionadoUi);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Detalle de Solicitud"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(estadoColor),
            const SizedBox(height: 14),

            _sectionCard(
              title: "Información",
              child: Column(
                children: [
                  _infoTile(Icons.email_rounded, "Correo institucional",
                      widget.solicitud.correo),
                  _divider(),
                  _infoTile(
                      Icons.category_rounded, "Tipo", widget.solicitud.tipo),
                  _divider(),
                  _infoTile(Icons.label_rounded, "Subtipo",
                      widget.solicitud.subtipo ?? "No especificado"),
                  _divider(),
                  _infoTile(Icons.calendar_today_rounded, "Fecha de envío",
                      widget.solicitud.fecha),
                  _divider(),
                  _infoTile(Icons.flag_rounded, "Estado actual",
                      _estadoSeleccionadoUi),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Selector de estado
            _sectionCard(
              title: "Cambiar estado",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _estadoSeleccionadoUi,
                    items: _estadosBackend
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: _working
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() => _estadoSeleccionadoUi = v);
                          },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: UIDEColors.conchevino,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _working
                          ? null
                          : () => _actualizarEstado(
                                estadoBackend: _estadoSeleccionadoUi,
                                cerrarAlFinal: false,
                              ),
                      icon: _working
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text("Guardar estado"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIDEColors.conchevino,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ Botones rápidos
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _working
                              ? null
                              : () => _actualizarEstado(
                                    estadoBackend: 'En progreso',
                                  ),
                          child: const Text("En progreso"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _working
                              ? null
                              : () => _actualizarEstado(
                                    estadoBackend: 'Rechazada',
                                  ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          child: const Text("Rechazar"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _working
                          ? null
                          : () => _actualizarEstado(
                                estadoBackend: 'Aprobada',
                                cerrarAlFinal: true,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Aprobar",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _sectionCard(
              title: "Descripción",
              child: Text(
                (widget.solicitud.descripcion ?? '').trim().isEmpty
                    ? "No hay descripción proporcionada."
                    : widget.solicitud.descripcion!.trim(),
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 12),

            _sectionCard(
              title: "Documentos adjuntos",
              child: _docsList(),
            ),

            const SizedBox(height: 12),

            // ✅ Comentarios (funcional)
            _sectionCard(
              title: "Comentario",
              child: Column(
                children: [
                  TextField(
                    controller: _comentarioController,
                    enabled: !_working,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Escribe un comentario para el estudiante…",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: UIDEColors.conchevino,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _working ? null : _enviarComentario,
                      icon: _working
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: const Text("Enviar comentario"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIDEColors.azul,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (_puedeActuar) _acciones(provider),
            if (_mostrarMotivoPosponer) _posponerBox(provider),
          ],
        ),
      ),
    );
  }

  // =======================
  // UI pieces
  // =======================
  Widget _header(Color estadoColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: UIDEColors.conchevino.withOpacity(0.14),
              child: Text(
                widget.solicitud.estudiante.isNotEmpty
                    ? widget.solicitud.estudiante[0].toUpperCase()
                    : "E",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: UIDEColors.conchevino,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.solicitud.estudiante,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.solicitud.correo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: ${widget.solicitud.id} • ${widget.solicitud.fecha}",
                    style:
                        TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: estadoColor.withOpacity(0.25)),
              ),
              child: Text(
                _estadoSeleccionadoUi.toUpperCase(),
                style: TextStyle(
                  color: estadoColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: UIDEColors.conchevino,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: UIDEColors.conchevino),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.8,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: Colors.black.withOpacity(0.06)),
      );

  // =======================
  // Docs
  // =======================
  Widget _docsList() {
    final docs = widget.solicitud.documentos;

    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "No hay documentos adjuntos",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: docs.map((d) {
        final info = _docInfo(d);
        final full = _toFullUrl(info.url);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: ListTile(
            leading:
                const Icon(Icons.attach_file, color: UIDEColors.conchevino),
            title: Text(
              info.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              full.isEmpty
                  ? "Ruta no disponible"
                  : "Tocar para abrir/descargar",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download_rounded,
                  color: UIDEColors.conchevino),
              onPressed: _working ? null : () => _openDocUrl(info.url),
            ),
            onTap: _working ? null : () => _openDocUrl(info.url),
          ),
        );
      }).toList(),
    );
  }

  // =======================
  // Actions (posponer demo)
  // =======================
  Widget _acciones(AdminProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _working
                ? null
                : () => setState(
                    () => _mostrarMotivoPosponer = !_mostrarMotivoPosponer),
            icon: const Icon(Icons.hourglass_bottom_rounded, size: 20),
            label: const Text("Posponer"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.black.withOpacity(0.18)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _posponerBox(AdminProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Motivo de la posposición",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: UIDEColors.conchevino,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _motivoController,
                maxLines: 3,
                enabled: !_working,
                decoration: InputDecoration(
                  hintText:
                      "Escribe la razón por la cual se pospone la solicitud",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: UIDEColors.conchevino),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _working ? null : () => _posponer(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 108, 6, 25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _working
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Confirmar",
                          style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
