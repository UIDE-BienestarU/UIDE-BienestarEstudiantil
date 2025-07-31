import SolicitudService from '../../business/services/SolicitudService.js';

class SolicitudController {
  static async createSolicitud(req, res) {
    try {
      if (req.user.rol !== 'estudiante') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los estudiantes pueden crear solicitudes',
          details: [],
        });
      }
      const solicitud = await SolicitudService.createSolicitud(req.user.userId, req.body);
      res.status(201).json({
        message: 'Solicitud creada exitosamente',
        data: solicitud,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al crear solicitud',
        code: 'SOLICITUD_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async getSolicitudes(req, res) {
    try {
      const solicitudes = await SolicitudService.getSolicitudes(req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Solicitudes obtenidas exitosamente',
        data: solicitudes,
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async getSolicitudById(req, res) {
    try {
      const solicitud = await SolicitudService.getSolicitudById(req.params.id, req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Solicitud obtenida exitosamente',
        data: solicitud,
      });
    } catch (error) {
      res.status(404).json({
        error: 'Solicitud no encontrada',
        code: 'NOT_FOUND',
        message: error.message,
        details: [],
      });
    }
  }

  static async getNotificaciones(req, res) {
    try {
      const notificaciones = await SolicitudService.getNotificaciones(req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Notificaciones obtenidas exitosamente',
        data: notificaciones,
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async updateSolicitud(req, res) {
    try {
      if (req.user.rol !== 'administrador' && req.user.rol !== 'estudiante') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo administradores y estudiantes pueden actualizar solicitudes',
          details: [],
        });
      }
      const solicitud = await SolicitudService.updateSolicitud(req.params.id, req.user.userId, req.body, req.user.rol);
      res.status(200).json({
        message: 'Solicitud actualizada exitosamente',
        data: solicitud,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al actualizar solicitud',
        code: 'SOLICITUD_UPDATE_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async deleteSolicitud(req, res) {
    try {
      await SolicitudService.deleteSolicitud(req.params.id, req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Solicitud eliminada exitosamente',
        data: null,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al eliminar solicitud',
        code: 'SOLICITUD_DELETE_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default SolicitudController;
