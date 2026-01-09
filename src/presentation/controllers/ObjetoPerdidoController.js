// src/presentation/controllers/ObjetoPerdidoController.js

import ObjetoPerdidoService from '../../business/services/ObjetoPerdidoService.js';
import NotificacionService from '../../business/services/NotificacionService.js';
import admin from '../../config/firebase.js';
import Usuario from '../../data/models/Usuario.js';

class ObjetoPerdidoController {
  static async reportar(req, res) {
    try {
      const { descripcion, lugar, fecha } = req.body;
      const foto = req.file ? `/Uploads/${req.file.filename}` : null;

      const obj = await ObjetoPerdidoService.reportar(
        { descripcion, lugar, fecha, foto },
        req.user.userId
      );

      //  Notificar a TODOS los estudiantes 
      const estudiantes = await Usuario.findAll({
        where: { rol: 'estudiante' },
        attributes: ['id', 'nombre_completo', 'fcm_token'],
      });

      const titulo = '¡Nuevo objeto perdido reportado!';
      const cuerpo = descripcion || 'Se encontró un objeto en el campus. ¡Revisa si es tuyo!';

      const promesasNotificaciones = estudiantes.map(async (estudiante) => {
        // Enviar push si tiene token
        if (estudiante.fcm_token) {
          const message = {
            token: estudiante.fcm_token,
            notification: { title: titulo, body: cuerpo },
            data: {
              tipo: 'objeto_perdido',
              objetoId: obj.id.toString(),
            },
          };

          try {
            await admin.messaging().send(message);
          } catch (error) {
            console.error(`Error enviando push a estudiante ${estudiante.id}:`, error.message);
          }
        }

        // Guardar en historial de notificaciones
        await NotificacionService.crearNotificacion({
          usuario_id: estudiante.id,
          titulo,
          mensaje: cuerpo,
          data: {
            tipo: 'objeto_perdido',
            objetoId: obj.id,
          },
        });
      });

      // Ejecutamos todas en paralelo (más rápido)
      await Promise.all(promesasNotificaciones);

      res.status(201).json({
        message: 'Objeto reportado y notificación enviada a estudiantes',
        data: obj,
      });
    } catch (error) {
      console.error('Error reportando objeto perdido:', error);
      res.status(422).json({ error: error.message });
    }
  }

  static async obtenerTodos(req, res) {
    try {
      const objetos = await ObjetoPerdidoService.obtenerTodos();
      res.status(200).json({ message: 'OK', data: objetos });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  static async comentar(req, res) {
    try {
      const { mensaje, es_reclamo } = req.body;

      const comentario = await ObjetoPerdidoService.comentar(
        req.params.id,
        mensaje,
        req.user.userId,
        es_reclamo || false
      );

      if (es_reclamo) {
      }

      res.status(201).json({ message: 'Comentario agregado', data: comentario });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }
}

export default ObjetoPerdidoController;