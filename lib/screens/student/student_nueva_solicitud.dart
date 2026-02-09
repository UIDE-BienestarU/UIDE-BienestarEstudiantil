import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/solicitud_provider.dart';
import '../../services/api_client.dart';
import '../../services/solicitud_draft_service.dart';
import '../../theme/uide_colors.dart';
import 'student_solicitud_enviada_screen.dart';

class StudentNuevaSolicitudScreen extends StatefulWidget {
  final String? tipoInicial; // viene desde Home
  const StudentNuevaSolicitudScreen({super.key, this.tipoInicial});

  @override
  State<StudentNuevaSolicitudScreen> createState() =>
      _StudentNuevaSolicitudScreenState();
}

/// ✅ Estructura tipada para evitar Object? en name
class _TipoNorm {
  final int id;
  final Map<String, dynamic> raw;
  final String name; // normalizado

  const _TipoNorm({
    required this.id,
    required this.raw,
    required this.name,
  });
}

class _StudentNuevaSolicitudScreenState
    extends State<StudentNuevaSolicitudScreen> {
  // =======================
  // Catálogo real (API)
  // =======================
  bool _catalogLoading = false;
  String? _catalogError;

  List<Map<String, dynamic>> _tipos = [];
  List<Map<String, dynamic>> _subtipos = [];

  int? _tipoIdSeleccionado;
  int? _subtipoIdSeleccionado;

  String _tipoNombreSeleccionado = '';
  String _subtipoNombreSeleccionado = '';

  // ✅ evita autosave durante arranque
  bool _booting = true;

  // =======================
  // Form
  // =======================
  final TextEditingController _descripcionController = TextEditingController();
  final FocusNode _descFocus = FocusNode();
  final List<PlatformFile> _archivos = [];
  bool _sending = false;

  // =======================
  // Draft (autosave/restore)
  // =======================
  Timer? _draftDebounce;
  String? _draftId;
  bool _draftLoading = false;
  bool _draftDirty = false;
  DateTime? _draftSavedAt;

  @override
  void initState() {
    super.initState();
    _initFlow();

    _descripcionController.addListener(() {
      _draftDirty = true;
      _scheduleDraftSave();
    });
  }

  // ✅ orden nuevo: catálogo -> si viene tipoInicial, aplicar y NO draft -> si no, cargar draft
  Future<void> _initFlow() async {
    await _loadCatalogo();

    final tipo = widget.tipoInicial?.trim() ?? '';
    if (tipo.isNotEmpty) {
      // vienes desde Home: esto debe ganar y NO ser pisado por draft
      _applyTipoInicialByNombre(tipo);
      _booting = false;
      return;
    }

    await _loadDraft();
    _booting = false;
  }

  // =======================
  // Helpers básicos
  // =======================
  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  String _asStr(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  String _nombreTipo(Map<String, dynamic> t) {
    return _asStr(
      t['nombre'],
      _asStr(t['nombre_tipo'], _asStr(t['titulo'], 'Tipo')),
    );
  }

  String _nombreSubtipo(Map<String, dynamic> s) {
    return _asStr(
      s['nombre_sub'],
      _asStr(s['nombre'], _asStr(s['titulo'], 'Subtipo')),
    );
  }

  List<Map<String, dynamic>> get _subtiposFiltrados {
    final tid = _tipoIdSeleccionado;
    if (tid == null) return [];
    return _subtipos.where((s) => _asInt(s['tipo_id']) == tid).toList();
  }

  void _syncNombresFromIds() {
    final tid = _tipoIdSeleccionado;
    final sid = _subtipoIdSeleccionado;

    if (tid != null) {
      final t = _tipos.where((x) => _asInt(x['id']) == tid).toList();
      _tipoNombreSeleccionado = t.isNotEmpty ? _nombreTipo(t.first) : '';
    } else {
      _tipoNombreSeleccionado = '';
    }

    if (sid != null) {
      final s = _subtipos.where((x) => _asInt(x['id']) == sid).toList();
      _subtipoNombreSeleccionado = s.isNotEmpty ? _nombreSubtipo(s.first) : '';
    } else {
      _subtipoNombreSeleccionado = '';
    }
  }

  void _setDefaultsCatalogo() {
    if (_tipos.isEmpty) return;

    _tipoIdSeleccionado = _asInt(_tipos.first['id']);
    final subs = _subtiposFiltrados;
    _subtipoIdSeleccionado = subs.isNotEmpty ? _asInt(subs.first['id']) : null;

    _syncNombresFromIds();
  }

  // ======================================================
  // ✅ MATCH robusto: normalize + scoring
  // ======================================================
  String _normalize(String s) {
    var x = s.trim().toLowerCase();

    x = x.replaceAll(RegExp(r'^(sobre|acerca de|tema|tipo)\s+'), '');

    x = x
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');

    x = x.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();

    return x;
  }

  int _scoreMatch(String query, String candidate) {
    if (query.isEmpty || candidate.isEmpty) return 0;

    final qWords = query.split(' ').where((w) => w.length >= 3).toSet();
    final cWords = candidate.split(' ').where((w) => w.length >= 3).toSet();

    var score = 0;
    for (final w in qWords) {
      if (cWords.contains(w)) score += 3;
      if (candidate.contains(w)) score += 1;
    }

    if (candidate == query) score += 12;
    if (candidate.contains(query)) score += 5;

    return score;
  }

  void _applyTipoInicialByNombre(String tipoNombre) {
    if (_tipos.isEmpty) return;

    final q = _normalize(tipoNombre);
    if (q.isEmpty) return;

    final normalized = <_TipoNorm>[];
    for (final t in _tipos) {
      final id = _asInt(t['id']);
      if (id == null) continue;
      normalized.add(_TipoNorm(
        id: id,
        raw: t,
        name: _normalize(_nombreTipo(t)),
      ));
    }
    if (normalized.isEmpty) return;

    // exact match
    final exact = normalized.where((x) => x.name == q).toList();
    _TipoNorm? chosen;

    if (exact.isNotEmpty) {
      chosen = exact.first;
    } else {
      normalized.sort((a, b) {
        final sa = _scoreMatch(q, a.name);
        final sb = _scoreMatch(q, b.name);
        return sb.compareTo(sa);
      });

      final best = normalized.first;
      final bestScore = _scoreMatch(q, best.name);
      if (bestScore >= 3) chosen = best;
    }

    if (chosen == null) return;

    setState(() {
      _tipoIdSeleccionado = chosen!.id;

      final subs = _subtiposFiltrados;
      _subtipoIdSeleccionado =
          subs.isNotEmpty ? _asInt(subs.first['id']) : null;

      _syncNombresFromIds();
    });

    _draftDirty = true;
    _scheduleDraftSave();
  }

  // =======================
  // API catálogo
  // =======================
  Future<void> _loadCatalogo() async {
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });

    try {
      final tiposRes = await ApiClient.dio.get('/tiposolicitudes');
      final subtiposRes = await ApiClient.dio.get('/subtiposolicitudes');

      final tipos =
          List<Map<String, dynamic>>.from(tiposRes.data['data'] ?? []);
      final subs =
          List<Map<String, dynamic>>.from(subtiposRes.data['data'] ?? []);

      _tipos = tipos;
      _subtipos = subs;

      _setDefaultsCatalogo();

      if (mounted) setState(() {});
    } catch (e) {
      _catalogError = e.toString().replaceFirst('Exception: ', '');
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _catalogLoading = false);
    }
  }

  // =======================
  // Files
  // =======================
  Future<List<File>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );

    if (result == null) return [];

    return result.files
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();
  }

  Future<void> _seleccionarArchivos() async {
    final files = await pickFiles();
    if (files.isEmpty) return;

    final picked = files
        .map((f) => PlatformFile(
              name: f.path.split(Platform.pathSeparator).last,
              path: f.path,
              size: f.lengthSync(),
            ))
        .toList();

    setState(() => _archivos.addAll(picked));
    _draftDirty = true;
    _scheduleDraftSave();
  }

  void _eliminarArchivo(int index) {
    setState(() => _archivos.removeAt(index));
    _draftDirty = true;
    _scheduleDraftSave();
  }

  List<File> get _archivosSeleccionados => _archivos
      .where((f) => f.path != null && f.path!.isNotEmpty)
      .map((f) => File(f.path!))
      .toList();

  // =======================
  // Draft payload
  // =======================
  Map<String, dynamic> _buildDraftPayload() {
    _syncNombresFromIds();
    return {
      "tipoId": _tipoIdSeleccionado,
      "subtipoId": _subtipoIdSeleccionado,
      "tipoNombre": _tipoNombreSeleccionado,
      "subtipoNombre": _subtipoNombreSeleccionado,
      "descripcion": _descripcionController.text.trim(),
      "archivos": _archivos
          .map((f) => {
                "name": f.name,
                "path": f.path,
                "size": f.size,
              })
          .toList(),
    };
  }

  Future<void> _loadDraft() async {
    setState(() => _draftLoading = true);

    try {
      final draft = await SolicitudDraftService.getLatestDraft();
      if (draft == null) return;

      _draftId = draft['id']?.toString();

      final payloadRaw = draft['payload'];
      Map<String, dynamic>? payload;

      if (payloadRaw is Map<String, dynamic>) {
        payload = payloadRaw;
      } else if (payloadRaw is String && payloadRaw.isNotEmpty) {
        if (payloadRaw.trim().startsWith('{')) {
          payload = Map<String, dynamic>.from(jsonDecode(payloadRaw) as Map);
        }
      }

      if (payload == null) return;

      final tipoId = _asInt(payload["tipoId"]);
      final subtipoId = _asInt(payload["subtipoId"]);

      if (tipoId != null && _tipos.any((t) => _asInt(t['id']) == tipoId)) {
        _tipoIdSeleccionado = tipoId;

        final subs = _subtiposFiltrados;
        if (subtipoId != null &&
            subs.any((s) => _asInt(s['id']) == subtipoId)) {
          _subtipoIdSeleccionado = subtipoId;
        } else {
          _subtipoIdSeleccionado =
              subs.isNotEmpty ? _asInt(subs.first['id']) : null;
        }
      } else {
        _setDefaultsCatalogo();
      }

      _descripcionController.text = _asStr(payload["descripcion"], "");

      final archivosRaw = payload["archivos"];
      if (archivosRaw is List) {
        _archivos.clear();
        for (final a in archivosRaw) {
          if (a is Map) {
            final name = _asStr(a["name"], "archivo");
            final path = _asStr(a["path"], "");
            final size = _asInt(a["size"]) ?? 0;
            if (path.isNotEmpty) {
              _archivos.add(PlatformFile(name: name, path: path, size: size));
            }
          }
        }
      }

      _syncNombresFromIds();
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("No se pudo cargar draft: $e");
      }
    } finally {
      if (mounted) setState(() => _draftLoading = false);
    }
  }

  void _scheduleDraftSave() {
    // ✅ NO guardes draft durante el arranque
    if (_booting) return;

    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 650), () async {
      await _saveDraftNow();
    });
  }

  Future<void> _saveDraftNow() async {
    if (!_draftDirty) return;

    final payload = _buildDraftPayload();

    try {
      if (_draftId == null) {
        final created =
            await SolicitudDraftService.createDraft(payload: payload);
        _draftId = created['id']?.toString();
      } else {
        await SolicitudDraftService.updateDraft(
          draftId: _draftId!,
          payload: payload,
        );
      }
      _draftDirty = false;
      _draftSavedAt = DateTime.now();
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("Draft save error: $e");
      }
    }
  }

  bool _formularioValido() {
    final descOk = _descripcionController.text.trim().isNotEmpty;
    return descOk && _subtipoIdSeleccionado != null;
  }

  // =======================
  // Enviar solicitud
  // =======================
  Future<void> _enviarSolicitudReal() async {
    if (_sending) return;

    final provider = context.read<SolicitudProvider>();
    final subtipoId = _subtipoIdSeleccionado;
    if (subtipoId == null) {
      throw Exception("Selecciona un subtipo válido");
    }

    final payload = {
      "subtipo_id": subtipoId,
      "nivel_urgencia": "Normal",
      "observaciones": _descripcionController.text.trim(),
      "comentario": "Enviado desde la app",
    };

    setState(() => _sending = true);

    try {
      await provider.crearSolicitud(
        payload: payload,
        archivos: _archivosSeleccionados,
      );

      _draftDirty = false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud enviada correctamente")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentSolicitudEnviadaScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _mostrarConfirmacionEnvio() {
    _syncNombresFromIds();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: UIDEColors.conchevino.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: UIDEColors.conchevino,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Confirmar envío",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sending ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ResumenItem(
                label: "Tipo",
                value: _tipoNombreSeleccionado.isEmpty
                    ? "—"
                    : _tipoNombreSeleccionado,
              ),
              const SizedBox(height: 8),
              _ResumenItem(
                label: "Subtipo",
                value: _subtipoNombreSeleccionado.isEmpty
                    ? "—"
                    : _subtipoNombreSeleccionado,
              ),
              const SizedBox(height: 8),
              _ResumenItem(
                label: "Archivos",
                value: "${_archivos.length} adjunto(s)",
              ),
              const SizedBox(height: 14),
              Text(
                "¿Listo? Revisa que la descripción y documentos sean correctos.",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sending ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Regresar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIDEColors.conchevino,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _sending
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _enviarSolicitudReal();
                            },
                      child: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Enviar",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    final solicitudProvider = context.watch<SolicitudProvider>();
    final loading = _sending || solicitudProvider.loading || _catalogLoading;

    // ✅ asegura que el value exista en items
    final tipoIds = _tipos.map((t) => _asInt(t['id'])).whereType<int>().toSet();
    if (_tipoIdSeleccionado != null && !tipoIds.contains(_tipoIdSeleccionado)) {
      _tipoIdSeleccionado = tipoIds.isNotEmpty ? tipoIds.first : null;
    }

    final subs = _subtiposFiltrados;
    final subIds = subs.map((s) => _asInt(s['id'])).whereType<int>().toSet();
    if (_subtipoIdSeleccionado != null &&
        !subIds.contains(_subtipoIdSeleccionado)) {
      _subtipoIdSeleccionado = subIds.isNotEmpty ? subIds.first : null;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              children: [
                if (_catalogError != null) ...[
                  _ErrorBanner(
                    message: _catalogError!,
                    onRetry: loading ? null : _loadCatalogo,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_draftLoading) ...[
                  const _InfoBanner(text: "Cargando borrador…"),
                  const SizedBox(height: 12),
                ],
                const _HeaderCard(
                  title: "Completa tu solicitud",
                  subtitle:
                      "Selecciona el subtipo y describe tu caso. Puedes adjuntar evidencias.",
                ),
                const SizedBox(height: 14),
                _StepCard(
                  step: "1",
                  title: "Elige el tipo y subtipo",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Tipo de solicitud"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _tipoIdSeleccionado,
                        isExpanded: true,
                        decoration:
                            _inputDecoration(hint: "Selecciona un tipo"),
                        items: _tipos
                            .map((t) {
                              final id = _asInt(t['id']);
                              if (id == null) return null;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  _nombreTipo(t),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            })
                            .whereType<DropdownMenuItem<int>>()
                            .toList(),
                        onChanged: loading
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() {
                                  _tipoIdSeleccionado = v;
                                  final subList = _subtiposFiltrados;
                                  _subtipoIdSeleccionado = subList.isNotEmpty
                                      ? _asInt(subList.first['id'])
                                      : null;
                                  _syncNombresFromIds();
                                });
                                _draftDirty = true;
                                _scheduleDraftSave();
                              },
                      ),
                      const SizedBox(height: 16),
                      _label("Subtipo de solicitud"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _subtipoIdSeleccionado,
                        isExpanded: true,
                        decoration:
                            _inputDecoration(hint: "Selecciona un subtipo"),
                        items: subs
                            .map((s) {
                              final id = _asInt(s['id']);
                              if (id == null) return null;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  _nombreSubtipo(s),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            })
                            .whereType<DropdownMenuItem<int>>()
                            .toList(),
                        onChanged: loading
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() {
                                  _subtipoIdSeleccionado = v;
                                  _syncNombresFromIds();
                                });
                                _draftDirty = true;
                                _scheduleDraftSave();
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _StepCard(
                  step: "2",
                  title: "Describe tu situación",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Descripción"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descripcionController,
                        focusNode: _descFocus,
                        maxLines: 6,
                        enabled: !loading,
                        decoration: _inputDecoration(
                          hint:
                              "Cuéntanos qué pasó, fechas, y lo que necesitas…",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tip: mientras más claro, más rápido te ayudan.",
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _StepCard(
                  step: "3",
                  title: "Adjunta evidencias (opcional)",
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text("Adjuntar archivos"),
                          onPressed: loading ? null : _seleccionarArchivos,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side:
                                const BorderSide(color: UIDEColors.conchevino),
                            foregroundColor: UIDEColors.conchevino,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_archivos.isEmpty)
                        _MiniHint(
                          icon: Icons.info_outline,
                          text:
                              "PDF o imágenes (JPG/PNG/WEBP). Puedes seleccionar varios.",
                        )
                      else
                        Column(
                          children: List.generate(_archivos.length, (i) {
                            final f = _archivos[i];
                            return _FileTile(
                              name: f.name,
                              subtitle: _prettySize(f.size),
                              onRemove:
                                  loading ? null : () => _eliminarArchivo(i),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
                if (solicitudProvider.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    solicitudProvider.error!.replaceFirst('Exception: ', ''),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 90),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                saving: _draftDirty && !_draftLoading && !loading,
                savedAt: _draftSavedAt,
                enabled: !loading,
                loading: loading,
                onSubmit: () {
                  if (!_formularioValido()) {
                    _showInlineError(context);
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  _mostrarConfirmacionEnvio();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // Helpers UI
  // =======================
  void _showInlineError(BuildContext context) {
    final msg = (_subtipoIdSeleccionado == null)
        ? "Selecciona un subtipo para continuar."
        : "Escribe una descripción para continuar.";

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    if (_subtipoIdSeleccionado == null) return;
    _descFocus.requestFocus();
  }

  String _prettySize(int bytes) {
    if (bytes <= 0) return "0 KB";
    final kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(0)} KB";
    final mb = kb / 1024;
    return "${mb.toStringAsFixed(1)} MB";
  }

  static Widget _label(String texto) {
    return Builder(
      builder: (context) => Text(
        texto,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
          fontSize: 13.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: UIDEColors.conchevino, width: 1.6),
      ),
    );
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    _descripcionController.dispose();
    _descFocus.dispose();
    super.dispose();
  }
}

// ======================================================
// Widgets pequeños (UI)
// ======================================================

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIDEColors.azul.withOpacity(0.95),
            UIDEColors.azul.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.8,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
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

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final Widget child;

  const _StepCard({
    required this.step,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: UIDEColors.conchevino.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    step,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      color: UIDEColors.conchevino,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onRemove;

  const _FileTile({
    required this.name,
    required this.subtitle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: UIDEColors.conchevino.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.insert_drive_file_rounded,
              color: UIDEColors.conchevino),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
        subtitle: Text(
          subtitle,
          style:
              GoogleFonts.poppins(fontSize: 12.3, color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}

class _MiniHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.grey.shade700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text("Reintentar"),
          )
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool saving;
  final DateTime? savedAt;
  final bool enabled;
  final bool loading;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.saving,
    required this.savedAt,
    required this.enabled,
    required this.loading,
    required this.onSubmit,
  });

  String _savedText() {
    if (saving) return "Guardando borrador…";
    if (savedAt == null) return "Borrador listo";
    final now = DateTime.now();
    final diff = now.difference(savedAt!);
    if (diff.inSeconds < 10) return "Guardado hace unos segundos";
    if (diff.inMinutes < 1) return "Guardado hace ${diff.inSeconds}s";
    return "Guardado hace ${diff.inMinutes} min";
    // (si quieres fino, aquí puedes formatear hh:mm)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    saving
                        ? Icons.cloud_upload_rounded
                        : Icons.cloud_done_rounded,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _savedText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIDEColors.conchevino,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: (!enabled || loading) ? null : onSubmit,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Enviar",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResumenItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              fontSize: 13.2,
            ),
          ),
        ),
      ],
    );
  }
}
