import express from 'express';
import { verifyToken } from '../middleware/auth.js';
import upload from '../middleware/multer.js'; 
import ObjetoPerdidoController from '../controllers/ObjetoPerdidoController.js';

const router = express.Router();

router.post('/', verifyToken, upload.single('foto'), ObjetoPerdidoController.reportar);
router.get('/', verifyToken, ObjetoPerdidoController.obtenerTodos);
router.post('/:id/comentar', verifyToken, ObjetoPerdidoController.comentar);

export default router;