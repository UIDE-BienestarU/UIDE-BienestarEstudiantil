import NotificacionService from '../../business/services/NotificacionService.js';

class NotificacionController {
  static async getNotificaciones(req, res) {
    try {
      const notificaciones = await NotificacionService.getNotificaciones(req.user.userId, req.user.rol);
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

  static async markAsRead(req, res) {
    try {
      const notificacion = await NotificacionService.markAsRead(req.params.id, req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Notificación marcada como leída',
        data: notificacion,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al marcar notificación',
        code: 'NOTIFICACION_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default NotificacionController;