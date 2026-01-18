import express from 'express';
import DiscapacidadController from '../controllers/DiscapacidadController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import { validateDiscapacidad } from '../middleware/validation.js';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = express.Router();

// Configurar almacenamiento de multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../../../Uploads');
    console.log('Ruta de destino para multer:', uploadPath);
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const cleanFileName = file.originalname.replace(/\s+/g, '_');
    cb(null, `${uniqueSuffix}-${cleanFileName}`);
  },
});

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
    if (!allowedTypes.includes(file.mimetype)) {
      return cb(new Error('Solo se permiten archivos PDF, JPG o PNG'));
    }
    cb(null, true);
  },
});

router.post('/agregar-discapacidad', verifyToken, restrictTo('estudiante'), upload.single('informe_medico'), validateDiscapacidad, DiscapacidadController.createDiscapacidad);
router.get('/obtener-discapacidades', verifyToken, DiscapacidadController.getDiscapacidad);
router.put('/actualizar-discapacidad/:id', verifyToken, restrictTo('estudiante'), upload.single('informe_medico'), validateDiscapacidad, DiscapacidadController.updateDiscapacidad);

export default router;
