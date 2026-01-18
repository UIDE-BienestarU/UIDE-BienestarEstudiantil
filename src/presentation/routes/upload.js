import express from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { verifyToken } from '../middleware/auth.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = express.Router();

// Configurar almacenamiento de multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Apuntar a la carpeta Uploads en la raíz del proyecto
    cb(null, path.join(__dirname, '../../../Uploads'));
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, `${uniqueSuffix}-${file.originalname}`);
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

// Ruta para subir archivos
router.post('/upload', verifyToken, upload.single('documento'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No se proporcionó ningún archivo',
        code: 'UPLOAD_ERROR',
        message: 'Se requiere un archivo',
      });
    }
    const filePath = `/Uploads/${req.file.filename}`;
    console.log('Archivo subido:', filePath);
    res.status(200).json({
      message: 'Archivo subido exitosamente',
      url: filePath,
    });
  } catch (error) {
    res.status(500).json({
      error: 'Error al subir archivo',
      code: 'SERVER_ERROR',
      message: error.message,
    });
  }
});

export default router;
