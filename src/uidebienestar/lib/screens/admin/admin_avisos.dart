import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/aviso.dart';
import '../../providers/avisos_provider.dart';

class AdminAvisosScreen extends StatelessWidget {
  const AdminAvisosScreen({super.key});

  void _abrirFormulario(
    BuildContext context, {
    Aviso? aviso,
    int? index,
  }) {
    final tituloCtrl = TextEditingController(text: aviso?.titulo);
    final contenidoCtrl = TextEditingController(text: aviso?.contenido);
    String? imagen = aviso?.imagen;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aviso == null ? 'Nuevo aviso' : 'Editar aviso'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contenidoCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Agregar imagen'),
                onPressed: () async {
                  final img = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (img != null) imagen = img.path;
                },
              ),
              if (imagen != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(File(imagen!), height: 120),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevoAviso = Aviso(
                titulo: tituloCtrl.text.trim(),
                contenido: contenidoCtrl.text.trim(),
                imagen: imagen,
                activo: aviso?.activo ?? true,
                fechaCreacion: aviso?.fechaCreacion ?? DateTime.now(),
              );

              final provider =
                  context.read<AvisosProvider>();

              if (aviso == null) {
                provider.agregarAviso(nuevoAviso);
              } else {
                provider.editarAviso(index!, nuevoAviso);
              }

              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avisos = context.watch<AvisosProvider>().avisos;

    return Scaffold(
      appBar: AppBar(title: const Text('Administrar avisos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        child: const Icon(Icons.add),
      ),
      body: avisos.isEmpty
          ? const Center(child: Text('No hay avisos'))
          : ListView.builder(
              itemCount: avisos.length,
              itemBuilder: (_, i) {
                final aviso = avisos[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: aviso.imagen != null
                        ? Image.file(File(aviso.imagen!), width: 50)
                        : const Icon(Icons.campaign),
                    title: Text(aviso.titulo),
                    subtitle: Text(
                      aviso.contenido,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Switch(
                      value: aviso.activo,
                      onChanged: (_) => context
                          .read<AvisosProvider>()
                          .toggleActivo(i),
                    ),
                    onTap: () =>
                        _abrirFormulario(context, aviso: aviso, index: i),
                  ),
                );
              },
            ),
    );
  }
}
