import express from 'express';
import DiscapacidadController from '../controllers/DiscapacidadController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import { validateDiscapacidad } from '../middleware/validation.js';

const router = express.Router();

router.post('/discapacidades', verifyToken, restrictTo('estudiante'), validateDiscapacidad, DiscapacidadController.createDiscapacidad);
router.get('/discapacidades', verifyToken, DiscapacidadController.getDiscapacidad);
router.put('/discapacidades', verifyToken, restrictTo('estudiante'), validateDiscapacidad, DiscapacidadController.updateDiscapacidad);

export default router;