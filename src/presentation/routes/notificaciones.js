import express from 'express';
import NotificacionController from '../controllers/NotificacionController.js';
import { verifyToken } from '../middleware/auth.js';
import { validateNotificacion, validateEnviarNotificacion } from '../middleware/validation.js';

const router = express.Router();

router.get('/notificaciones', verifyToken, NotificacionController.getNotificaciones);

router.get('/notificaciones/:userId', verifyToken, NotificacionController.getNotificacionesByUserId);

router.put('/notificaciones/:id/leido', verifyToken, validateNotificacion, NotificacionController.markAsRead);

// Ruta para enviar notificación push
router.post('/notificaciones/enviar', verifyToken, validateEnviarNotificacion, NotificacionController.enviarNotificacion);

export default router;