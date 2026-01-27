import express from 'express';
import UsuarioController from '../controllers/UsuarioController.js';
import { validateUser, validateLogin } from '../middleware/validation.js';
import { verifyToken } from '../middleware/auth.js';
import Usuario from '../../data/models/Usuario.js';
import { authLimiter } from '../middleware/rateLimiters.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   - name: Auth
 *     description: Autenticación y sesión
 *   - name: Solicitudes
 *     description: Solicitudes de bienestar y documentos
 *   - name: Objetos Perdidos
 *     description: Publicación y gestión de objetos perdidos + comentarios
 *   - name: Notificaciones
 *     description: Notificaciones in-app y push
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Registrar usuario
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - correo_institucional
 *               - contrasena
 *               - nombre_completo
 *             properties:
 *               correo_institucional:
 *                 type: string
 *                 example: estudiante@uide.edu.ec
 *               contrasena:
 *                 type: string
 *                 example: 12345678
 *               nombre_completo:
 *                 type: string
 *                 example: Juan Pérez
 *               rol:
 *                 type: string
 *                 enum: [estudiante, administrador, bienestar]
 *                 example: estudiante
 *               cedula:
 *                 type: string
 *                 example: "1723456789"
 *               matricula:
 *                 type: string
 *                 example: "U20251234"
 *               telefono:
 *                 type: string
 *                 example: "0999999999"
 *               carrera:
 *                 type: string
 *                 example: "Ingeniería en Tecnologías de la Información"
 *               semestre:
 *                 type: integer
 *                 example: 5
 *     responses:
 *       201:
 *         description: Usuario registrado
 *       400:
 *         description: Datos inválidos
 *       409:
 *         description: Email ya existe
 */
router.post('/auth/register', authLimiter, validateUser, UsuarioController.register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Iniciar sesión
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - correo_institucional
 *               - contrasena
 *             properties:
 *               correo_institucional:
 *                 type: string
 *                 example: estudiante@uide.edu.ec
 *               contrasena:
 *                 type: string
 *                 example: 12345678
 *     responses:
 *       200:
 *         description: Login exitoso (tokens)
 *       401:
 *         description: Credenciales inválidas
 */
router.post('/auth/login', authLimiter, validateLogin, UsuarioController.login);

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Renovar access token usando refresh token
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *     responses:
 *       200:
 *         description: Tokens renovados
 *       400:
 *         description: refreshToken faltante
 *       401:
 *         description: Sesión inválida
 */
router.post('/auth/refresh', UsuarioController.refresh);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Cerrar sesión (invalida sesión/token)
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *     responses:
 *       200:
 *         description: Sesión cerrada
 *       401:
 *         description: No autorizado
 */
router.post('/auth/logout', verifyToken, UsuarioController.logout);

// ==================== PERFIL ====================

router.get('/perfil', verifyToken, async (req, res) => {
  try {
    const usuario = await Usuario.findByPk(req.user.userId, {
      attributes: [
        'id',
        'nombre_completo',
        'correo_institucional',
        'rol',
        'cedula',
        'matricula',
        'telefono',
        'carrera',
        'semestre'
      ]
    });

    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });

    res.json({ data: usuario });
  } catch (error) {
    res.status(500).json({ message: 'Error del servidor', error: error.message });
  }
});

router.put('/perfil', verifyToken, async (req, res) => {
  try {
    const { telefono, carrera, semestre } = req.body;
    const usuario = await Usuario.findByPk(req.user.userId);

    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });

    if (telefono) {
      if (!/^\d{9,10}$/.test(telefono)) {
        return res.status(400).json({ message: 'Teléfono inválido' });
      }
      usuario.telefono = telefono;
    }
    if (carrera) usuario.carrera = carrera;
    if (semestre) usuario.semestre = semestre;

    await usuario.save();
    res.json({ message: 'Perfil actualizado', data: usuario });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar', error: error.message });
  }
});

export default router;
