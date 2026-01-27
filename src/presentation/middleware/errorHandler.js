// src/presentation/middleware/errorHandler.js
import { fail } from './apiResponse.js';
import multer from 'multer';

export class ApiError extends Error {
    constructor(status, code, message, errors = null) {
        super(message);
        this.status = status;
        this.code = code;
        this.errors = errors;
    }
}

export const notFoundHandler = (req, res) => {
    return fail(res, { status: 404, code: 'NOT_FOUND', message: 'Ruta no encontrada' });
};

export const errorHandler = (err, req, res, next) => {
    if (err instanceof ApiError) {
        return fail(res, {
            status: err.status,
            code: err.code,
            message: err.message,
            errors: err.errors ?? undefined,
        });
    }

    // Multer errors (FILE_TOO_LARGE, etc.)
    if (err instanceof multer.MulterError) {
        const code = err.code === 'LIMIT_FILE_SIZE' ? 'FILE_TOO_LARGE' : 'UPLOAD_ERROR';
        const message = err.code === 'LIMIT_FILE_SIZE'
            ? 'Archivo demasiado grande'
            : 'Error subiendo archivo';
        return fail(res, { status: 400, code, message });
    }

    // Errores normales (ej: tipo no permitido)
    if (err?.message?.includes('Tipo de archivo no permitido')) {
        return fail(res, { status: 400, code: 'INVALID_FILE_TYPE', message: err.message });
    }

    if (err?.name === 'SequelizeValidationError' || err?.name === 'SequelizeUniqueConstraintError') {
        const errors = err.errors?.map(e => ({ field: e.path, message: e.message })) ?? [];
        return fail(res, { status: 400, code: 'VALIDATION_ERROR', message: 'Datos inválidos', errors });
    }

    console.error('UNHANDLED_ERROR:', err);
    return fail(res, {
        status: 500,
        code: 'SERVER_ERROR',
        message: 'Error interno del servidor',
        errors: process.env.NODE_ENV === 'development' ? { detail: err?.message } : undefined,
    });
};
