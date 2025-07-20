import { body, param, validationResult } from 'express-validator';

export const validateUser = [
  body('correo_institucional')
    .isEmail()
    .matches(/^[a-z][a-z]?[a-z]+@uide\.edu\.ec$/i)
    .withMessage('El correo debe ser institucional (@uide.edu.ec) con formato válido'),
  body('contrasena')
    .isLength({ min: 8 })
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
    .withMessage('La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial'),
  body('nombre_completo').notEmpty().withMessage('El nombre completo es obligatorio'),
  body('rol').isIn(['estudiante', 'administrador']).withMessage('Rol inválido'),
  body('cedula').if(body('rol').equals('estudiante')).matches(/^\d{10}$/).withMessage('Cédula debe tener 10 dígitos'),
  body('matricula').if(body('rol').equals('estudiante')).matches(/^U\d{6}$/).withMessage('Matrícula debe seguir el formato U123456'),
  body('telefono').if(body('rol').equals('estudiante')).matches(/^\d{9,10}$/).withMessage('Teléfono debe tener 9 o 10 dígitos'),
  body('carrera').if(body('rol').equals('estudiante')).isIn([
    'Ingeniería en Tecnologías de la Información',
    'Arquitectura',
    'Psicología',
    'Marketing',
    'Derecho',
    'Business',
  ]).withMessage('Carrera inválida'),
  body('semestre').if(body('rol').equals('estudiante')).isInt({ min: 1, max: 8 }).withMessage('Semestre debe estar entre 1 y 8'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateSolicitud = [
  body('subtipo_id').isInt().withMessage('Subtipo de solicitud inválido'),
  body('nivel_urgencia').isIn(['Normal', 'Alta', 'Crítica']).withMessage('Nivel de urgencia inválido'),
  body('observaciones').optional().isString().withMessage('Observaciones deben ser texto'),
  body('documentos').optional().isArray().withMessage('Documentos deben ser un arreglo'),
  body('documentos.*.nombre_documento').optional().isString().withMessage('Nombre del documento debe ser texto'),
  body('documentos.*.url_archivo').isString().withMessage('URL del documento es obligatoria'),
  body('documentos.*.obligatorio').optional().isBoolean().withMessage('Obligatorio debe ser booleano'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateSolicitudUpdate = [
  body('estado').isIn(['Pendiente', 'Aprobado', 'Rechazado', 'En espera']).withMessage('Estado inválido'),
  body('observaciones').optional().isString().withMessage('Observaciones deben ser texto'),
  body('comentario').optional().isString().withMessage('Comentario debe ser texto'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateNotificacion = [
  param('id').isInt().withMessage('ID de notificación inválido'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateDocumento = [
  body('nombre_documento').optional().isString().withMessage('Nombre del documento debe ser texto'),
  body('url_archivo').isString().withMessage('URL del documento es obligatoria'),
  body('obligatorio').optional().isBoolean().withMessage('Obligatorio debe ser booleano'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateDiscapacidad = [
  body('tipo').isString().withMessage('Tipo de discapacidad debe ser texto'),
  body('carnet_conadis').optional().isString().withMessage('Carnet CONADIS debe ser texto'),
  body('informe_medico').optional().isString().withMessage('Informe médico debe ser texto'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  },
];