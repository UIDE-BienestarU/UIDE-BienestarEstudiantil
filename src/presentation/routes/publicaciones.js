// publicaciones.js
import express from 'express';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import upload from '../middleware/multer.js';
import PublicacionController from '../controllers/PublicacionController.js';

const router = express.Router();

/**
 * @swagger
 * /publicaciones/publicaciones-crear:
 *   post:
 *     summary: Crear una publicación institucional
 *     description: Permite al personal de Bienestar o Administrador crear una publicación con imagen opcional.
 *     tags: [Publicaciones]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - titulo
 *               - contenido
 *             properties:
 *               titulo:
 *                 type: string
 *                 example: "Feria de Bienestar Universitario"
 *               contenido:
 *                 type: string
 *                 example: "Este viernes se realizará la feria de bienestar en el campus principal."
 *               imagen:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Publicación creada exitosamente
 *       400:
 *         description: Error de validación
 *       401:
 *         description: No autenticado
 *       403:
 *         description: No autorizado (rol incorrecto)
 */
router.post(
    '/publicaciones-crear',
    verifyToken,
    restrictTo('administrador', 'bienestar'),
    upload.single('imagen'),
    PublicacionController.crear
);

/**
 * @swagger
 * /publicaciones/ver-publicaciones:
 *   get:
 *     summary: Listar publicaciones institucionales
 *     description: Devuelve todas las publicaciones visibles para los usuarios autenticados.
 *     tags: [Publicaciones]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           example: 1
 *         description: Página a consultar
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           example: 10
 *         description: Cantidad de publicaciones por página
 *     responses:
 *       200:
 *         description: Lista de publicaciones
 *       401:
 *         description: No autenticado
 */
router.get(
    '/ver-publicaciones',
    verifyToken,
    PublicacionController.obtenerTodas
);

export default router;
