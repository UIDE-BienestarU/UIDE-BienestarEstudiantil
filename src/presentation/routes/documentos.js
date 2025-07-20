import express from 'express';
import DocumentoController from '../controllers/DocumentoController.js';
import { verifyToken } from '../middleware/auth.js';
import { validateDocumento } from '../middleware/validation.js';

const router = express.Router();

router.get('/solicitudes/:solicitudId/documentos', verifyToken, DocumentoController.getDocumentosBySolicitud);
router.post('/solicitudes/:solicitudId/documentos', verifyToken, validateDocumento, DocumentoController.addDocumento);

export default router;