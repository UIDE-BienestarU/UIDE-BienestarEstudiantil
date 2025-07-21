import express from 'express';
import UsuarioController from '../controllers/UsuarioController.js';
import { validateUser, validateLogin } from '../middleware/validation.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';

const router = express.Router();

router.post('/auth/register', validateUser, UsuarioController.register);
router.post('/auth/login', validateLogin, UsuarioController.login);
router.post('/auth/logout', verifyToken, UsuarioController.logout);
router.get('/estudiantes-con-solicitudes', verifyToken, restrictTo('administrador'), UsuarioController.getEstudiantesConSolicitudes);

export default router;