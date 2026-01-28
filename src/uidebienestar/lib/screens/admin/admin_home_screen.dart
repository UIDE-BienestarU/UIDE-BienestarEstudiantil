import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';
import '../../models/aviso.dart'; //IMPORTS

class AdminHomeScreen extends StatelessWidget {
  final void Function(CategoriaAviso categoria) onAccesoAvisos;

  const AdminHomeScreen({
    super.key,
    required this.onAccesoAvisos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienestar Universitario"),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _saludoAdmin(),
            const SizedBox(height: 13),
            _guiaTextoAdmin(),
            const SizedBox(height: 12),
            _AvisoTextoAdmin(),
            const SizedBox(height: 22),

            const Text(
              "Accesos rápidos – Avisos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: UIDEColors.conchevino,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _accesoRapido(
                    icon: Icons.backpack,
                    titulo: "Objetos perdidos",
                    onTap: () =>
                        onAccesoAvisos(CategoriaAviso.objetosPerdidos),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _accesoRapido(
                    icon: Icons.campaign,
                    titulo: "Avisos / Comunicados",
                    onTap: () =>
                        onAccesoAvisos(CategoriaAviso.comunicado),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }

  Widget _saludoAdmin() {
    return Card(
      color: UIDEColors.azul,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            "Hola, administrador",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
),

      ),
    );
  }

  Widget _guiaTextoAdmin() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "El desarrollo de esta aplicación te permitirá gestionar solicitudes y generar avisos para la comunidad universitaria de forma rápida y centralizada.",
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
  Widget _AvisoTextoAdmin() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          "Recuerda que en la versión Web puedes acceder a más funciones.",
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
      ),
    );
  }

  Widget _accesoRapido({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: UIDEColors.conchevino.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: UIDEColors.conchevino.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: UIDEColors.conchevino),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: UIDEColors.conchevino,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
