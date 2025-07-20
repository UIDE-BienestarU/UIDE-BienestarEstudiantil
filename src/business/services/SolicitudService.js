import Solicitud from '../../data/models/Solicitud.js';
import Documento from '../../data/models/Documento.js';
import HistorialEstado from '../../data/models/HistorialEstado.js';
import Notificacion from '../../data/models/Notificacion.js';

class SolicitudService {
  static async createSolicitud(userId, solicitudData) {
    const transaction = await Solicitud.sequelize.transaction();
    try {
      const solicitud = await Solicitud.create({
        estudiante_id: userId,
        subtipo_id: solicitudData.subtipo_id,
        fecha_solicitud: new Date(),
        estado_actual: 'Pendiente',
        nivel_urgencia: solicitudData.nivel_urgencia,
        observaciones: solicitudData.observaciones,
      }, { transaction });

      if (solicitudData.documentos) {
        for (const doc of solicitudData.documentos) {
          await Documento.create({
            solicitud_id: solicitud.id,
            nombre_documento: doc.nombre_documento,
            url_archivo: doc.url_archivo,
            obligatorio: doc.obligatorio,
          }, { transaction });
        }
      }

      await Notificacion.create({
        solicitud_id: solicitud.id,
        mensaje: 'Solicitud registrada exitosamente',
        tipo: 'Alerta',
      }, { transaction });

      await transaction.commit();
      return solicitud;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  static async getSolicitudes(userId, rol) {
    if (rol === 'administrador') {
      return await Solicitud.findAll({ include: ['Estudiante', 'SubtipoSolicitud'] });
    }
    return await Solicitud.findAll({
      where: { estudiante_id: userId },
      include: ['SubtipoSolicitud'],
    });
  }

  static async updateSolicitud(solicitudId, adminId, updateData) {
    const transaction = await Solicitud.sequelize.transaction();
    try {
      const solicitud = await Solicitud.findByPk(solicitudId);
      if (!solicitud) {
        throw new Error('Solicitud no encontrada');
      }

      await solicitud.update({
        estado_actual: updateData.estado,
        observaciones: updateData.observaciones,
      }, { transaction });

      await HistorialEstado.create({
        solicitud_id: solicitudId,
        admin_id: adminId,
        estado: updateData.estado,
        comentario: updateData.comentario,
      }, { transaction });

      await Notificacion.create({
        solicitud_id: solicitudId,
        mensaje: `Estado actualizado a ${updateData.estado}`,
        tipo: 'Actualización',
      }, { transaction });

      await transaction.commit();
      return solicitud;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  static async deleteSolicitud(solicitudId, userId, rol) {
    const solicitud = await Solicitud.findByPk(solicitudId);
    if (!solicitud) {
      throw new Error('Solicitud no encontrada');
    }
    if (rol !== 'administrador' && solicitud.estudiante_id !== userId) {
      throw new Error('No tienes permiso para eliminar esta solicitud');
    }
    await solicitud.destroy();
    await Notificacion.create({
      solicitud_id: solicitudId,
      mensaje: 'Solicitud eliminada',
      tipo: 'Rechazo',
    });
  }
}

export default SolicitudService;