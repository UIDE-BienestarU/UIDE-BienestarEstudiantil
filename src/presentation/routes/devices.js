import express from 'express';
import { verifyToken } from '../middleware/auth.js';
import DeviceController from '../controllers/DeviceController.js';

const router = express.Router();

router.post('/register', verifyToken, DeviceController.register);
router.post('/unregister', verifyToken, DeviceController.unregister);

export default router;
