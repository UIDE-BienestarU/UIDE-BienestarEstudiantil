import NotificacionService from '../../business/services/NotificacionService.js';
import admin from '../../config/firebase.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';
import DeviceService from '../../business/services/DeviceService.js';

class NotificacionController {
  static async getNotificaciones(req, res) {
    const result = await NotificacionService.listForUser(req.user.userId, req.query);
    return ok(res, {
      message: 'Notificaciones',
      data: result.rows,
      meta: { page: result.page, limit: result.limit, total: result.total }
    });
  }

  static async getNotificacionesByUserId(req, res) {
    const { userId } = req.params;
    const parsedUserId = parseInt(userId, 10);
    if (isNaN(parsedUserId)) throw new ApiError(400, 'BAD_REQUEST', 'userId debe ser un número entero');

    if (req.user.rol !== 'administrador' && req.user.rol !== 'bienestar' && req.user.userId !== parsedUserId) {
      throw new ApiError(403, 'FORBIDDEN', 'No tienes permiso para ver las notificaciones de este usuario');
    }

    const notificaciones = await NotificacionService.getNotificacionesByUserId(parsedUserId);
    return ok(res, { message: 'Notificaciones', data: notificaciones });
  }

  static async markAsRead(req, res) {
    const notificacion = await NotificacionService.markAsRead(req.params.id, req.user.userId, req.user.rol);
    return ok(res, { message: 'Notificación marcada como leída', data: notificacion });
  }

  // ✅ Enviar push + guardar en BD (ADMIN)
  static async enviarNotificacion(req, res) {
    const { userId, title, body, data = {}, tipo = 'Actualización' } = req.body;

    if (!userId || !title || !body) {
      throw new ApiError(400, 'BAD_REQUEST', 'userId, title y body son requeridos');
    }

    if (req.user.rol !== 'administrador') {
      throw new ApiError(403, 'FORBIDDEN', 'Solo administradores pueden enviar notificaciones');
    }

    // FCM data debe ser string
    const safeData = {};
    for (const [k, v] of Object.entries(data)) safeData[k] = v != null ? String(v) : '';

    const numericUserId = Number(userId);

    const tokensMap = await DeviceService.getActiveTokensByUserIds([numericUserId]);
    const tokens = tokensMap.get(numericUserId) || [];

    if (tokens.length === 0) {
      return res.status(404).json({
        error: 'Token no encontrado',
        code: 'TOKEN_NOT_FOUND',
        message: 'El usuario no tiene tokens activos registrados',
        details: [],
      });
    }

    const results = [];
    for (const token of tokens) {
      const message = {
        token,
        notification: { title: String(title).trim(), body: String(body).trim() },
        data: safeData,
      };

      try {
        const firebaseResponse = await admin.messaging().send(message);
        results.push({ token, ok: true, firebaseResponse });
      } catch (firebaseError) {
        console.error('Error enviando push:', firebaseError);

        // Si token inválido, lo desactivamos
        if (firebaseError.code === 'messaging/registration-token-not-registered') {
          await DeviceService.disableToken(token);
        }
        results.push({ token, ok: false, error: firebaseError.message });
      }
    }

    // Guardar siempre en BD
    await NotificacionService.crearNotificacion({
      usuario_id: numericUserId,
      titulo: String(title).trim(),
      mensaje: String(body).trim(),
      tipo,
      data: Object.keys(safeData).length ? safeData : null,
    });

    return ok(res, {
      message: 'Notificación procesada',
      data: { destinatario: numericUserId, pushes: results, tokensCount: tokens.length }
    });
  }
}

export default NotificacionController;
