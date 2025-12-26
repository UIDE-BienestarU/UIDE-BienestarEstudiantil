// lib/screens/admin/admin_detalle_solicitud_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/solicitud.dart';
import '../../providers/admin_provider.dart';
import '../../theme/uide_colors.dart';

class AdminDetalleSolicitudScreen extends StatelessWidget {
  final Solicitud solicitud;

  const AdminDetalleSolicitudScreen({Key? key, required this.solicitud}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Detalle de Solicitud"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal del estudiante
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: solicitud.colorEstado.withOpacity(0.2),
                      child: Text(
                        solicitud.estudiante[0],
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: solicitud.colorEstado),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(solicitud.estudiante, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("ID: ${solicitud.id}", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Chip(
                      backgroundColor: solicitud.colorEstado.withOpacity(0.2),
                      label: Text(solicitud.estado, style: TextStyle(color: solicitud.colorEstado, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Información
            _buildInfoSection("Tipo de solicitud", solicitud.tipo),
            const SizedBox(height: 16),
            _buildInfoSection("Fecha de envío", solicitud.fecha),
            const SizedBox(height: 16),
            _buildInfoSection("Estado actual", solicitud.estado),
            const SizedBox(height: 32),

            // Documentos adjuntos (mock)
            const Text("Documentos adjuntos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
            const SizedBox(height: 12),
            _buildDocumentRow("Cédula de identidad", "cedula.pdf"),
            _buildDocumentRow("Certificado de notas", "notas.pdf"),
            _buildDocumentRow("Carta de motivación", "carta.pdf"),
            const SizedBox(height: 40),

            // Botones de acción
            if (solicitud.estado == "Pendiente" || solicitud.estado == "En revisión") ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.aprobar(solicitud.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Solicitud APROBADA"), backgroundColor: Colors.green),
                        );
                      },
                      icon: const Icon(Icons.check_circle, size: 28),
                      label: const Text("Aprobar", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Podrías agregar rechazar también
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Funcionalidad en desarrollo")),
                        );
                      },
                      icon: const Icon(Icons.cancel, size: 28),
                      label: const Text("Posponer", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solicitud derivada al área de becas")),
                    );
                  },
                  icon: const Icon(Icons.forward),
                  label: const Text("Derivar a otra área"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UIDEColors.azul,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: UIDEColors.azul),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ] else
              Center(
                child: Chip(
                  backgroundColor: solicitud.colorEstado.withOpacity(0.2),
                  label: Text("Esta solicitud ya fue ${solicitud.estado.toLowerCase()}", style: TextStyle(fontSize: 16, color: solicitud.colorEstado)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDocumentRow(String name, String file) {
    return ListTile(
      leading: const Icon(Icons.attach_file, color: UIDEColors.azul),
      title: Text(name),
      subtitle: Text(file),
      trailing: IconButton(icon: const Icon(Icons.download), onPressed: () {}),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[300]!)),
    );
  }
}