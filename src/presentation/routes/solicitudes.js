import express from 'express';
import SolicitudController from '../controllers/SolicitudController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import { validateSolicitud, validateEstadoSolicitud } from '../middleware/validation.js';

const router = express.Router();

router.post('/solicitudes-crear', verifyToken, restrictTo('estudiante'), validateSolicitud, SolicitudController.createSolicitud);
router.get('/ver-solicitudes', verifyToken, SolicitudController.getSolicitudes);
router.put('/solicitudes/:id/estado', verifyToken, restrictTo('administrador', 'bienestar'), validateEstadoSolicitud, SolicitudController.updateEstado);

export default router;