import express from 'express';
import NotificacionController from '../controllers/NotificacionController.js';
import { verifyToken } from '../middleware/auth.js';
import { validateNotificacion, validateEnviarNotificacion } from '../middleware/validation.js';

const router = express.Router();

/**
 * @swagger
 * /notificaciones:
 *   get:
 *     summary: Listar notificaciones (paginado y filtro unread)
 *     tags: [Notificaciones]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           example: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           example: 20
 *       - in: query
 *         name: unread
 *         schema:
 *           type: boolean
 *           example: true
 *     responses:
 *       200:
 *         description: Notificaciones paginadas
 */
router.get('/notificaciones', verifyToken, NotificacionController.getNotificaciones);

router.get('/notificaciones/:userId', verifyToken, NotificacionController.getNotificacionesByUserId);

/**
 * @swagger
 * /notificaciones/{id}/leido:
 *   put:
 *     summary: Marcar notificación como leída
 *     tags: [Notificaciones]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *           example: 12
 *     responses:
 *       200:
 *         description: Notificación marcada como leída
 *       404:
 *         description: No encontrada
 */
router.put('/notificaciones/:id/leido', verifyToken, validateNotificacion, NotificacionController.markAsRead);

/**
 * @swagger
 * /notificaciones/enviar:
 *   post:
 *     summary: Enviar notificación push a un usuario (solo admin)
 *     tags: [Notificaciones]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [userId, title, body]
 *             properties:
 *               userId:
 *                 type: integer
 *                 example: 1
 *               title:
 *                 type: string
 *                 example: "Recordatorio"
 *               body:
 *                 type: string
 *                 example: "Revisa tu solicitud en la app"
 *               data:
 *                 type: object
 *                 example:
 *                   tipo: "custom"
 *                   foo: "bar"
 *     responses:
 *       200:
 *         description: Push enviado + guardado en BD
 *       403:
 *         description: No autorizado
 */
router.post('/notificaciones/enviar', verifyToken, validateEnviarNotificacion, NotificacionController.enviarNotificacion);

export default router;
