import express from 'express';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import upload from '../middleware/multer.js';
import ObjetoPerdidoController from '../controllers/ObjetoPerdidoController.js';
import ComentarioObjetoController from '../controllers/ComentarioObjetoController.js';

const router = express.Router();

/**
 * @swagger
 * /objetos-perdidos/reportar-objetos-perdidos:
 *   post:
 *     summary: Publicar objeto perdido (admin/bienestar)
 *     tags: [Objetos Perdidos]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [titulo, descripcion]
 *             properties:
 *               titulo:
 *                 type: string
 *                 example: "Botella azul"
 *               descripcion:
 *                 type: string
 *                 example: "Botella encontrada en el bloque A"
 *               lugar_encontrado:
 *                 type: string
 *                 example: "Biblioteca"
 *               estado:
 *                 type: string
 *                 enum: [perdido, encontrado, devuelto]
 *                 example: encontrado
 *               foto:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Objeto reportado
 *       401:
 *         description: No autorizado
 *       403:
 *         description: No permitido
 */
router.post(
  '/reportar-objetos-perdidos',
  verifyToken,
  restrictTo('administrador', 'bienestar'),
  upload.single('foto'),
  ObjetoPerdidoController.reportar
);

/**
 * @swagger
 * /objetos-perdidos/ver-objetos:
 *   get:
 *     summary: Listar objetos perdidos
 *     tags: [Objetos Perdidos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           example: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           example: 20
 *       - in: query
 *         name: estado
 *         schema:
 *           type: string
 *           example: "encontrado"
 *     responses:
 *       200:
 *         description: Lista de objetos
 */
router.get('/ver-objetos', verifyToken, ObjetoPerdidoController.obtenerTodos);

// =====================
// Comentarios (NUEVO)
// =====================

/**
 * @swagger
 * /objetos-perdidos/{id}/comentarios:
 *   get:
 *     summary: Listar comentarios de un objeto
 *     tags: [Objetos Perdidos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *           example: 5
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           example: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           example: 20
 *     responses:
 *       200:
 *         description: Comentarios paginados
 */
router.get('/:id/comentarios', verifyToken, ComentarioObjetoController.list);

/**
 * @swagger
 * /objetos-perdidos/{id}/comentarios:
 *   post:
 *     summary: Crear comentario (estudiante)
 *     tags: [Objetos Perdidos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *           example: 5
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [mensaje]
 *             properties:
 *               mensaje:
 *                 type: string
 *                 example: "Creo que es mía, ¿dónde puedo retirarla?"
 *               es_reclamo:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       201:
 *         description: Comentario creado
 */
router.post(
  '/:id/comentarios',
  verifyToken,
  restrictTo('estudiante'),
  ComentarioObjetoController.create
);

// =====================
// Alias legacy (opcional)
// =====================
// Mantener compatibilidad con clientes antiguos
router.post(
  '/:id/comentar',
  verifyToken,
  restrictTo('estudiante'),
  ComentarioObjetoController.create
);

/**
 * @swagger
 * /objetos-perdidos/{id}/estado:
 *   put:
 *     summary: Cambiar estado del objeto (admin/bienestar)
 *     tags: [Objetos Perdidos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *           example: 5
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [estado]
 *             properties:
 *               estado:
 *                 type: string
 *                 enum: [perdido, encontrado, devuelto]
 *                 example: devuelto
 *     responses:
 *       200:
 *         description: Estado actualizado
 */
router.put(
  '/:id/estado',
  verifyToken,
  restrictTo('administrador', 'bienestar'),
  ObjetoPerdidoController.actualizarEstado
);

export default router;
