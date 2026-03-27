import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../models/aviso.dart';

class AdminHomeScreen extends StatelessWidget {
  final void Function(CategoriaAviso categoria) onAccesoAvisos;

  /// ✅ Opcional: si tu AdminDashboard tiene tabs, pasa una función para ir directo
  /// a "Solicitudes" u otro módulo.
  final VoidCallback? onAccesoSolicitudes;

  /// ✅ Opcional: acción rápida “crear” (si quieres abrir pantalla modal/crear).
  /// Si no lo usas, igual funciona.
  final VoidCallback? onCrearComunicado;
  final VoidCallback? onCrearObjetoPerdido;

  const AdminHomeScreen({
    super.key,
    required this.onAccesoAvisos,
    this.onAccesoSolicitudes,
    this.onCrearComunicado,
    this.onCrearObjetoPerdido,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text("Bienestar Universitario"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerAdmin(context),
            const SizedBox(height: 16),

            _cardInfo(
              context,
              icon: Icons.tips_and_updates_rounded,
              title: "Panel de administración",
              text:
                  "Gestiona avisos, objetos perdidos y solicitudes desde un solo lugar.",
            ),
            const SizedBox(height: 10),

            _cardInfo(
              context,
              icon: Icons.language_rounded,
              title: "Tip",
              text:
                  "En la versión Web hay funciones adicionales para reportes.",
            ),
            const SizedBox(height: 18),

            _sectionTitle("Acciones rápidas"),
            const SizedBox(height: 10),

            // ✅ Acciones rápidas (crear directo)
            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    context,
                    icon: Icons.campaign_rounded,
                    title: "Nuevo comunicado",
                    subtitle: "Publica una noticia",
                    onTap: onCrearComunicado ??
                        () => onAccesoAvisos(CategoriaAviso.comunicado),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickAction(
                    context,
                    icon: Icons.backpack_rounded,
                    title: "Nuevo objeto",
                    subtitle: "Reportar encontrado",
                    onTap: onCrearObjetoPerdido ??
                        () => onAccesoAvisos(CategoriaAviso.objetosPerdidos),
                  ),
                ),
              ],
            ),

            if (onAccesoSolicitudes != null) ...[
              const SizedBox(height: 12),
              _wideAction(
                context,
                icon: Icons.assignment_rounded,
                title: "Ir a solicitudes",
                subtitle: "Revisar y actualizar estados",
                onTap: onAccesoSolicitudes!,
              ),
            ],

            const SizedBox(height: 22),

            _sectionTitle("Accesos rápidos – Avisos"),
            const SizedBox(height: 10),

            _accessTile(
              context,
              icon: Icons.backpack_rounded,
              title: "Objetos perdidos",
              subtitle: "Publicar • editar estado • ver comentarios",
              onTap: () => onAccesoAvisos(CategoriaAviso.objetosPerdidos),
            ),
            const SizedBox(height: 10),
            _accessTile(
              context,
              icon: Icons.campaign_rounded,
              title: "Avisos / Comunicados",
              subtitle: "Crear • activar/desactivar • eliminar",
              onTap: () => onAccesoAvisos(CategoriaAviso.comunicado),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI PIEZAS =====================

  Widget _headerAdmin(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            UIDEColors.azul.withOpacity(0.95),
            UIDEColors.azul.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hola, administrador",
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Gestiona contenido y solicitudes rápidamente.",
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: UIDEColors.conchevino,
      ),
    );
  }

  Widget _cardInfo(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UIDEColors.conchevino.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: UIDEColors.conchevino),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: UIDEColors.conchevino.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: UIDEColors.conchevino.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: UIDEColors.conchevino),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: UIDEColors.conchevino.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: UIDEColors.conchevino.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: UIDEColors.conchevino),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: UIDEColors.conchevino),
          ],
        ),
      ),
    );
  }

  Widget _accessTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: UIDEColors.conchevino.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: UIDEColors.conchevino.withOpacity(0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: UIDEColors.conchevino, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: UIDEColors.conchevino,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: UIDEColors.conchevino),
          ],
        ),
      ),
    );
  }
}
