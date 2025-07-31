import Solicitud from '../../data/models/Solicitud.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';
import Estudiante from '../../data/models/Estudiante.js';
import TipoSolicitud from '../../data/models/TipoSolicitud.js';
import Notificacion from '../../data/models/Notificacion.js';
import Usuario from '../../data/models/Usuario.js';
import Documento from '../../data/models/Documento.js';
import { Op } from 'sequelize';

class SolicitudService {
  static async createSolicitud(userId, data) {
    try {
      const solicitud = await Solicitud.create({
        estudiante_id: userId,
        subtipo_id: data.subtipo_id,
        fecha_solicitud: new Date(),
        estado_actual: 'Pendiente',
        nivel_urgencia: data.nivel_urgencia,
        observaciones: data.observaciones,
        comentario: null,
      });

      // Crear documentos en la tabla Documento
      if (data.documentos && data.documentos.length > 0) {
        const documentos = data.documentos.map(doc => ({
          solicitud_id: solicitud.id,
          url_archivo: doc.url_archivo,
          obligatorio: doc.obligatorio,
          fecha_subida: new Date(),
        }));
        await Documento.bulkCreate(documentos);
      }

      // Obtener el nombre_completo del usuario
      const usuario = await Usuario.findByPk(userId, {
        attributes: ['nombre_completo'],
      });

      // Crear notificación para el administrador
      await Notificacion.create({
        solicitud_id: solicitud.id,
        mensaje: `Nueva solicitud creada por ${usuario?.nombre_completo || 'Estudiante ID ' + userId}`,
        tipo: 'Alerta',
        fecha_envio: new Date(),
        leido: false,
        destinatario_rol: 'administrador',
      });

      // Crear notificación para el estudiante
      await Notificacion.create({
        solicitud_id: solicitud.id,
        mensaje: `Tu solicitud #${solicitud.id} ha sido enviada exitosamente`,
        tipo: 'Confirmación',
        fecha_envio: new Date(),
        leido: false,
        destinatario_rol: 'estudiante',
        destinatario_id: userId,
      });

      return solicitud;
    } catch (error) {
      throw new Error('Error al crear solicitud: ' + error.message);
    }
  }

  static async getSolicitudes(userId, rol) {
    try {
      let whereClause = {};
      if (rol !== 'administrador') {
        whereClause = { estudiante_id: userId };
      }
      const solicitudes = await Solicitud.findAll({
        where: whereClause,
        include: [
          { 
            model: Estudiante, 
            include: [{ model: Usuario, attributes: ['nombre_completo', 'correo_institucional'] }],
            attributes: ['id', 'cedula', 'matricula', 'carrera', 'semestre'],
          },
          { 
            model: SubtipoSolicitud,
            include: [{ model: TipoSolicitud, attributes: ['nombre'] }],
            attributes: ['id', 'nombre_sub'],
          },
          {
            model: Documento,
            attributes: ['id', 'url_archivo', 'obligatorio', 'fecha_subida'],
          },
        ],
      });
      return solicitudes;
    } catch (error) {
      throw new Error('Error al obtener solicitudes: ' + error.message);
    }
  }

  static async getSolicitudById(id, userId, rol) {
    try {
      const whereClause = rol === 'administrador' ? {} : { estudiante_id: userId };
      const solicitud = await Solicitud.findOne({
        where: { id, ...whereClause },
        include: [
          { 
            model: Estudiante, 
            include: [{ model: Usuario, attributes: ['nombre_completo', 'correo_institucional'] }],
            attributes: ['id', 'cedula', 'matricula', 'carrera', 'semestre'],
          },
          { 
            model: SubtipoSolicitud,
            include: [{ model: TipoSolicitud, attributes: ['nombre'] }],
            attributes: ['id', 'nombre_sub'],
          },
          {
            model: Documento,
            attributes: ['id', 'url_archivo', 'obligatorio', 'fecha_subida'],
          },
        ],
      });
      if (!solicitud) {
        throw new Error('Solicitud no encontrada o no autorizada');
      }
      return solicitud;
    } catch (error) {
      throw new Error('Error al obtener solicitud: ' + error.message);
    }
  }

  static async getNotificaciones(userId, rol) {
    try {
      const whereClause = rol === 'administrador' 
        ? { destinatario_rol: 'administrador' }
        : { destinatario_rol: 'estudiante', destinatario_id: userId };
      const notificaciones = await Notificacion.findAll({
        where: whereClause,
        order: [['fecha_envio', 'DESC']],
      });
      return notificaciones;
    } catch (error) {
      throw new Error('Error al obtener notificaciones: ' + error.message);
    }
  }

  static async updateSolicitud(id, userId, data, rol) {
    try {
      const solicitud = await Solicitud.findByPk(id, {
        include: [{ model: Estudiante }, { model: Documento }],
      });
      if (!solicitud) {
        throw new Error('Solicitud no encontrada');
      }
      if (rol !== 'administrador' && solicitud.estudiante_id !== userId) {
        throw new Error('No autorizado para actualizar esta solicitud');
      }
      if (rol === 'estudiante' && solicitud.estado_actual !== 'Rechazado') {
        throw new Error('Solo se pueden actualizar solicitudes rechazadas');
      }

      // Guardar el estado actual para comparar cambios
      const estadoAnterior = solicitud.estado_actual;

      // Actualizar campos permitidos
      if (rol === 'administrador') {
        if (data.estado_actual) {
          solicitud.estado_actual = data.estado_actual;
          if (data.estado_actual === 'Rechazado') {
            if (!data.comentario) {
              throw new Error('El comentario es obligatorio al rechazar la solicitud');
            }
            solicitud.comentario = data.comentario;
          } else {
            solicitud.comentario = null; // Limpiar comentario si no se rechaza
          }
        }
        if (data.observaciones) {
          solicitud.observaciones = data.observaciones;
        }
      } else if (rol === 'estudiante') {
        solicitud.estado_actual = 'Pendiente';
        solicitud.comentario = null; // Limpiar comentario al reabrir
        if (data.observaciones) {
          solicitud.observaciones = data.observaciones;
        }
        if (data.documentos && data.documentos.length > 0) {
          // Eliminar documentos existentes
          await Documento.destroy({ where: { solicitud_id: solicitud.id } });
          // Crear nuevos documentos
          const documentos = data.documentos.map(doc => ({
            solicitud_id: solicitud.id,
            url_archivo: doc.url_archivo,
            obligatorio: doc.obligatorio,
            fecha_subida: new Date(),
          }));
          await Documento.bulkCreate(documentos);
        }
      }

      // Crear notificación si el estado cambia o la solicitud es actualizada por estudiante
      if (data.estado_actual !== estadoAnterior || rol === 'estudiante') {
        const usuario = await Usuario.findByPk(solicitud.estudiante_id, {
          attributes: ['nombre_completo'],
        });
        if (rol === 'administrador') {
          await Notificacion.create({
            solicitud_id: solicitud.id,
            mensaje: `Tu solicitud #${solicitud.id} ha sido actualizada a ${solicitud.estado_actual}${solicitud.comentario ? ': ' + solicitud.comentario : ''}`,
            tipo: 'Actualización',
            fecha_envio: new Date(),
            leido: false,
            destinatario_rol: 'estudiante',
            destinatario_id: solicitud.estudiante_id,
          });
        } else if (rol === 'estudiante') {
          await Notificacion.create({
            solicitud_id: solicitud.id,
            mensaje: `El estudiante ${usuario?.nombre_completo || 'ID ' + solicitud.estudiante_id} ha actualizado la solicitud #${solicitud.id}`,
            tipo: 'Actualización',
            fecha_envio: new Date(),
            leido: false,
            destinatario_rol: 'administrador',
          });
        }
      }

      await solicitud.save();
      return solicitud;
    } catch (error) {
      throw new Error('Error al actualizar solicitud: ' + error.message);
    }
  }

  static async deleteSolicitud(id, userId, rol) {
    try {
      const solicitud = await Solicitud.findByPk(id);
      if (!solicitud) {
        throw new Error('Solicitud no encontrada');
      }
      if (rol !== 'administrador' && solicitud.estudiante_id !== userId) {
        throw new Error('No autorizado para eliminar esta solicitud');
      }
      await solicitud.destroy();
      return true;
    } catch (error) {
      throw new Error('Error al eliminar solicitud: ' + error.message);
    }
  }
}

export default SolicitudService;
