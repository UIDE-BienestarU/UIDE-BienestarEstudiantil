import express from 'express';
import TipoSolicitudController from '../controllers/TipoSolicitudController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/tiposolicitudes', verifyToken, TipoSolicitudController.getTiposSolicitud);

export default router;