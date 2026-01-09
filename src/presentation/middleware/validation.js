// src/presentation/middleware/validation.js
import { body, param, validationResult } from 'express-validator';

const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Error de validación',
      message: 'Los datos proporcionados no son válidos',
      details: errors.array().map(err => ({
        campo: err.path,
        mensaje: err.msg
      }))
    });
  }
  next();
};

// ==================== REGISTRO ====================
export const validateUser = [
  body('correo_institucional')
    .isEmail()
    .contains('@uide.edu.ec')
    .withMessage('Debe ser correo institucional @uide.edu.ec'),

  body('contrasena')
    .isLength({ min: 8 })
    .withMessage('La contraseña debe tener mínimo 8 caracteres'),

  body('nombre_completo')
    .notEmpty()
    .withMessage('El nombre completo es obligatorio'),

  body('cedula')
    .optional()
    .isLength({ min: 10, max: 10 })
    .isNumeric()
    .withMessage('La cédula debe tener exactamente 10 dígitos'),

  body('matricula')
    .optional()
    .matches(/^U\d{6,8}$/)
    .withMessage('Matrícula inválida. Formato: U seguido de 6-8 números (ej: U20251234)'),

  body('telefono')
    .optional()
    .matches(/^\d{9,10}$/)
    .withMessage('Teléfono debe tener 9 o 10 dígitos'),

  body('carrera')
    .optional()
    .isIn(['Ingeniería en Tecnologías de la Información', 'Arquitectura', 'Psicología', 'Marketing', 'Derecho', 'Business'])
    .withMessage('Carrera no válida'),

  body('semestre')
    .optional()
    .isInt({ min: 1, max: 10 })
    .withMessage('Semestre debe ser entre 1 y 10'),

  handleValidation
];

// ==================== LOGIN ====================
export const validateLogin = [
  body('correo_institucional').isEmail().contains('@uide.edu.ec').withMessage('Correo institucional requerido'),
  body('contrasena').notEmpty().withMessage('Contraseña requerida'),
  handleValidation
];

// ==================== DISCAPACIDAD ====================
export const validateDiscapacidad = [
  body('tipo').notEmpty().withMessage('Tipo de discapacidad obligatorio'),
  handleValidation
];

// ==================== DOCUMENTO ====================
export const validateDocumento = [
  body('url_archivo').matches(/^\/Uploads\//).withMessage('Ruta debe comenzar con /Uploads/'),
  handleValidation
];

// ==================== NOTIFICACIÓN ====================

// Para marcar como leída: PUT /notificaciones/:id/leido
export const validateNotificacion = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('El ID de la notificación debe ser un número entero positivo'),
  handleValidation
];

// NUEVA: Para enviar notificación push: POST /notificaciones/enviar
export const validateEnviarNotificacion = [
  body('userId')
    .isInt({ min: 1 })
    .withMessage('userId debe ser un número entero positivo'),

  body('title')
    .isString()
    .notEmpty()
    .isLength({ max: 100 })
    .withMessage('El título es obligatorio y no debe exceder 100 caracteres'),

  body('body')
    .isString()
    .notEmpty()
    .isLength({ max: 500 })
    .withMessage('El mensaje es obligatorio y no debe exceder 500 caracteres'),

  body('data')
    .optional()
    .isObject()
    .withMessage('data debe ser un objeto JSON (opcional)'),

  handleValidation
];

// ==================== SOLICITUD ====================
export const validateSolicitud = [
  body('subtipo_id').isInt({ min: 1 }).withMessage('Subtipo requerido'),
  handleValidation
];

export const validateEstadoSolicitud = [
  body('estado_actual').isIn(['Pendiente', 'Aprobado', 'Rechazado', 'En espera'])
    .withMessage('Estado no válido'),
  handleValidation
];