import 'package:flutter/material.dart';

class StudentHistorialScreen extends StatefulWidget {
  const StudentHistorialScreen({Key? key}) : super(key: key);

  @override
  State<StudentHistorialScreen> createState() => _StudentHistorialScreenState();
}

class _StudentHistorialScreenState extends State<StudentHistorialScreen> {
  String _tipoSeleccionado = 'Todos';
  String _estadoSeleccionado = 'Todos';

  final List<Map<String, dynamic>> _todasLasSolicitudes = const [
    {
      "tipo": "Beca Académica",
      "fecha": "15 Nov 2025",
      "estado": "Pendiente",
      "color": Colors.orange,
    },
    {
      "tipo": "Cita Psicológica",
      "fecha": "10 Nov 2025",
      "estado": "Aprobada",
      "color": Colors.green,
    },
    {
      "tipo": "Certificado",
      "fecha": "05 Nov 2025",
      "estado": "En revisión",
      "color": Colors.blue,
    },
  ];

  List<Map<String, dynamic>> get _solicitudesFiltradas {
    return _todasLasSolicitudes.where((s) {
      final coincideTipo =
          _tipoSeleccionado == 'Todos' || s['tipo'] == _tipoSeleccionado;
      final coincideEstado =
          _estadoSeleccionado == 'Todos' || s['estado'] == _estadoSeleccionado;

      return coincideTipo && coincideEstado;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFiltros(),

        Expanded(
          child: _solicitudesFiltradas.isEmpty
              ? const Center(
                  child: Text(
                    "No hay solicitudes con esos filtros",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _solicitudesFiltradas.length,
                  itemBuilder: (context, index) {
                    final solicitud = _solicitudesFiltradas[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.description_outlined,
                          color: solicitud["color"],
                          size: 32,
                        ),
                        title: Text(
                          solicitud["tipo"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("Enviada: ${solicitud["fecha"]}"),
                        trailing: Chip(
                          label: Text(
                            solicitud["estado"],
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: solicitud["color"],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: "Tipo",
                border: OutlineInputBorder(),
              ),
              items: const [
                'Todos',
                'Beca Académica',
                'Cita Psicológica',
                'Certificado',
              ]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _tipoSeleccionado = value!);
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: "Estado",
                border: OutlineInputBorder(),
              ),
              items: const [
                'Todos',
                'Pendiente',
                'Aprobada',
                'En revisión',
              ]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _estadoSeleccionado = value!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
