import express from 'express';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import upload from '../middleware/multer.js';
import ObjetoPerdidoController from '../controllers/ObjetoPerdidoController.js';

const router = express.Router();

router.post(
  '/reportar-objetos-perdidos',
  verifyToken,
  restrictTo('administrador', 'bienestar'),
  upload.single('foto'),
  ObjetoPerdidoController.reportar
);

router.get(
  '/ver-objetos',
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