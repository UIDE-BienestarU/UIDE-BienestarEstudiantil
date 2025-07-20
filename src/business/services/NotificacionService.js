import Notificacion from '../../data/models/Notificacion.js';
import Solicitud from '../../data/models/Solicitud.js';
import Estudiante from '../../data/models/Estudiante.js';

class NotificacionService {
  static async getNotificaciones(userId, rol) {
    if (rol === 'administrador') {
      return await Notificacion.findAll({
        include: [{ model: Solicitud, include: [Estudiante] }],
      });
    }
    return await Notificacion.findAll({
      include: [{
        model: Solicitud,
        where: { estudiante_id: userId },
      }],
    });
  }

  static async markAsRead(notificacionId, userId, rol) {
    const notificacion = await Notificacion.findByPk(notificacionId, {
      include: [Solicitud],
    });
    if (!notificacion) {
      throw new Error('Notificación no encontrada');
    }
    if (rol !== 'administrador' && notificacion.Solicitud.estudiante_id !== userId) {
      throw new Error('No tienes permiso para marcar esta notificación');
    }
    await notificacion.update({ leido: true });
    return notificacion;
  }
}

export default NotificacionService;