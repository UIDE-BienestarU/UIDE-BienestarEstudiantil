// publicaciones.js
import express from 'express';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import upload from '../middleware/multer.js';  
import PublicacionController from '../controllers/PublicacionController.js';

const router = express.Router();

router.post('/', verifyToken, restrictTo('administrador', 'bienestar'), upload.single('imagen'), PublicacionController.crear);
router.get('/', verifyToken, PublicacionController.obtenerTodas);

export default router;