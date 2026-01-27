import Notificacion from '../../data/models/Notificacion.js';
import Usuario from '../../data/models/Usuario.js';
import { Op } from 'sequelize';
import { parsePagination } from '../utils/pagination.js';
import UserDevice from '../../data/models/UserDevice.js'; // (si implementaste devices)

class NotificacionService {
  // ✅ Lista paginada para el usuario autenticado
  static async listForUser(userId, query = {}) {
    const { page, limit, offset } = parsePagination(query);

    const where = { usuario_id: userId };

    // 🔹 NUEVO: unread=true → leido=false
    if (query.unread === 'true') where.leido = false;
    else {
      if (query.leido === 'true') where.leido = true;
      if (query.leido === 'false') where.leido = false;
    }

    if (query.tipo) where.tipo = query.tipo;

    if (query.fechaDesde || query.fechaHasta) {
      where.fecha_envio = {};
      if (query.fechaDesde) where.fecha_envio[Op.gte] = new Date(query.fechaDesde);
      if (query.fechaHasta) where.fecha_envio[Op.lte] = new Date(query.fechaHasta);
    }

    const { rows, count } = await Notificacion.findAndCountAll({
      where,
      order: [['fecha_envio', 'DESC']],
      limit,
      offset,
    });

    // ✅ parsear data JSON
    const parsed = rows.map(n => {
      const obj = n.toJSON();
      if (obj.data) {
        try { obj.data = JSON.parse(obj.data); } catch { /* ignore */ }
      }
      return obj;
    });

    return { rows: parsed, total: count, page, limit };
  }

  static async getNotificacionesByUserId(userId) {
    const rows = await Notificacion.findAll({
      where: { usuario_id: userId },
      order: [['fecha_envio', 'DESC']],
    });

    return rows.map(n => {
      const obj = n.toJSON();
      if (obj.data) {
        try { obj.data = JSON.parse(obj.data); } catch { }
      }
      return obj;
    });
  }

  static async markAsRead(id, userId, rol) {
    const notificacion = await Notificacion.findByPk(id);

    if (!notificacion) throw new Error('Notificación no encontrada');

    if (rol !== 'administrador' && rol !== 'bienestar' && notificacion.usuario_id !== userId) {
      throw new Error('No tienes permiso para marcar esta notificación como leída');
    }

    notificacion.leido = true;
    await notificacion.save();
    return notificacion;
  }

  // ✅ Compatibilidad: si aún usan Usuario.fcm_token
  static async getUserFcmTokenLegacy(userId) {
    const usuario = await Usuario.findByPk(userId, { attributes: ['fcm_token'] });
    return usuario?.fcm_token || null;
  }

  // ✅ NUEVO: tokens activos por multi-dispositivo
  static async getActiveDeviceTokens(userId) {
    if (!UserDevice) {
      const legacy = await this.getUserFcmTokenLegacy(userId);
      return legacy ? [legacy] : [];
    }

    const devices = await UserDevice.findAll({
      where: { userId, isActive: true },
      attributes: ['fcmToken'],
    });

    return devices.map(d => d.fcmToken);
  }

  // ✅ Crear notificación persistida
  static async crearNotificacion({ usuario_id, titulo = null, mensaje, tipo = 'Actualización', data = null, solicitud_id = null }) {
    return await Notificacion.create({
      usuario_id,
      solicitud_id,
      titulo,
      mensaje,
      tipo,
      leido: false,
      data: data ? JSON.stringify(data) : null,
    });
  }
}

export default NotificacionService;
