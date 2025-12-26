import NotificacionService from '../../business/services/NotificacionService.js';

class NotificacionController {
  // Obtener notificaciones
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

  // Obtener notificaciones por usuario
  static async getNotificacionesByUserId(req, res) {
    try {
      const { userId } = req.params;
      if (req.user.rol !== 'administrador' && req.user.userId !== parseInt(userId)) {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'No tienes permiso para ver las notificaciones de este usuario',
          details: [],
        });
      }
      const notificaciones = await NotificacionService.getNotificacionesByUserId(userId);
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

  // Marcar notificación como leída
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
