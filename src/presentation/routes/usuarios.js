import express from 'express';
import UsuarioController from '../controllers/UsuarioController.js';
import { validateUser, validateLogin } from '../middleware/validation.js';
import { verifyToken, restrictTo } from '../middleware/auth.js';
import Usuario from '../../data/models/Usuario.js';

const router = express.Router();

// Auth
router.post('/auth/register', validateUser, UsuarioController.register);
router.post('/auth/login', validateLogin, UsuarioController.login);
router.post('/auth/logout', verifyToken, UsuarioController.logout);

// Perfil (ahora todo está en Usuario, no hay Estudiante)
router.get('/perfil', verifyToken, async (req, res) => {
  try {
    const usuario = await Usuario.findByPk(req.user.userId, {
      attributes: ['id', 'nombre_completo', 'correo_institucional', 'rol', 'cedula', 'matricula', 'telefono', 'carrera', 'semestre']
    });

    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });

    res.json({ data: usuario });
  } catch (error) {
    res.status(500).json({ message: 'Error del servidor', error: error.message });
  }
});

// Actualizar teléfono (o cualquier campo del estudiante)
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