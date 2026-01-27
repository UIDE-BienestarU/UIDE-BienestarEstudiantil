// src/presentation/middleware/multer.js
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Carpeta Uploads (coincide con server.js)
const uploadDir = path.join(__dirname, '../../Uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const original = path.basename(file.originalname).replace(/[^\w.\-]/g, '_');
    const ext = path.extname(original).toLowerCase();
    const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, `${unique}${ext}`);
  }
});

const allowedMimes = new Set([
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp'
]);

const fileFilter = (req, file, cb) => {
  if (!allowedMimes.has(file.mimetype)) {
    return cb(new Error(`Tipo de archivo no permitido: ${file.mimetype}`));
  }
  cb(null, true);
};

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter,
});

export default upload;
