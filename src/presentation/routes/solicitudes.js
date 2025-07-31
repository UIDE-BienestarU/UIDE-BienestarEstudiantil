import express from 'express';
import SolicitudController from '../controllers/SolicitudController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import { validateSolicitud, validateSolicitudUpdate } from '../middleware/validation.js';

const router = express.Router();

router.post('/solicitudes', verifyToken, restrictTo('estudiante'), validateSolicitud, SolicitudController.createSolicitud);
router.get('/solicitudes', verifyToken, SolicitudController.getSolicitudes);
router.get('/solicitudes/:id', verifyToken, SolicitudController.getSolicitudById);
router.get('/notificaciones', verifyToken, SolicitudController.getNotificaciones);
router.put('/solicitudes/:id', verifyToken, restrictTo('administrador', 'estudiante'), validateSolicitudUpdate, SolicitudController.updateSolicitud);
router.delete('/solicitudes/:id', verifyToken, SolicitudController.deleteSolicitud);

export default router;
