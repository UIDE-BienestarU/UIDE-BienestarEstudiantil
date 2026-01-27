// src/presentation/controllers/ObjetoPerdidoController.js

import ObjetoPerdidoService from '../../business/services/ObjetoPerdidoService.js';
import NotificacionService from '../../business/services/NotificacionService.js';
import admin from '../../config/firebase.js';
import Usuario from '../../data/models/Usuario.js';
import ObjetoPerdido from '../../data/models/ObjetoPerdido.js';

class ObjetoPerdidoController {
  static async reportar(req, res) {
    try {
      const { titulo, descripcion, lugar_encontrado, fecha } = req.body;

      // Validación obligatoria
      if (!titulo) {
        return res.status(400).json({
          error: 'titulo es requerido',
          code: 'VALIDATION_ERROR',
        });
      }

      if (!descripcion) {
        return res.status(400).json({
          error: 'descripcion es requerida',
          code: 'VALIDATION_ERROR',
        });
      }

      // Foto (opcional) - asumiendo multer con campo 'foto'
      const foto = req.file ? `/Uploads/${req.file.filename}` : null;

      // Preparar datos para el service
      const data = {
        titulo,
        descripcion,
        imagen: foto,
        lugar_encontrado: lugar_encontrado || null,
        fecha: fecha || new Date().toISOString().split('T')[0], // fecha actual si no viene
        reportado_por: req.user.userId,
      };

      console.log('Datos recibidos para crear objeto perdido:', data); // ← debug

      const objeto = await ObjetoPerdidoService.reportar(data, req.user.userId);

      // Notificar a TODOS los estudiantes
      const estudiantes = await Usuario.findAll({
        where: { rol: 'estudiante' },
        attributes: ['id', 'nombre_completo', 'fcm_token'],
      });

      const tituloNotif = '¡Nuevo objeto perdido reportado!';
      const cuerpoNotif = `Se reportó: "${titulo}" - ${descripcion.substring(0, 100)}...`;

      const promesas = estudiantes.map(async (estudiante) => {
        // Push notification si tiene token FCM
        if (estudiante.fcm_token) {
          const message = {
            token: estudiante.fcm_token,
            notification: {
              title: tituloNotif,
              body: cuerpoNotif,
            },
            data: {
              tipo: 'objeto_perdido',
              objetoId: objeto.id.toString(),
            },
          };

          try {
            await admin.messaging().send(message);
          } catch (pushError) {
            console.error(`Error enviando push a ${estudiante.id}:`, pushError.message);
          }
        }

        // Guardar en historial de notificaciones
        await NotificacionService.crearNotificacion({
          usuario_id: estudiante.id,
          titulo: tituloNotif,
          mensaje: cuerpoNotif,
          data: {
            tipo: 'objeto_perdido',
            objetoId: objeto.id,
          },
        });
      });

      await Promise.all(promesas);

      res.status(201).json({
        message: 'Objeto reportado y notificación enviada a estudiantes',
        data: objeto,
      });
    } catch (error) {
      console.error('Error reportando objeto perdido:', error);
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async obtenerTodos(req, res) {
    try {
      const objetos = await ObjetoPerdidoService.obtenerTodos();
      res.status(200).json({
        message: 'Objetos perdidos obtenidos exitosamente',
        data: objetos,
      });
    } catch (error) {
      console.error('Error obteniendo objetos perdidos:', error);
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async comentar(req, res) {
    try {
      const { mensaje, es_reclamo } = req.body;

      if (!mensaje) {
        return res.status(400).json({
          error: 'mensaje es requerido para el comentario',
          code: 'VALIDATION_ERROR',
        });
      }

      const comentario = await ObjetoPerdidoService.comentar(
        req.params.id,
        mensaje,
        req.user.userId,
        es_reclamo || false
      );

      // Opcional: notificar al reportador original si es reclamo
      if (es_reclamo) {
        const objeto = await ObjetoPerdido.findByPk(req.params.id);
        if (objeto && objeto.reportado_por) {
          await NotificacionService.crearNotificacion({
            usuario_id: objeto.reportado_por,
            titulo: 'Reclamo en tu reporte de objeto perdido',
            mensaje: `Alguien hizo un reclamo: "${mensaje}"`,
            data: { tipo: 'reclamo_objeto', objetoId: objeto.id },
          });
        }
      }

      res.status(201).json({
        message: 'Comentario agregado exitosamente',
        data: comentario,
      });
    } catch (error) {
      console.error('Error agregando comentario:', error);
      res.status(422).json({ error: error.message });
    }
  }

  static async actualizarEstado(req, res) {
    try {
      const { estado } = req.body;

      if (!estado) {
        return res.status(400).json({
          error: 'estado es requerido',
          code: 'VALIDATION_ERROR',
        });
      }

      if (!['perdido', 'encontrado', 'devuelto'].includes(estado)) {
        return res.status(400).json({
          error: 'estado inválido',
          code: 'VALIDATION_ERROR',
        });
      }

      const actualizado = await ObjetoPerdidoService.actualizarEstado(req.params.id, estado);

      return res.status(200).json({
        message: 'Estado actualizado',
        data: actualizado,
      });
    } catch (error) {
      console.error('Error actualizando estado objeto perdido:', error);
      return res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default ObjetoPerdidoController;
