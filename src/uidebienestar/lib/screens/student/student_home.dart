import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/avisos_provider.dart';
import '../../models/aviso.dart';
import '../../theme/uide_colors.dart';
import 'student_dashboard.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvisosProvider>();

    final objetosPerdidos =
        provider.avisosPorCategoria(CategoriaAviso.objetosPerdidos);
    final comunicados =
        provider.avisosPorCategoria(CategoriaAviso.comunicado);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _saludo(),
          const SizedBox(height: 24),

          _accionesRapidas(context),
          const SizedBox(height: 32),

          _titulo("Objetos perdidos"),
          objetosPerdidos.isEmpty
              ? _vacio("No hay objetos perdidos")
              : _itemObjetoPerdido(context, objetosPerdidos.first),

          const SizedBox(height: 32),

          _filaNoticias(),
          const SizedBox(height: 12),

          comunicados.isEmpty
              ? _vacio("No hay noticias")
              : Column(
                  children: comunicados
                      .map((a) => _itemNoticia(context, a))
                      .toList(),
                ),
        ],
      ),
    );
  }

  // ================= HELPER IMÁGENES MÚLTIPLES =================
  List<String> _imagenes(Aviso aviso) {
    if (aviso.imagen == null) return [];
    return aviso.imagen!
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  // ================= HELPER FORMATEAR FECHA =================
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) return "Hace un momento";
    if (diferencia.inMinutes < 60) return "Hace ${diferencia.inMinutes} min";
    if (diferencia.inHours < 24) return "Hace ${diferencia.inHours} h";
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  // ================= MÉTODO CONFIRMAR ELIMINAR =================
  void _confirmarEliminarComentario(
    BuildContext context,
    String avisoId,
    String comentarioId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar comentario"),
        content: const Text("¿Deseas eliminar este comentario?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 112, 22, 16),
            ),
            onPressed: () {
              context
                  .read<AvisosProvider>()
                  .eliminarComentario(avisoId, comentarioId);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= SALUDO =================
  Widget _saludo() {
    return Card(
      color: const Color.fromARGB(255, 13, 51, 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola, Juan Fuentes!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Es un buen día para seguir aprendiendo.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACCIONES RÁPIDAS =================
      Widget _accionesRapidas(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo("Acciones rápidas"),

          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: [
                _accionItem(
                  context,
                  Icons.health_and_safety,
                  textoCorto: "Salud",
                  tipoReal: "Salud y bienestar físico",
                ),
                _accionItem(
                  context,
                  Icons.psychology,
                  textoCorto: "Psicológico",
                  tipoReal: "Apoyo psicológico y psicopedagógico",
                ),
                _accionItem(
                  context,
                  Icons.school,
                  textoCorto: "Becas",
                  tipoReal: "Becas y ayudas financieras",
                ),
                _accionItem(
                  context,
                  Icons.admin_panel_settings,
                  textoCorto: "Académico",
                  tipoReal: "Gestión académica y administrativa",
                ),
                _accionItem(
                  context,
                  Icons.sports_soccer,
                  textoCorto: "Deportes",
                  tipoReal: "Deportes y cultura",
                ),
              ],
            ),
          ),
        ],
      );
    }


  Widget _accionItem(
  BuildContext context,
  IconData icon, {
  required String textoCorto,
  required String tipoReal,
}) {
  return SizedBox(
    width: 50,
    child: _accion(context, icon, textoCorto, tipoReal),
  );
}


  Widget _accion(
    BuildContext context,
    IconData icon,
    String textoCorto,
    String tipoReal,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboard(
              initialIndex: 2,
              tipoInicial: tipoReal
            ),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                const Color.fromARGB(255, 21, 30, 88).withOpacity(0.1),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 27, 35, 104),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            textoCorto,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ================= OBJETOS PERDIDOS =================
  Widget _itemObjetoPerdido(BuildContext context, Aviso aviso) {
    final imagenes = _imagenes(aviso);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IMÁGENES
          imagenes.isNotEmpty
              ? SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: imagenes.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _verImagenesFullscreen(
                          context,
                          imagenes,
                          inicial: index,
                        ),
                        child: Image.file(
                          File(imagenes[index]),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 220,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.backpack, size: 60),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  height: 220,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.backpack, size: 60),
                  ),
                ),

          // TEXTO SOBRE IMAGEN
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.6),
              child: Text(
                aviso.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // INDICADOR DE FOTOS
          if (imagenes.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${imagenes.length} fotos",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // ICONO COMENTARIOS
          Positioned(
            bottom: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.comment),
                color: UIDEColors.azul,
                onPressed: () => _modalComentarios(context, aviso),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MODAL COMENTARIOS MEJORADO =================
  void _modalComentarios(BuildContext context, Aviso aviso) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "Comentarios",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(height: 1),

              // LISTA DE COMENTARIOS CON PROVIDER WATCH
              Expanded(
                child: Builder(
                  builder: (context) {
                    final provider = context.watch<AvisosProvider>();
                    final avisoActualizado = provider.avisoPorId(aviso.id);
                    final comentarios = avisoActualizado.comentarios;

                    if (comentarios.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          "No hay comentarios aún",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: comentarios.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // AVATAR
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      UIDEColors.conchevino.withOpacity(0.1),
                                  child: Text(
                                    c.autorNombre.isNotEmpty
                                        ? c.autorNombre[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      color: UIDEColors.conchevino,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // COMENTARIO CON LONG PRESS
                                Expanded(
                                  child: GestureDetector(
                                    onLongPress: () {
                                      // TODO: Verificar si es el autor actual
                                      _confirmarEliminarComentario(
                                        context,
                                        aviso.id,
                                        c.id,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.autorNombre.isNotEmpty
                                                ? c.autorNombre
                                                : "Estudiante",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatearFecha(c.fecha),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(c.texto),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // CAJA COMENTAR
              Padding(
                padding: const EdgeInsets.all(12),
                child: _CajaComentario(aviso.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= resto de métodos sin cambios =================
  Widget _filaNoticias() {
    return const Text(
      "Noticias",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: UIDEColors.conchevino,
      ),
    );
  }

  Widget _itemNoticia(BuildContext context, Aviso aviso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(width: 4, color: UIDEColors.conchevino),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: ListTile(
        title: Text(
          aviso.titulo,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          aviso.contenido,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _detalle(context, aviso),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: UIDEColors.conchevino,
          ),
        ),
      );

  Widget _vacio(String texto) =>
      Text(texto, style: const TextStyle(color: Colors.grey));

  void _detalle(BuildContext context, Aviso aviso) {
    final imagenes = _imagenes(aviso);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imagenes.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: imagenes.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _verImagenesFullscreen(
                          context,
                          imagenes,
                          inicial: index,
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.file(
                            File(imagenes[index]),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (imagenes.length > 1)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Text(
                        "${imagenes.length} fotos",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aviso.titulo,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(aviso.contenido),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verImagenesFullscreen(
    BuildContext context,
    List<String> imagenes, {
    int inicial = 0,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: inicial),
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      File(imagenes[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                );
              },
            ),

            // BOTÓN CERRAR
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CAJA COMENTARIOS CORREGIDA =================
class _CajaComentario extends StatefulWidget {
  final String avisoId;

  const _CajaComentario(this.avisoId);

  @override
  State<_CajaComentario> createState() => _CajaComentarioState();
}

class _CajaComentarioState extends State<_CajaComentario> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(25), // Bordes MUY circulares
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Escribe un comentario...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22), // Bordes circulares
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: UIDEColors.azul,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: Colors.red.shade300,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                isDense: true,
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: UIDEColors.azul,
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;

                context.read<AvisosProvider>().agregarComentario(
                      widget.avisoId,
                      _controller.text.trim(),
                    );

                _controller.clear();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

}
