import express from 'express';
import { verifyToken } from '../middleware/auth.js';
import SolicitudDraftController from '../controllers/SolicitudDraftController.js';

const router = express.Router();

router.get('/drafts', verifyToken, SolicitudDraftController.listMine);
router.get('/drafts/:id', verifyToken, SolicitudDraftController.getOne);
router.post('/draft', verifyToken, SolicitudDraftController.create);
router.put('/draft/:id', verifyToken, SolicitudDraftController.update);

export default router;
