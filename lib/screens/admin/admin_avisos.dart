import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/uide_colors.dart';

import '../../models/aviso.dart';
import '../../providers/avisos_provider.dart';

class AdminAvisosScreen extends StatefulWidget {
  final CategoriaAviso? categoriaInicial;

  const AdminAvisosScreen({
    super.key,
    this.categoriaInicial,
  });

  @override
  State<AdminAvisosScreen> createState() => _AdminAvisosScreenState();
}

class _AdminAvisosScreenState extends State<AdminAvisosScreen> {
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  CategoriaAviso _categoria = CategoriaAviso.comunicado;
  List<String> _imagenesPaths = [];
  Aviso? _avisoEditando;
  bool _mostrarActivos = true;

  @override
  void initState() {
    super.initState();

    if (widget.categoriaInicial != null) {
      _categoria = widget.categoriaInicial!;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  void _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenesPaths.add(pickedFile.path);
      });
    }
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenesPaths.removeAt(index);
    });
  }

  void _guardarAviso() {
    if (_tituloController.text.trim().isEmpty || _contenidoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y contenido son obligatorios')),
      );
      return;
    }

    final nuevoAviso = Aviso(
      id: _avisoEditando?.id ?? DateTime.now().toString(),
      titulo: _tituloController.text.trim(),
      contenido: _contenidoController.text.trim(),
      categoria: _categoria,
      imagen: _imagenesPaths.isNotEmpty ? _imagenesPaths.join(',') : null,
      activo: _avisoEditando?.activo ?? true,
      fechaCreacion: _avisoEditando?.fechaCreacion ?? DateTime.now(),
      comentarios: _avisoEditando?.comentarios ?? [],
    );

    final provider = context.read<AvisosProvider>();
    if (_avisoEditando == null) {
      provider.agregarAviso(nuevoAviso);
    } else {
      provider.editarAviso(_avisoEditando!.id, nuevoAviso);
    }

    // Limpiar formulario
    _tituloController.clear();
    _contenidoController.clear();
    setState(() {
      _categoria = widget.categoriaInicial ?? CategoriaAviso.comunicado;
      _imagenesPaths.clear();
      _avisoEditando = null;
    });
  }

  void _editarAviso(Aviso aviso) {
    setState(() {
      _avisoEditando = aviso;
      _tituloController.text = aviso.titulo;
      _contenidoController.text = aviso.contenido;
      _categoria = aviso.categoria;
      _imagenesPaths = aviso.imagen != null 
          ? aviso.imagen!.split(',').where((path) => path.isNotEmpty).toList()
          : [];
    });
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar aviso", style: TextStyle(fontWeight: FontWeight.bold, color: UIDEColors.conchevino)),
        content: const Text("¿Está seguro de eliminar este aviso? Esta acción no se puede deshacer.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<AvisosProvider>().eliminarAviso(id);
              Navigator.pop(ctx);
            },
            child: const Text("Eliminar"),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avisos = context.watch<AvisosProvider>().avisos;
    final avisosFiltrados = avisos
    .where((a) => a.activo == _mostrarActivos)
    .toList();


    return Scaffold(
            appBar: AppBar(
        title: Text(
          widget.categoriaInicial != null
              ? "Nuevo ${widget.categoriaInicial == CategoriaAviso.objetosPerdidos ? 'Objeto perdido' : 'Comunicado'}"
              : "Bienestar Universitario",
        ),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Formulario compacto arriba
            Card(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _avisoEditando == null 
                          ? (widget.categoriaInicial != null 
                              ? "Nuevo ${widget.categoriaInicial == CategoriaAviso.objetosPerdidos ? 'Objeto perdido' : 'Comunicado'}"
                              : "Nuevo aviso")
                          : "Editar aviso",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UIDEColors.conchevino),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: "Título",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _contenidoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Contenido",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<CategoriaAviso>(
                      value: _categoria,
                      decoration: InputDecoration(
                        labelText: "Categoría",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: CategoriaAviso.comunicado, child: Text("Comunicado")),
                        DropdownMenuItem(value: CategoriaAviso.objetosPerdidos, child: Text("Objeto perdido")),
                      ],
                      onChanged: (value) => value != null ? setState(() => _categoria = value) : null,
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate, size: 20),
                      label: Text("${_imagenesPaths.length} imagen${_imagenesPaths.length != 1 ? 'es' : ''} • Agregar", style: const TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: UIDEColors.conchevino,
                        side: BorderSide(color: UIDEColors.conchevino),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _seleccionarImagen,
                    ),

                    // Lista de imágenes seleccionadas
                    if (_imagenesPaths.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text("Imágenes seleccionadas:", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imagenesPaths.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_imagenesPaths[index]),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _eliminarImagen(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIDEColors.conchevino,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _guardarAviso,
                        child: Text(
                          _avisoEditando == null ? "Crear aviso" : "Guardar cambios",
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de avisos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                "Avisos creados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UIDEColors.conchevino),
              ),
            ),
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Activos"),
                  selected: _mostrarActivos,
                  selectedColor: UIDEColors.conchevino.withOpacity(0.15),
                  onSelected: (_) {
                    setState(() {
                      _mostrarActivos = true;
                    });
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Inactivos"),
                  selected: !_mostrarActivos,
                  selectedColor: Colors.grey.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() {
                      _mostrarActivos = false;
                    });
                  },
                ),
              ],
            ),
          ),


            avisosFiltrados.isEmpty

                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No hay avisos aún', style: TextStyle(color: Colors.grey))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: avisosFiltrados.length,
                    itemBuilder: (context, index) {
                      final a = avisosFiltrados[index];

                      final imagenes = a.imagen != null ? a.imagen!.split(',') : [];
                      
                      return GestureDetector(
                        onTap: () => _editarAviso(a),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                if (imagenes.isNotEmpty && imagenes.first.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          File(imagenes.first),
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: UIDEColors.conchevino.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.image_not_supported, color: UIDEColors.conchevino, size: 32),
                                            ),
                                        ),
                                        if (imagenes.length > 1)
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "+${imagenes.length - 1}",
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: UIDEColors.conchevino.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image_not_supported, color: UIDEColors.conchevino, size: 32),
                                  ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.titulo,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        a.categoria == CategoriaAviso.comunicado ? "Comunicado" : "Objeto perdido",
                                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Creado: ${a.fechaCreacion.toString().split(' ')[0]}",
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                      if (imagenes.length > 0)
                                        Text(
                                          "${imagenes.length} imagen${imagenes.length != 1 ? 'es' : ''}",
                                          style: TextStyle(color: UIDEColors.conchevino, fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                    ],
                                  ),
                                ),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: a.activo,
                                      activeColor: UIDEColors.conchevino,
                                      onChanged: (_) => context.read<AvisosProvider>().toggleActivo(a.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                      onPressed: () => _confirmarEliminar(a.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
