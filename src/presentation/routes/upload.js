import express from 'express';
import { verifyToken } from '../middleware/auth.js';
import upload from '../middleware/multer.js';
import { uploadLimiter } from '../middleware/rateLimiters.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';

const router = express.Router();

router.post(
  '/upload',
  verifyToken,
  uploadLimiter,
  upload.single('documento'),
  (req, res) => {
    if (!req.file) {
      throw new ApiError(400, 'UPLOAD_ERROR', 'Se requiere un archivo');
    }

    const filePath = `/Uploads/${req.file.filename}`;

    return ok(res, {
      message: 'Archivo subido exitosamente',
      data: {
        url: filePath,
        mimeType: req.file.mimetype,
        size: req.file.size,
        originalName: req.file.originalname,
      }
    });
  }
);

export default router;
