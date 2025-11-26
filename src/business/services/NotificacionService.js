import Notificacion from '../../data/models/Notificacion.js';

class NotificacionService {
  static async getByUser(userId, rol) {
    const where = (rol === 'administrador' || rol === 'bienestar') ? {} : { usuario_id: userId };
    return await Notificacion.findAll({ where, order: [['createdAt', 'DESC']] });
  }

  static async marcarLeida(id) {
    const n = await Notificacion.findByPk(id);
    if (n) { n.leido = true; await n.save(); }
    return n;
  }
}
export default NotificacionService;