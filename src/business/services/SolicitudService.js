import Solicitud from '../../data/models/Solicitud.js';
import Documento from '../../data/models/Documento.js';
import Usuario from '../../data/models/Usuario.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';

import SolicitudHistorial from '../../data/models/SolicitudHistorial.js';
import { Op } from 'sequelize';
import { parsePagination } from '../utils/pagination.js'; 

class SolicitudService {
  static async createSolicitud(userId, data) {
    const t = await Solicitud.sequelize.transaction();
    try {
      const solicitud = await Solicitud.create({
        estudiante_id: userId,
        subtipo_id: data.subtipo_id,
        nivel_urgencia: data.nivel_urgencia || 'Normal',
        observaciones: data.observaciones,
        comentario: data.comentario || null,
      }, { transaction: t });

      await SolicitudHistorial.create({
        solicitud_id: solicitud.id,
        actor_user_id: userId,
        action: 'CREATE',
        from_status: null,
        to_status: solicitud.estado_actual,
        comentario: data.comentario || null
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

  static async getSolicitudes(userId, rol, query = {}) {
    const { page, limit, offset } = parsePagination(query);

    const where = {};
    if (!(rol === 'administrador' || rol === 'bienestar')) where.estudiante_id = userId;

    if (query.estado) where.estado_actual = query.estado;
    if (query.subtipo_id) where.subtipo_id = Number(query.subtipo_id);

    if (query.fechaDesde || query.fechaHasta) {
      where.createdAt = {};
      if (query.fechaDesde) where.createdAt[Op.gte] = new Date(query.fechaDesde);
      if (query.fechaHasta) where.createdAt[Op.lte] = new Date(query.fechaHasta);
    }

    const result = await Solicitud.findAndCountAll({
      where,
      include: [
        { model: Usuario, as: 'estudiante', attributes: ['nombre_completo', 'matricula'] },
        { model: SubtipoSolicitud, as: 'subtipo' },
        { model: Documento, as: 'documentos' }
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
      distinct: true,
    });

    return { rows: result.rows, total: result.count, page, limit };
  }

  static async addDocumentos(userId, solicitudId, documentos) {
    const solicitud = await Solicitud.findByPk(solicitudId);
    if (!solicitud) throw new Error('Solicitud no encontrada');
    if (solicitud.estudiante_id !== userId) throw new Error('No autorizado');

    if (!['Observada', 'Por revisar', 'En progreso'].includes(solicitud.estado_actual)) {
      throw new Error('No se pueden agregar documentos en este estado');
    }

    await Documento.bulkCreate(
      documentos.map(d => ({
        solicitud_id: solicitudId,
        url_archivo: d.url_archivo,
        nombre_documento: d.nombre_documento || 'Documento',
        obligatorio: d.obligatorio ?? true,
      }))
    );

    return await Solicitud.findByPk(solicitudId, { include: [{ model: Documento, as: 'documentos' }] });
  }

  static async updateEstado(id, estado, adminId, comentario = '') {
    const solicitud = await Solicitud.findByPk(id, {
      include: [{
        model: Usuario,
        as: 'estudiante',
        attributes: ['id', 'nombre_completo', 'correo_institucional']
      }]
    });

    if (!solicitud) throw new Error('Solicitud no encontrada');

    const from = solicitud.estado_actual;

    await solicitud.update({
      estado_actual: estado,
      comentario: comentario || null,
    });

    await SolicitudHistorial.create({
      solicitud_id: solicitud.id,
      actor_user_id: adminId,
      action: 'UPDATE_STATUS',
      from_status: from,
      to_status: estado,
      comentario: comentario || null
    });

    return solicitud;
  }

  static async getHistorial(solicitudId) {
    return await SolicitudHistorial.findAll({
      where: { solicitud_id: solicitudId },
      include: [{ model: Usuario, as: 'actor', attributes: ['id', 'nombre_completo', 'rol'] }],
      order: [['createdAt', 'ASC']],
    });
  }
}

export default SolicitudService;
