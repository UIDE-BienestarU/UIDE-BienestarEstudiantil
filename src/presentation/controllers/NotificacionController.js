import NotificacionService from '../../business/services/NotificacionService.js';
import admin from '../../config/firebase.js';

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

  // NUEVO: Enviar notificación push con Firebase
  static async enviarNotificacion(req, res) {
    try {
      const { userId, title, body, data } = req.body;

      // Validación básica
      if (!userId || !title || !body) {
        return res.status(400).json({
          error: 'Datos incompletos',
          code: 'BAD_REQUEST',
          message: 'userId, title y body son requeridos',
          details: [],
        });
      }

      // Solo administradores pueden enviar notificaciones (ajusta según tu lógica)
      if (req.user.rol !== 'administrador') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los administradores pueden enviar notificaciones',
          details: [],
        });
      }

      // Obtener el token FCM del usuario desde tu base de datos (MySQL)
      const userToken = await NotificacionService.getUserFcmToken(userId);

      if (!userToken) {
        return res.status(404).json({
          error: 'Token no encontrado',
          code: 'TOKEN_NOT_FOUND',
          message: 'El usuario no tiene un token de dispositivo registrado',
          details: [],
        });
      }

      // Construir mensaje para Firebase
      const message = {
        token: userToken,
        notification: {
          title,
          body,
        },
        data: data || {}, // Datos adicionales (opcional)
      };

      // Enviar con Firebase
      const response = await admin.messaging().send(message);

      // Opcional: guardar en la base de datos para historial
      await NotificacionService.crearNotificacion({
        userId,
        title,
        body,
        leida: false,
      });

      res.status(200).json({
        message: 'Notificación enviada exitosamente',
        data: {
          firebaseResponse: response,
          destinatario: userId,
        },
      });
    } catch (error) {
      console.error('Error enviando notificación push:', error);

      // Errores comunes de Firebase
      if (error.code === 'messaging/registration-token-not-registered') {
        // Podrías marcar el token como inválido en tu DB aquí
        return res.status(410).json({
          error: 'Token inválido',
          code: 'INVALID_TOKEN',
          message: 'El token del dispositivo ya no es válido',
        });
      }

      res.status(500).json({
        error: 'Error al enviar notificación',
        code: 'NOTIFICATION_SEND_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default NotificacionController;