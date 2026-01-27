import SolicitudService from '../../business/services/SolicitudService.js';
import NotificacionService from '../../business/services/NotificacionService.js';
import admin from '../../config/firebase.js';
import Usuario from '../../data/models/Usuario.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';
import DeviceService from '../../business/services/DeviceService.js';

class SolicitudController {
  // Crear solicitud
  static async createSolicitud(req, res) {
    try {
      if (req.user.rol !== 'estudiante') {
        return res.status(403).json({ error: 'Solo estudiantes', code: 'FORBIDDEN' });
      }

      const solicitud = await SolicitudService.createSolicitud(req.user.userId, req.body);

      // === NUEVO: Notificar a todos los administradores y bienestar ===
      const admins = await Usuario.findAll({
        where: { rol: ['administrador', 'bienestar'] },
        attributes: ['id', 'nombre_completo'],
      });

      const estudianteActual = await Usuario.findByPk(req.user.userId, {
        attributes: ['nombre_completo']
      });

      const nombre = estudianteActual?.nombre_completo?.trim()
        ? estudianteActual.nombre_completo.trim()
        : `Estudiante (ID: ${req.user.userId})`;

      const titulo = 'Nueva solicitud pendiente';
      const cuerpo = `${nombre} ha creado una nueva solicitud`;

      const adminIds = admins.map(a => a.id);
      const tokensMap = await DeviceService.getActiveTokensByUserIds(adminIds);

      for (const adminUser of admins) {
        const tokens = tokensMap.get(adminUser.id) || [];
        for (const token of tokens) {
          try {
            await admin.messaging().send({
              token,
              notification: { title: titulo, body: cuerpo },
              data: { tipo: 'nueva_solicitud', solicitudId: solicitud.id.toString() },
            });
          } catch (e) {
            // si token inválido, lo desactivas
            await DeviceService.disableToken(token);
          }
        }

        // Guardar en historial de notificaciones
        await NotificacionService.crearNotificacion({
          usuario_id: adminUser.id,
          titulo,
          mensaje: cuerpo,
          data: { tipo: 'nueva_solicitud', solicitudId: solicitud.id },
        });
      }

      res.status(201).json({ message: 'Solicitud creada', data: solicitud });
    } catch (error) {
      console.error('Error creando solicitud:', error);
      res.status(422).json({ error: error.message });
    }
  }

  // Listar solicitudes
  static async getSolicitudes(req, res) {
    const result = await SolicitudService.getSolicitudes(req.user.userId, req.user.rol, req.query);
    return ok(res, {
      message: 'Solicitudes',
      data: result.rows,
      meta: { page: result.page, limit: result.limit, total: result.total }
    });
  }

  static async addDocumentos(req, res) {
    const solicitudId = Number(req.params.id);
    const { documentos } = req.body; // [{ url_archivo, nombre_documento, obligatorio }]
    if (!Array.isArray(documentos) || documentos.length === 0) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'documentos es requerido');
    }

    const result = await SolicitudService.addDocumentos(req.user.userId, solicitudId, documentos);
    return ok(res, { message: 'Documentos agregados', data: result });
  }

  // Actualizar estado de solicitud
  static async updateEstado(req, res) {
    try {
      if (!['administrador', 'bienestar'].includes(req.user.rol)) {
        return res.status(403).json({ error: 'No autorizado' });
      }

      const { estado_actual, comentario } = req.body;
      const solicitud = await SolicitudService.updateEstado(req.params.id, estado_actual, req.user.userId, comentario);

      const estadosMensaje = {
        'Aprobada': '¡Tu solicitud ha sido APROBADA!',
        'En progreso': 'Tu solicitud está en progreso',
        'Por revisar': 'Tu solicitud está por revisar',
        'Observada': 'Tu solicitud fue OBSERVADA: revisa los requisitos y vuelve a subir documentos.',
        'Derivada a becas': 'Tu solicitud fue derivada al área de Becas.',
        'Rechazada': 'Tu solicitud fue RECHAZADA. Revisa el comentario.',
      };

      const titulo = `Solicitud ${estado_actual}`;
      let cuerpo = estadosMensaje[estado_actual] || `Tu solicitud ahora está: ${estado_actual}`;
      if (comentario) cuerpo += `\nComentario: ${comentario}`;

      const tokensMap = await DeviceService.getActiveTokensByUserIds([solicitud.estudiante_id]);
      const tokens = tokensMap.get(solicitud.estudiante_id) || [];
      for (const token of tokens) {
        try {
          await admin.messaging().send({
            token,
            notification: { title: titulo, body: cuerpo },
            data: { tipo: 'cambio_estado', solicitudId: solicitud.id.toString(), estado: estado_actual },
          });
        } catch (e) {
          await DeviceService.disableToken(token);
        }
      }

      // Guardar en historial
      await NotificacionService.crearNotificacion({
        usuario_id: solicitud.estudiante_id,
        titulo,
        mensaje: cuerpo,
        data: { tipo: 'cambio_estado', solicitudId: solicitud.id, estado: estado_actual },
      });

      res.status(200).json({ message: 'Estado actualizado', data: solicitud });
    } catch (error) {
      console.error('Error actualizando estado:', error);
      res.status(422).json({ error: error.message });
    }
  }

  static async getHistorial(req, res) {
    const { id } = req.params;
    const historial = await SolicitudService.getHistorial(id);
    return ok(res, { message: 'Historial', data: historial });
  }
}

export default SolicitudController;
