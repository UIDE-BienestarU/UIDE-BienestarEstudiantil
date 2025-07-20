import UsuarioService from '../../business/services/UsuarioService.js';

class UsuarioController {
  static async register(req, res) {
    try {
      const { user, token } = await UsuarioService.register(req.body);
      res.status(201).json({
        message: 'Usuario registrado exitosamente',
        data: { user: { id: user.id, correo_institucional: user.correo_institucional, rol: user.rol }, token },
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al registrar usuario',
        code: 'REGISTRATION_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async login(req, res) {
    try {
      const { user, token } = await UsuarioService.login(req.body.correo_institucional, req.body.contrasena);
      res.status(200).json({
        message: 'Inicio de sesión exitoso',
        data: { user: { id: user.id, correo_institucional: user.correo_institucional, rol: user.rol }, token },
      });
    } catch (error) {
      res.status(401).json({
        error: 'Credenciales inválidas',
        code: 'LOGIN_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async logout(req, res) {
    try {
      await UsuarioService.logout(req.user.userId, req.header('Authorization')?.replace('Bearer ', ''));
      res.status(200).json({
        message: 'Sesión cerrada exitosamente',
        data: null,
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error al cerrar sesión',
        code: 'LOGOUT_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async getEstudiantesConSolicitudes(req, res) {
    try {
      if (req.user.rol !== 'administrador') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los administradores pueden ver la lista de estudiantes con solicitudes',
          details: [],
        });
      }
      const estudiantes = await UsuarioService.getEstudiantesConSolicitudes();
      res.status(200).json({
        message: 'Lista de estudiantes con solicitudes obtenida exitosamente',
        data: estudiantes,
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default UsuarioController;