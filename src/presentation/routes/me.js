import express from 'express';
import { verifyToken } from '../middleware/auth.js';
import MeController from '../controllers/MeController.js';

const router = express.Router();

router.get('/summary', verifyToken, MeController.summary);

export default router;
