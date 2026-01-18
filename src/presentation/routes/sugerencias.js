import express from 'express';
import SugerenciaController from '../controllers/SugerenciaController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';

const router = express.Router();

router.post('/enviar-sugerencia', verifyToken, SugerenciaController.enviar);
router.get('/ver-sugerencias', verifyToken, restrictTo('administrador', 'bienestar'), SugerenciaController.obtenerTodas);

export default router;