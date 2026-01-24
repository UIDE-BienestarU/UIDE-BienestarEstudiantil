import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/uide_colors.dart';
import 'student_solicitud_enviada_screen.dart';

class StudentNuevaSolicitudScreen extends StatefulWidget {
  final String? tipoInicial;
  const StudentNuevaSolicitudScreen({Key? key, this.tipoInicial}) : super(key: key);

  @override
  State<StudentNuevaSolicitudScreen> createState() => _StudentNuevaSolicitudScreenState();
}

class _StudentNuevaSolicitudScreenState extends State<StudentNuevaSolicitudScreen> {
  // ================== DATA ==================
  final Map<String, List<String>> _tiposConSubtipos = {
    'Salud y bienestar físico': [
      'Atención médica general',
      'Emergencia médica / Primeros auxilios',
      'Validación de certificados médicos externos',
      'Atención odontológica (Clínica UIDE)',
      'Seguro de accidentes - Reembolso',
    ],
    'Apoyo psicológico y psicopedagógico': [
      'Asesoría psicológica individual',
      'Orientación vocacional y profesional',
      'Adaptaciones curriculares',
      'Intervención en crisis',
      'Talleres de prevención',
    ],
    'Becas y ayudas financieras': [
      'Beca por mérito académico',
      'Beca por situación socioeconómica',
      'Beca por mérito deportivo',
      'Beca por movilidad humana',
      'Beca por discapacidad',
      'Beca pueblos y nacionalidades',
      'Descuento por convenio institucional',
    ],
    'Gestión académica y administrativa': [
      'Solicitud de reingreso',
      'Cambio de carrera / sede',
      'Retiro temporal de asignatura',
      'Solicitud de tercera matrícula',
      'Justificación de faltas',
    ],
    'Deportes y cultura': [
      'Inscripción a clubes culturales',
      'Reserva de canchas / gimnasio',
      'Inscripción a selecciones deportivas',
      'Voluntariado universitario',
    ],
  };

  late String _tipoSeleccionado;
  late String _subtipoSeleccionado;
  final TextEditingController _descripcionController = TextEditingController();
  List<PlatformFile> _archivos = [];

  // ================== INIT ==================
  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = widget.tipoInicial ?? _tiposConSubtipos.keys.first;
    _subtipoSeleccionado = _tiposConSubtipos[_tipoSeleccionado]!.first;
  }

  // ================== VALIDACIÓN ==================
  bool _formularioValido() {
    return _descripcionController.text.trim().isNotEmpty;
  }

  // ================== FILE PICKER ==================
  Future<void> _seleccionarArchivos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        if (result.files.isNotEmpty) {
          _archivos.addAll(result.files);
        }
      });
    }
  }

  void _eliminarArchivo(int index) {
    setState(() {
      _archivos.removeAt(index);
    });
  }

  // ================== ALERTAS ==================
  void _mostrarErrorCampos() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Campos incompletos"),
        content: const Text("Por favor, completa los campos requeridos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionEnvio() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirmar envío"),
        content: const Text(
          "Por favor, revisa que la información y documentación sea correcta.\n\n"
          "Ante dudas puedes comunicarte a los contactos que están en tu perfil.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Regresar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UIDEColors.conchevino),
            onPressed: () {
              Navigator.pop(context);
              _enviarSolicitud();
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _enviarSolicitud() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const StudentSolicitudEnviadaScreen()),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ===== FORMULARIO =====
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, "Tipo de solicitud"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _tipoSeleccionado,
                      decoration: _inputDecoration(context),
                      items: _tiposConSubtipos.keys.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoSeleccionado = value!;
                          _subtipoSeleccionado = _tiposConSubtipos[value]!.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    _label(context, "Subtipo de solicitud"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _subtipoSeleccionado,
                      decoration: _inputDecoration(context),
                      items: _tiposConSubtipos[_tipoSeleccionado]!
                          .map((sub) => DropdownMenuItem(value: sub, child: Text(sub, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (value) => setState(() => _subtipoSeleccionado = value!),
                    ),
                    const SizedBox(height: 24),
                    _label(context, "Descripción"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descripcionController,
                      maxLines: 6,
                      decoration: _inputDecoration(context, hint: "Describe el motivo de tu solicitud..."),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== ADJUNTOS TÚNICO WIDGET ✅=====
            _label(context, "Adjuntar documentos"),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                children: [
                  // ✅ HEADER: Selector o contador
                  _archivos.isEmpty
                      ? GestureDetector(
                          onTap: _seleccionarArchivos,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: const [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: UIDEColors.conchevino,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Toca para adjuntar documentos",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "PDF, JPG o PNG (máx. 10MB)",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, color: UIDEColors.conchevino, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_archivos.length} archivo${_archivos.length == 1 ? '' : 's'} adjuntado${_archivos.length == 1 ? '' : 's'}",
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    GestureDetector(
                                      onTap: _seleccionarArchivos,
                                      child: Text(
                                        "Toca para agregar más",
                                        style: TextStyle(color: UIDEColors.conchevino, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                  // ✅ LISTA DE ARCHIVOS (solo si hay)
                  if (_archivos.isNotEmpty) ...[
                    const Divider(height: 1),
                    ..._archivos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: const Icon(Icons.insert_drive_file, color: UIDEColors.conchevino, size: 24),
                          title: Text(file.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                          subtitle: Text("${(file.size / 1024).toStringAsFixed(2)} KB", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 20),
                            onPressed: () => _eliminarArchivo(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ===== BOTÓN =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIDEColors.conchevino,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (!_formularioValido()) {
                    _mostrarErrorCampos();
                    return;
                  }
                  _mostrarConfirmacionEnvio();
                },
                child: const Text(
                  "Enviar solicitud",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HELPERS ==================
  Widget _label(BuildContext context, String texto) {
    final theme = Theme.of(context);
    return Text(
      texto,
      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: UIDEColors.conchevino),
      ),
    );
  }
}
