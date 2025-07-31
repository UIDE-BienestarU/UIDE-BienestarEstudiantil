import { body, param, validationResult } from 'express-validator';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';

export const validateUser = [
  body('correo_institucional')
    .isEmail()
    .matches(/^[a-zA-Z0-9._%+-]+@uide\.edu\.ec$/i)
    .withMessage('El correo debe ser institucional (@uide.edu.ec)'),
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
          field: err.path,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateLogin = [
  body('correo_institucional')
    .isEmail()
    .matches(/^[a-zA-Z0-9._%+-]+@uide\.edu\.ec$/i)
    .withMessage('El correo debe ser institucional (@uide.edu.ec)'),
  body('contrasena')
    .notEmpty()
    .withMessage('La contraseña es obligatoria'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.path,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateSolicitud = [
  body('subtipo_id').isInt().withMessage('El ID del subtipo debe ser un número entero'),
  body('nivel_urgencia').isIn(['Normal', 'Alta', 'Crítica']).withMessage('El nivel de urgencia debe ser Normal, Alta o Crítica'),
  body('observaciones').optional().isString().withMessage('Las observaciones deben ser una cadena de texto'),
  body('documentos').optional().isArray().withMessage('Los documentos deben ser un arreglo'),
  body('documentos.*.url_archivo').optional().isString().withMessage('La URL del documento debe ser una cadena'),
  body('documentos.*.obligatorio').optional().isBoolean().withMessage('El campo obligatorio debe ser booleano'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array(),
      });
    }
    next();
  },
];

export const validateSolicitudUpdate = [
  body('estado_actual')
    .optional()
    .isIn(['Pendiente', 'Aprobado', 'Rechazado', 'En espera'])
    .withMessage('El estado debe ser uno de: Pendiente, Aprobado, Rechazado, En espera'),
  body('observaciones').optional().isString().withMessage('Las observaciones deben ser una cadena de texto'),
  body('comentario')
    .if(body('estado_actual').equals('Rechazado'))
    .notEmpty()
    .withMessage('El comentario es obligatorio al rechazar la solicitud'),
  body('documentos').optional().isArray().withMessage('Los documentos deben ser un arreglo'),
  body('documentos.*.url_archivo').optional().isString().withMessage('La URL del documento debe ser una cadena'),
  body('documentos.*.obligatorio').optional().isBoolean().withMessage('El campo obligatorio debe ser booleano'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array(),
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
          field: err.path,
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
          field: err.path,
          message: err.msg,
        })),
      });
    }
    next();
  },
];

export const validateDiscapacidad = [
  body('tipo')
    .notEmpty()
    .withMessage('El tipo de discapacidad es requerido')
    .isString()
    .withMessage('El tipo de discapacidad debe ser texto')
    .isLength({ max: 100 })
    .withMessage('El tipo de discapacidad no puede exceder los 100 caracteres'),
  body('carnet_conadis')
    .optional()
    .isString()
    .withMessage('El carnet CONADIS debe ser texto')
    .isLength({ max: 50 })
    .withMessage('El carnet CONADIS no puede exceder los 50 caracteres'),
  body('informe_medico')
    .optional()
    .if(body('informe_medico').exists())
    .isString()
    .withMessage('El informe médico debe ser una URL válida')
    .matches(/^\/Uploads\//)
    .withMessage('El informe médico debe ser una URL que comience con /Uploads/'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Error de validación',
        code: 'VALIDATION_ERROR',
        message: 'Los datos proporcionados no son válidos',
        details: errors.array().map(err => ({
          field: err.path,
          message: err.msg,
        })),
      });
    }
    next();
  },
];
