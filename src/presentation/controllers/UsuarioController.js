import UsuarioService from '../../business/services/UsuarioService.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';

class UsuarioController {
  // Registro de usuario
  static async register(req, res) {
    const userData = {
      ...req.body,
      contrasena: req.body.contrasena
    };

    const { user, accessToken, refreshToken } = await UsuarioService.register(userData);

    return ok(res, {
      status: 201,
      message: 'Usuario registrado exitosamente',
      data: { user, accessToken, refreshToken },
    });
  }

  // Inicio de sesión
  static async login(req, res) {
    const { correo_institucional, contrasena } = req.body;

    if (!correo_institucional || !contrasena) {
      throw new ApiError(400, 'MISSING_CREDENTIALS', 'Debe proporcionar correo y contraseña');
    }

    const { user, accessToken, refreshToken } = await UsuarioService.login(correo_institucional, contrasena);

    return ok(res, {
      message: 'Inicio de sesión exitoso',
      data: {
        user: {
          id: user.id,
          correo_institucional: user.correo_institucional,
          nombre_completo: user.nombre_completo,
          rol: user.rol
        },
        accessToken,
        refreshToken
      },
    });
  }

  static async refresh(req, res) {
    const { refreshToken } = req.body;
    if (!refreshToken) throw new ApiError(400, 'NO_REFRESH_TOKEN', 'refreshToken requerido');

    const tokens = await UsuarioService.refresh(refreshToken);
    return ok(res, { message: 'Token renovado', data: tokens });
  }

  static async logout(req, res) {
    const { refreshToken } = req.body;
    if (!refreshToken) throw new ApiError(400, 'NO_REFRESH_TOKEN', 'refreshToken requerido para logout');

    await UsuarioService.logout(req.user.userId, refreshToken);
    return ok(res, { message: 'Sesión cerrada correctamente' });
  }

  static async getEstudiantesConSolicitudes(req, res) {
    try {
      if (!['bienestar', 'administrador'].includes(req.user.rol)) {
        return res.status(403).json({
          error: 'Acceso denegado',
          message: 'Solo personal de Bienestar o Administrador puede acceder'
        });
      }

      const estudiantes = await UsuarioService.getEstudiantesConSolicitudes();

      res.status(200).json({
        success: true,
        message: 'Lista de estudiantes obtenida correctamente',
        count: estudiantes.length,
        data: estudiantes
      });
    } catch (error) {
      console.error('Error al obtener estudiantes:', error);
      res.status(500).json({
        success: false,
        error: 'Error del servidor',
        message: 'No se pudieron cargar los datos'
      });
    }
  }
}

export default UsuarioController;
