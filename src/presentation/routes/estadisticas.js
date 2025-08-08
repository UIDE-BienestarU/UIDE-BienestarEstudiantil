import express from 'express';
import getEstadisticasHandler  from '../controllers/EstadisticaController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';

const router = express.Router();

router.get('/estadisticas', verifyToken, restrictTo('administrador'), getEstadisticasHandler);

export default router;