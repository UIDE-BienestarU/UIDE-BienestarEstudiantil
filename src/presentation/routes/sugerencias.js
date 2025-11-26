import express from 'express';
import SugerenciaController from '../controllers/SugerenciaController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';

const router = express.Router();

router.post('/', verifyToken, SugerenciaController.enviar);
router.get('/', verifyToken, restrictTo('administrador', 'bienestar'), SugerenciaController.obtenerTodas);

export default router;