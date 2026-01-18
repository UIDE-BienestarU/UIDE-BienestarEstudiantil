import NotificacionService from '../../business/services/NotificacionService.js';
import admin from '../../config/firebase.js';

class NotificacionController {
  // Obtener notificaciones del usuario autenticado
  static async getNotificaciones(req, res) {
    try {
      const notificaciones = await NotificacionService.getByUser(req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Notificaciones obtenidas exitosamente',
        data: notificaciones,
      });
    } catch (error) {
      console.error('Error obteniendo notificaciones:', error);
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  // Obtener notificaciones de un usuario específico (solo admin)
  static async getNotificacionesByUserId(req, res) {
    try {
      const { userId } = req.params;
      const parsedUserId = parseInt(userId, 10);

      if (isNaN(parsedUserId)) {
        return res.status(400).json({
          error: 'userId inválido',
          code: 'BAD_REQUEST',
          message: 'userId debe ser un número entero',
          details: [],
        });
      }

      if (req.user.rol !== 'administrador' && req.user.userId !== parsedUserId) {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'No tienes permiso para ver las notificaciones de este usuario',
          details: [],
        });
      }

      const notificaciones = await NotificacionService.getNotificacionesByUserId(parsedUserId);
      res.status(200).json({
        message: 'Notificaciones obtenidas exitosamente',
        data: notificaciones,
      });
    } catch (error) {
      console.error('Error obteniendo notificaciones por userId:', error);
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
      const notificacion = await NotificacionService.markAsRead(
        req.params.id,
        req.user.userId,
        req.user.rol
      );

      res.status(200).json({
        message: 'Notificación marcada como leída',
        data: notificacion,
      });
    } catch (error) {
      console.error('Error marcando notificación como leída:', error);
      res.status(422).json({
        error: 'Error al marcar notificación',
        code: 'NOTIFICACION_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  // Enviar notificación push con Firebase (solo admin)
  static async enviarNotificacion(req, res) {
    try {
      const { userId, title, body, data = {} } = req.body;

      // Validación básica
      if (!userId || !title || !body) {
        return res.status(400).json({
          error: 'Datos incompletos',
          code: 'BAD_REQUEST',
          message: 'userId, title y body son requeridos',
          details: [],
        });
      }

      // Solo administradores pueden enviar
      if (req.user.rol !== 'administrador') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los administradores pueden enviar notificaciones',
          details: [],
        });
      }

      // Obtener token FCM
      const userToken = await NotificacionService.getUserFcmToken(userId);

      if (!userToken) {
        return res.status(404).json({
          error: 'Token no encontrado',
          code: 'TOKEN_NOT_FOUND',
          message: 'El usuario no tiene un token de dispositivo registrado',
          details: [],
        });
      }

      // Convertir TODOS los valores de data a string (obligatorio para FCM)
      const safeData = {};
      for (const [key, value] of Object.entries(data)) {
        safeData[key] = value != null ? String(value) : '';
      }

      // Construir mensaje
      const message = {
        token: userToken,
        notification: {
          title: String(title).trim(),
          body: String(body).trim(),
        },
        data: safeData,
      };

      console.log('Enviando push con data:', safeData); // debug

      // Enviar con Firebase
      let firebaseResponse = null;
      try {
        firebaseResponse = await admin.messaging().send(message);
      } catch (firebaseError) {
        console.error('Error enviando push:', firebaseError);

        if (firebaseError.code === 'messaging/registration-token-not-registered') {
          return res.status(410).json({
            error: 'Token inválido',
            code: 'INVALID_TOKEN',
            message: 'El token del dispositivo ya no es válido',
            details: [],
          });
        }

        // No bloqueamos la respuesta por error de push (continuamos guardando en BD)
      }

      // Guardar siempre en historial (incluso si push falla)
      await NotificacionService.crearNotificacion({
        usuario_id: userId,
        titulo: String(title).trim(),
        mensaje: String(body).trim(),
        data: Object.keys(safeData).length > 0 ? safeData : null,
        leido: false,
      });

      res.status(200).json({
        message: 'Notificación enviada exitosamente',
        data: {
          firebaseResponse: firebaseResponse || 'No enviado (posible token inválido)',
          destinatario: userId,
        },
      });
    } catch (error) {
      console.error('Error general enviando notificación:', error);
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