import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/uide_colors.dart';

import '../../models/aviso.dart';
import '../../providers/avisos_provider.dart';

class AdminAvisosScreen extends StatelessWidget {
  const AdminAvisosScreen({super.key});

  void _formulario(
    BuildContext context, {
    Aviso? aviso,
  }) {
    final titulo = TextEditingController(text: aviso?.titulo);
    final contenido = TextEditingController(text: aviso?.contenido);
    CategoriaAviso categoria =
        aviso?.categoria ?? CategoriaAviso.comunicado;
    String? imagen = aviso?.imagen;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aviso == null ? "Nuevo aviso" : "Editar aviso"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titulo,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contenido,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Contenido"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoriaAviso>(
                value: categoria,
                items: const [
                  DropdownMenuItem(
                    value: CategoriaAviso.comunicado,
                    child: Text("Comunicado"),
                  ),
                  DropdownMenuItem(
                    value: CategoriaAviso.objetosPerdidos,
                    child: Text("Objeto perdido"),
                  ),
                ],
                onChanged: (v) => categoria = v!,
                decoration: const InputDecoration(labelText: "Categoría"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Imagen"),
                onPressed: () async {
                  final img = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (img != null) imagen = img.path;
                },
              ),
              if (imagen != null) ...[
                const SizedBox(height: 12),
                Image.file(
                  File(imagen!),
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevo = Aviso(
                id: aviso?.id ?? DateTime.now().toString(),
                titulo: titulo.text.trim(),
                contenido: contenido.text.trim(),
                categoria: categoria,
                imagen: imagen,
                activo: aviso?.activo ?? true,
                fechaCreacion:
                    aviso?.fechaCreacion ?? DateTime.now(),
                comentarios: aviso?.comentarios ?? [],
              );

              final p = context.read<AvisosProvider>();
              aviso == null
                  ? p.agregarAviso(nuevo)
                  : p.editarAviso(aviso.id, nuevo);

              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avisos = context.watch<AvisosProvider>().avisos;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienestar Universitario"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formulario(context),
        child: const Icon(Icons.add),
      ),
      body: avisos.isEmpty
          ? const Center(child: Text('No hay avisos aún'))
          : ListView.builder(
              itemCount: avisos.length,
              itemBuilder: (_, i) {
                final a = avisos[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(a.titulo),
                    subtitle: Text(a.categoria.name),
                    trailing: Switch(
                      value: a.activo,
                      onChanged: (_) =>
                          context.read<AvisosProvider>().toggleActivo(a.id),
                    ),
                    onTap: () => _formulario(context, aviso: a),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Eliminar aviso"),
                          content: const Text(
                              "¿Seguro que deseas eliminar este aviso?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                context
                                    .read<AvisosProvider>()
                                    .eliminarAviso(a.id);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}