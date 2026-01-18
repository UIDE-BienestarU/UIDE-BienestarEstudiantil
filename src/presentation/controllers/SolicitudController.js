import SolicitudService from '../../business/services/SolicitudService.js';
import NotificacionService from '../../business/services/NotificacionService.js'; 
import admin from '../../config/firebase.js'; 
import Usuario from '../../data/models/Usuario.js'; 

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
        attributes: ['id', 'nombre_completo', 'fcm_token'],
      });

      const estudianteActual = await Usuario.findByPk(req.user.userId, {
        attributes: ['nombre_completo']
      });

      const nombre = estudianteActual?.nombre_completo?.trim() 
        ? estudianteActual.nombre_completo.trim() 
        : `Estudiante (ID: ${req.user.userId})`;

      const titulo = 'Nueva solicitud pendiente';
      const cuerpo = `${nombre} ha creado una nueva solicitud`;
      for (const adminUser of admins) {
        if (adminUser.fcm_token) {
          const message = {
            token: adminUser.fcm_token,
            notification: { title: titulo, body: cuerpo },
            data: { tipo: 'nueva_solicitud', solicitudId: solicitud.id.toString() },
          };

          try {
            await admin.messaging().send(message);
          } catch (error) {
            console.error(`Error enviando push a admin ${adminUser.id}:`, error.message);
            // No rompemos todo si falla un token
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
    try {
      const solicitudes = await SolicitudService.getSolicitudes(req.user.userId, req.user.rol);
      res.status(200).json({ message: 'OK', data: solicitudes });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Actualizar estado de solicitud
  static async updateEstado(req, res) {
    try {
      if (!['administrador', 'bienestar'].includes(req.user.rol)) {
        return res.status(403).json({ error: 'No autorizado' });
      }

      const { estado_actual, comentario } = req.body;
      const solicitud = await SolicitudService.updateEstado(req.params.id, estado_actual, req.user.userId, comentario);

      // === NUEVO: Notificar al estudiante del cambio de estado ===
      const estudiante = await Usuario.findByPk(solicitud.estudiante_id, {
        attributes: ['nombre_completo', 'fcm_token'],
      });

      if (!estudiante) {
        throw new Error('Estudiante no encontrado');
      }

      const estadosMensaje = {
        'Aprobado': '¡Tu solicitud ha sido APROBADA!',
        'En progreso': 'Tu solicitud está en progreso',
        'Por revisar': 'Tu solicitud está por revisar',
      };

      const titulo = `Solicitud ${estado_actual}`;
      const cuerpo = estadosMensaje[estado_actual] || `Tu solicitud ahora está: ${estado_actual}`;
      if (comentario) cuerpo += `\nComentario: ${comentario}`;

      // Enviar push si tiene token
      if (estudiante.fcm_token) {
        const message = {
          token: estudiante.fcm_token,
          notification: { title: titulo, body: cuerpo },
          data: { tipo: 'cambio_estado', solicitudId: solicitud.id.toString(), estado: estado_actual },
        };

        try {
          await admin.messaging().send(message);
        } catch (error) {
          console.error(`Error enviando push al estudiante ${estudiante.id}:`, error.message);
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
}

export default SolicitudController;