import Solicitud from '../../data/models/Solicitud.js';
import Documento from '../../data/models/Documento.js';
import Notificacion from '../../data/models/Notificacion.js';
import Usuario from '../../data/models/Usuario.js';

class SolicitudService {
  static async createSolicitud(userId, data) {
    const t = await Solicitud.sequelize.transaction();
    try {
      const solicitud = await Solicitud.create({
        estudiante_id: userId,
        subtipo_id: data.subtipo_id,
        nivel_urgencia: data.nivel_urgencia || 'Normal',
        observaciones: data.observaciones,
      }, { transaction: t });

      if (data.documentos?.length > 0) {
        await Documento.bulkCreate(data.documentos.map(d => ({
          solicitud_id: solicitud.id,
          url_archivo: d.url_archivo,
          nombre_documento: d.nombre_documento || 'Documento',
          obligatorio: d.obligatorio ?? true
        })), { transaction: t });
      }

      const estudiante = await Usuario.findByPk(userId);
      await Notificacion.create({ usuario_id: userId, solicitud_id: solicitud.id, mensaje: `Solicitud #${solicitud.id} creada`, tipo: 'Confirmación' }, { transaction: t });
      await Notificacion.create({ mensaje: `Nueva solicitud de ${estudiante.nombre_completo}`, tipo: 'Alerta' }, { transaction: t });

      await t.commit();
      return solicitud;
    } catch (error) { await t.rollback(); throw error; }
  }

  static async getSolicitudes(userId, rol) {
    const where = rol === 'administrador' || rol === 'bienestar' ? {} : { estudiante_id: userId };
    return await Solicitud.findAll({
      where,
      include: [
        { model: Usuario, as: 'estudiante', attributes: ['nombre_completo', 'matricula'] },
        'subtipo',
        'documentos'
      ],
      order: [['createdAt', 'DESC']]
    });
  }

  static async updateEstado(id, estado, adminId, comentario = '') {
    const solicitud = await Solicitud.findByPk(id);
    if (!solicitud) throw new Error('Solicitud no encontrada');
    await solicitud.update({ estado_actual: estado, comentario });
    await Notificacion.create({
      usuario_id: solicitud.estudiante_id,
      solicitud_id: id,
      mensaje: `Tu solicitud fue ${estado.toLowerCase()}${comentario ? ': ' + comentario : ''}`,
      tipo: 'Actualización'
    });
    return solicitud;
  }
}
export default SolicitudService;