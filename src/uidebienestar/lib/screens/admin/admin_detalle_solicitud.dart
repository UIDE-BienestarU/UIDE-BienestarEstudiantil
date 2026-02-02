import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/solicitud.dart';
import '../../providers/admin_provider.dart';
import '../../theme/uide_colors.dart';

class AdminDetalleSolicitudScreen extends StatefulWidget {
  final Solicitud solicitud;

  const AdminDetalleSolicitudScreen({
    Key? key,
    required this.solicitud,
  }) : super(key: key);

  @override
  State<AdminDetalleSolicitudScreen> createState() => _AdminDetalleSolicitudScreenState();
}

class _AdminDetalleSolicitudScreenState extends State<AdminDetalleSolicitudScreen> {
  bool _mostrarMotivoPosponer = false;
  final TextEditingController _motivoController = TextEditingController();

  // ✅ VALIDADOR POSPONER
  void _showMotivoErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: UIDEColors.amarillo, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UIDEColors.azul,
              ),
            ),
          ],
        ),
        content: const Text(
          'Debe especificar el motivo de la posposición',
          style: TextStyle(
            fontSize: 16,
            color: UIDEColors.grisTexto,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ VALIDADOR APROBAR
  void _showAprobacionExitoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ÍCONO CHECK VERDE ✅
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 20, 162, 1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 45,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "¡Solicitud aprobada con éxito!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: UIDEColors.azul,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "La solicitud ha sido procesada correctamente.\nEl estudiante recibirá una notificación.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Vuelve a lista
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 20, 162, 1),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Volver a Solicitudes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final colorPrincipal = UIDEColors.conchevino;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        title: const Text("Detalle de Solicitud"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header compacto
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorPrincipal.withOpacity(0.15),
                  child: Text(
                    widget.solicitud.estudiante[0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorPrincipal,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.solicitud.estudiante,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.solicitud.correo,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "ID: ${widget.solicitud.id} • ${widget.solicitud.fecha}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: colorPrincipal.withOpacity(0.15),
                  label: Text(
                    widget.solicitud.estado,
                    style: TextStyle(
                      color: colorPrincipal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Información de la solicitud
            const Text(
              "Información de la solicitud",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UIDEColors.conchevino),
            ),
            const SizedBox(height: 12),
            _buildInfoRow("Correo institucional", widget.solicitud.correo),
            const Divider(height: 32),
            _buildInfoRow("Tipo de solicitud", widget.solicitud.tipo),
            const Divider(height: 32),
            _buildInfoRow("Subtipo", widget.solicitud.subtipo ?? "No especificado"),
            const Divider(height: 32),
            _buildInfoRow("Fecha de envío", widget.solicitud.fecha),
            const Divider(height: 32),
            _buildInfoRow("Estado actual", widget.solicitud.estado),
            const SizedBox(height: 32),

            // Descripción
            const Text(
              "Descripción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UIDEColors.conchevino),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.solicitud.descripcion ?? "No hay descripción proporcionada.",
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            // Documentos adjuntos
            const Text(
              "Documentos adjuntos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UIDEColors.conchevino),
            ),
            const SizedBox(height: 12),
            if (widget.solicitud.documentos == null || widget.solicitud.documentos!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No hay documentos adjuntos", style: TextStyle(color: Colors.grey))),
              )
            else
              ...widget.solicitud.documentos!.map((docName) => _buildDocumentRow(docName)),
            const SizedBox(height: 48),

            // Botones de acción ✅ ACTUALIZADOS
            if (widget.solicitud.estado == "Pendiente" || widget.solicitud.estado == "En revisión")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.aprobar(widget.solicitud.id);
                        _showAprobacionExitoDialog(); // ✅ NUEVO VALIDADOR
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text("Aprobar", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrincipal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mostrarMotivoPosponer = !_mostrarMotivoPosponer;
                        });
                      },
                      icon: const Icon(Icons.hourglass_empty, size: 20),
                      label: const Text("Posponer", style: TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

            // Campo motivo posposición ✅ ACTUALIZADO
            if (_mostrarMotivoPosponer) ...[
              const SizedBox(height: 24),
              const Text(
                "Motivo de la posposición",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: UIDEColors.conchevino),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _motivoController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Escribe la razón por la cual se pospone la solicitud",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: UIDEColors.conchevino),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_motivoController.text.trim().isEmpty) {
                      _showMotivoErrorDialog(); // ✅ NUEVO VALIDADOR
                      return;
                    }
                    setState(() {
                      _mostrarMotivoPosponer = false;
                    });
                    _motivoController.clear();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 108, 6, 25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Confirmar", style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String docName) {
    return ListTile(
      leading: const Icon(Icons.attach_file, color: UIDEColors.conchevino),
      title: Text(docName, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text("Archivo adjunto", style: TextStyle(color: Colors.grey)),
      trailing: Builder(
        builder: (BuildContext buttonContext) {
          return IconButton(
            icon: const Icon(Icons.download, color: UIDEColors.conchevino),
            onPressed: () {
              ScaffoldMessenger.of(buttonContext).showSnackBar(
                SnackBar(content: Text("Descargando $docName..."), duration: const Duration(seconds: 2)),
              );
            },
          );
        },
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
