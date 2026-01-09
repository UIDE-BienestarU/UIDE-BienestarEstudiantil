import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/uide_colors.dart';
//importaciones
class StudentNuevaSolicitudScreen extends StatefulWidget {
  final String? tipoInicial;

  const StudentNuevaSolicitudScreen({Key? key, this.tipoInicial})
      : super(key: key);

  @override
  State<StudentNuevaSolicitudScreen> createState() =>
      _StudentNuevaSolicitudScreenState();
}

class _StudentNuevaSolicitudScreenState
    extends State<StudentNuevaSolicitudScreen> {
  late String _tipoSeleccionado;

  final List<String> _tiposSolicitud = const [
    'Beca Académica',
    'Beca Socioeconómica',
    'Cita Psicológica',
    'Certificado',
  ];

  final TextEditingController _descripcionController =
      TextEditingController();

  List<PlatformFile> _archivos = [];

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = widget.tipoInicial ?? _tiposSolicitud.first;
  }

  Future<void> _seleccionarArchivos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _archivos = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tipo de solicitud",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),

            /// 🔽 SELECTOR DE TIPO
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _tiposSolicitud
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _tipoSeleccionado = value!);
              },
            ),

            const SizedBox(height: 32),

            /// 📝 DESCRIPCIÓN
            TextField(
              controller: _descripcionController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Motivo / Descripción",
                hintText: "Explica por qué necesitas esta solicitud...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Adjuntar documentos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            /// 📎 SUBIR ARCHIVOS
            ListTile(
              leading: const Icon(
                Icons.cloud_upload_outlined,
                color: UIDEColors.azul,
              ),
              title: const Text("Toca para subir archivos"),
              subtitle: _archivos.isNotEmpty
                  ? Text("${_archivos.length} archivo(s) seleccionados")
                  : null,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _seleccionarArchivos,
            ),

            /// 📄 LISTA DE ARCHIVOS
            if (_archivos.isNotEmpty)
              Column(
                children: _archivos.map((file) {
                  return Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(file.name),
                      subtitle: Text(
                        "${(file.size / 1024).toStringAsFixed(2)} KB",
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 40),

            /// 🚀 ENVIAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIDEColors.conchevino,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Solicitud de $_tipoSeleccionado enviada con éxito",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "ENVIAR SOLICITUD",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
