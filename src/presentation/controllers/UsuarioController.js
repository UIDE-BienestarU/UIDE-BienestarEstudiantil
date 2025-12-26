import UsuarioService from '../../business/services/UsuarioService.js';

class UsuarioController {
  // Registro de usuario
  static async register(req, res) {
    try {
      const userData = {
        ...req.body,
        contrasena: req.body.contrasena
      };

      const { user, token } = await UsuarioService.register(userData);

      res.status(201).json({
        message: 'Usuario registrado exitosamente',
        user: {
          id: user.id,
          correo_institucional: user.correo_institucional,
          nombre_completo: user.nombre_completo,
          rol: user.rol,
          cedula: user.cedula,
          matricula: user.matricula,
          carrera: user.carrera,
          semestre: user.semestre
        },
        token
      });
    } catch (error) {
      console.error('Error en registro:', error);

      // Errores de validacion de Sequelize
      if (error.name === 'SequelizeValidationError' || error.name === 'SequelizeUniqueConstraintError') {
        const details = error.errors?.map(err => ({
          field: err.path,
          message: err.message
        })) || [];

        return res.status(400).json({
          error: 'Datos inválidos',
          code: 'VALIDATION_ERROR',
          message: 'Por favor revisa los campos ingresados',
          details
        });
      }

      // Correo ya registrado
      if (error.message?.includes('correo_institucional')) {
        return res.status(409).json({
          error: 'Correo ya registrado',
          code: 'EMAIL_EXISTS',
          message: 'Ya existe un usuario con este correo institucional'
        });
      }

      // Error general
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: 'No se pudo completar el registro',
        // Solo en desarrollo mostramos el error real
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Inicio de sesión
  static async login(req, res) {
    try {
      const { correo_institucional, contrasena } = req.body;

      if (!correo_institucional || !contrasena) {
        return res.status(400).json({
          error: 'Faltan credenciales',
          message: 'Debe proporcionar correo y contraseña'
        });
      }

      const { user, token } = await UsuarioService.login(correo_institucional, contrasena);

      res.status(200).json({
        success: true,
        message: 'Inicio de sesión exitoso',
        user: {
          id: user.id,
          correo_institucional: user.correo_institucional,
          nombre_completo: user.nombre_completo,
          rol: user.rol
        },
        token
      });
    } catch (error) {
      res.status(401).json({
        success: false,
        error: 'Credenciales inválidas',
        code: 'LOGIN_FAILED',
        message: 'Correo institucional o contraseña incorrectos'
      });
    }
  }

  static async logout(req, res) {
    // En JWT el logout se maneja del lado del cliente (borrar token)
    res.status(200).json({
      success: true,
      message: 'Sesión cerrada correctamente'
    });
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