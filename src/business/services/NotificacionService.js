import Notificacion from '../../data/models/Notificacion.js';
import Usuario from '../../data/models/Usuario.js';

class NotificacionService {
  // Obtener notificaciones del usuario (o todas si es admin/bienestar)
  static async getByUser(userId, rol) {
    const where = (rol === 'administrador' || rol === 'bienestar') 
      ? {} 
      : { usuario_id: userId };
    
    return await Notificacion.findAll({ 
      where, 
      order: [['fecha_envio', 'DESC']] 
    });
  }

  // Obtener notificaciones por userId específico (usado en el controller)
  static async getNotificacionesByUserId(userId) {
    return await Notificacion.findAll({
      where: { usuario_id: userId },
      order: [['fecha_envio', 'DESC']],
    });
  }

  // Marcar como leída
  static async marcarLeida(id) {
    const n = await Notificacion.findByPk(id);
    if (n) {
      n.leido = true;
      await n.save();
    }
    return n;
  }

  // NUEVO: Marcar como leída con validación de permisos (usado en controller)
  static async markAsRead(id, userId, rol) {
    const notificacion = await Notificacion.findByPk(id);
    
    if (!notificacion) {
      throw new Error('Notificación no encontrada');
    }

    // Solo el dueño o admin/bienestar puede marcarla como leída
    if (rol !== 'administrador' && rol !== 'bienestar' && notificacion.usuario_id !== userId) {
      throw new Error('No tienes permiso para marcar esta notificación como leída');
    }

    notificacion.leido = true;
    await notificacion.save();
    return notificacion;
  }

  // NUEVO: Obtener el token FCM del usuario
  static async getUserFcmToken(userId) {
    const usuario = await Usuario.findByPk(userId, {
      attributes: ['fcm_token'], // Solo traemos el token para optimizar
    });

    return usuario?.fcm_token || null;
  }

  // NUEVO: Crear una nueva notificación en la base de datos (para historial)
  static async crearNotificacion({ usuario_id, titulo, mensaje, data = null }) {
    return await Notificacion.create({
      usuario_id,
      titulo,
      mensaje,
      leido: false,
      data: data ? JSON.stringify(data) : null, // Si envías data adicional
    });
  }
}

export default NotificacionService;