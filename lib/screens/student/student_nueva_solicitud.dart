import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../theme/uide_colors.dart';
import 'student_solicitud_enviada_screen.dart';

class StudentNuevaSolicitudScreen extends StatefulWidget {
  final String? tipoInicial;
  const StudentNuevaSolicitudScreen({super.key, this.tipoInicial});

  @override
  State<StudentNuevaSolicitudScreen> createState() =>
      _StudentNuevaSolicitudScreenState();
}

class _StudentNuevaSolicitudScreenState
    extends State<StudentNuevaSolicitudScreen> {
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
  final TextEditingController _descripcionController =
      TextEditingController();
  List<PlatformFile> _archivos = [];

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado =
        widget.tipoInicial ?? _tiposConSubtipos.keys.first;
    _subtipoSeleccionado =
        _tiposConSubtipos[_tipoSeleccionado]!.first;
  }

  bool _formularioValido() {
    return _descripcionController.text.trim().isNotEmpty;
  }

  Future<void> _seleccionarArchivos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => _archivos.addAll(result.files));
    }
  }

  void _eliminarArchivo(int index) {
    setState(() => _archivos.removeAt(index));
  }

  void _mostrarErrorCampos() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Campos incompletos"),
        content:
            const Text("Por favor, completa los campos requeridos."),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirmar envío"),
        content: const Text(
          "Revisa que la información y documentos sean correctos.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Regresar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
            ),
            onPressed: () {
              Navigator.pop(context);
              _enviarSolicitud();
            },
            child: const Text("Confirmar",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _enviarSolicitud() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentSolicitudEnviadaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✅ APPBAR PROPIO (NO SE BORRA)
      appBar: AppBar(
        title: const Text("Nueva solicitud"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, "Tipo de solicitud"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        isExpanded: true,
                        decoration: _inputDecoration(context),
                        items: _tiposConSubtipos.keys
                            .map((tipo) => DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _tipoSeleccionado = v!;
                            _subtipoSeleccionado =
                                _tiposConSubtipos[v]!.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _label(context, "Subtipo de solicitud"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _subtipoSeleccionado,
                        isExpanded: true,
                        decoration: _inputDecoration(context),
                        items: _tiposConSubtipos[_tipoSeleccionado]!
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _subtipoSeleccionado = v!),
                      ),
                      const SizedBox(height: 24),
                      _label(context, "Descripción"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descripcionController,
                        maxLines: 6,
                        decoration: _inputDecoration(
                          context,
                          hint:
                              "Describe el motivo de tu solicitud...",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIDEColors.conchevino,
                    padding:
                        const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String texto) {
    return Text(
      texto,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(BuildContext context,
      {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: UIDEColors.conchevino),
      ),
    );
  }
}
