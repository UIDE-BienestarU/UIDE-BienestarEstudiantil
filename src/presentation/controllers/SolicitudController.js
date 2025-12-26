import SolicitudService from '../../business/services/SolicitudService.js';

class SolicitudController {
  // Crear solicitud
  static async createSolicitud(req, res) {
    try {
      if (req.user.rol !== 'estudiante') {
        return res.status(403).json({ error: 'Solo estudiantes', code: 'FORBIDDEN' });
      }
      const solicitud = await SolicitudService.createSolicitud(req.user.userId, req.body);
      res.status(201).json({ message: 'Solicitud creada', data: solicitud });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }

  // Listar solicitudes
  static async getSolicitudes(req, res) {
    try {
      const solicitudes = await SolicitudService.getSolicitudes(req.user.userId, req.user.rol);
      res.status(200).json({ message: 'OK', data: solicitudes });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Actualizar estado de solicitud
  static async updateEstado(req, res) {
    try {
      if (!['administrador', 'bienestar'].includes(req.user.rol)) {
        return res.status(403).json({ error: 'No autorizado' });
      }
      const { estado_actual, comentario } = req.body;
      const solicitud = await SolicitudService.updateEstado(req.params.id, estado_actual, req.user.userId, comentario);
      res.status(200).json({ message: 'Estado actualizado', data: solicitud });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }
}

export default SolicitudController;