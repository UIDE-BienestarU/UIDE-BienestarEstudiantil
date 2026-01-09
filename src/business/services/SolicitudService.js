// src/business/services/SolicitudService.js

import Solicitud from '../../data/models/Solicitud.js';
import Documento from '../../data/models/Documento.js';

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
        await Documento.bulkCreate(
          data.documentos.map(d => ({
            solicitud_id: solicitud.id,
            url_archivo: d.url_archivo,
            nombre_documento: d.nombre_documento || 'Documento',
            obligatorio: d.obligatorio ?? true,
          })),
          { transaction: t }
        );
      }

      await t.commit();
      return solicitud;
    } catch (error) {
      await t.rollback();
      throw error;
    }
  }

  static async getSolicitudes(userId, rol) {
    const where = (rol === 'administrador' || rol === 'bienestar') 
      ? {} 
      : { estudiante_id: userId };

    return await Solicitud.findAll({
      where,
      include: [
        { model: Usuario, as: 'estudiante', attributes: ['nombre_completo', 'matricula'] },
        { model: SubtipoSolicitud, as: 'subtipo' },
        { model: Documento, as: 'documentos' }
      ],
      order: [['createdAt', 'DESC']],
    });
  }

  static async updateEstado(id, estado, adminId, comentario = '') {
    const solicitud = await Solicitud.findByPk(id, {
      include: [{ model: Usuario, as: 'estudiante' }] // Traemos el estudiante para usarlo después si quieres
    });

    if (!solicitud) throw new Error('Solicitud no encontrada');

    await solicitud.update({
      estado_actual: estado,
      comentario,
    });

    return solicitud;
  }
}

export default SolicitudService;