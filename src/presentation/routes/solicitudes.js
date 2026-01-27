import express from 'express';
import SolicitudController from '../controllers/SolicitudController.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import { validateSolicitud, validateEstadoSolicitud } from '../middleware/validation.js';
import { idempotency } from '../middleware/idempotency.js';

const router = express.Router();

router.post(
    '/solicitudes/:id/documentos',
    verifyToken,
    restrictTo('estudiante'),
    SolicitudController.addDocumentos
);

/**
 * @swagger
 * /solicitudes-crear:
 *   post:
 *     summary: Crear solicitud
 *     tags: [Solicitudes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [subtipo_id]
 *             properties:
 *               subtipo_id:
 *                 type: integer
 *                 example: 1
 *               nivel_urgencia:
 *                 type: string
 *                 enum: [Normal, Alta, Crítica]
 *                 example: Normal
 *               observaciones:
 *                 type: string
 *                 example: "Adjunto documentos solicitados."
 *               comentario:
 *                 type: string
 *                 example: "Primera vez que solicito."
 *               documentos:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url_archivo:
 *                       type: string
 *                       example: "/Uploads/1700000000.pdf"
 *                     nombre_documento:
 *                       type: string
 *                       example: "Certificado"
 *                     obligatorio:
 *                       type: boolean
 *                       example: true
 *     responses:
 *       201:
 *         description: Solicitud creada
 *       401:
 *         description: No autorizado
 *       403:
 *         description: Solo estudiante
 *       400:
 *         description: Validación
 */
router.post(
    '/solicitudes-crear',
    verifyToken,
    restrictTo('estudiante'),
    idempotency('POST:/solicitudes-crear'),
    validateSolicitud,
    SolicitudController.createSolicitud
);

/**
 * @swagger
 * /ver-solicitudes:
 *   get:
 *     summary: Listar solicitudes (paginación y filtros)
 *     tags: [Solicitudes]
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
 *           example: "Por revisar"
 *       - in: query
 *         name: subtipo_id
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Lista de solicitudes
 *       401:
 *         description: No autorizado
 */
router.get('/ver-solicitudes', verifyToken, SolicitudController.getSolicitudes);

/**
 * @swagger
 * /solicitudes/{id}/estado:
 *   put:
 *     summary: Actualizar estado de solicitud (admin/bienestar)
 *     tags: [Solicitudes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *           example: 10
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [estado_actual]
 *             properties:
 *               estado_actual:
 *                 type: string
 *                 enum: [Por revisar, En progreso, Observada, Derivada a becas, Aprobada, Rechazada]
 *                 example: "En progreso"
 *               comentario:
 *                 type: string
 *                 example: "Falta documento X"
 *     responses:
 *       200:
 *         description: Estado actualizado
 *       403:
 *         description: No autorizado
 */
router.put(
    '/solicitudes/:id/estado',
    verifyToken,
    restrictTo('administrador', 'bienestar'),
    validateEstadoSolicitud,
    SolicitudController.updateEstado
);

router.get('/solicitudes/:id/historial', verifyToken, SolicitudController.getHistorial);

export default router;
