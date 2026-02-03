import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
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
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _itemNoticia(context, a),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  // ================= SALUDO =================
  Widget _saludo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIDEColors.azul.withOpacity(0.95),
            UIDEColors.azul.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola, Juan Fuentes!",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Es un buen día para seguir aprendiendo.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
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
        const SizedBox(height: 6),

        Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 14,
            children: [
              _accionItem(context, Icons.health_and_safety_rounded,
                  color: Colors.green,
                  textoCorto: "Salud",
                  tipoReal: "Salud y bienestar físico"),
              _accionItem(context, Icons.psychology_rounded,
                  color: Colors.purple,
                  textoCorto: "Psicológico",
                  tipoReal: "Apoyo psicológico y psicopedagógico"),
              _accionItem(context, Icons.school_rounded,
                  color: Colors.orange,
                  textoCorto: "Becas",
                  tipoReal: "Becas y ayudas financieras"),
              _accionItem(context, Icons.admin_panel_settings_rounded,
                  color: Colors.blue,
                  textoCorto: "Académico",
                  tipoReal: "Gestión académica y administrativa"),
              _accionItem(context, Icons.sports_soccer_rounded,
                  color: Colors.redAccent,
                  textoCorto: "Deportes",
                  tipoReal: "Deportes y cultura"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accionItem(
    BuildContext context,
    IconData icon, {
    required Color color,
    required String textoCorto,
    required String tipoReal,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboard(
              initialIndex: 2,
              tipoInicial: tipoReal,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color:color),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              textoCorto,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= OBJETOS PERDIDOS =================
  Widget _itemObjetoPerdido(BuildContext context, Aviso aviso) {
    final imagenes = _imagenes(aviso);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          imagenes.isNotEmpty
              ? SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: imagenes.length,
                    itemBuilder: (_, i) => Image.file(
                      File(imagenes[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.backpack_rounded,
                      size: 64, color: Colors.grey),
                ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7)
                  ],
                ),
              ),
              child: Text(
                aviso.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= NOTICIAS =================
  Widget _filaNoticias() => Text(
        "Noticias",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: UIDEColors.conchevino,
        ),
      );

  Widget _itemNoticia(BuildContext context, Aviso aviso) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(width: 4, color: UIDEColors.conchevino)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(aviso.titulo,
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(
          aviso.contenido,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 13.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: UIDEColors.conchevino,
          ),
        ),
      );

  Widget _vacio(String texto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            texto,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
        ),
      );

  List<String> _imagenes(Aviso aviso) {
    if (aviso.imagen == null) return [];
    return aviso.imagen!
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }
}
