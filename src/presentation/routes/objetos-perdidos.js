import express from 'express';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import upload from '../middleware/multer.js';
import ObjetoPerdidoController from '../controllers/ObjetoPerdidoController.js';

const router = express.Router();

router.post(
  '/',
  verifyToken,
  restrictTo('administrador', 'bienestar'),
  upload.single('foto'),
  ObjetoPerdidoController.reportar
);

router.get(
  '/',
  verifyToken,
  ObjetoPerdidoController.obtenerTodos
);

router.post(
  '/:id/comentar',
  verifyToken,
  restrictTo('estudiante'),
  ObjetoPerdidoController.comentar
);

export default router;