import rateLimit from 'express-rate-limit';

const msg = (code, message) => ({ success: false, code, message });

export const generalLimiter = rateLimit({
    windowMs: 60 * 1000,
    limit: 120,
    standardHeaders: true,
    legacyHeaders: false,
    message: msg('RATE_LIMIT', 'Demasiadas solicitudes, intenta luego'),
});

export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 20,
    standardHeaders: true,
    legacyHeaders: false,
    message: msg('AUTH_RATE_LIMIT', 'Demasiados intentos, intenta luego'),
});

export const uploadLimiter = rateLimit({
    windowMs: 10 * 60 * 1000,
    limit: 60,
    standardHeaders: true,
    legacyHeaders: false,
    message: msg('UPLOAD_RATE_LIMIT', 'Demasiadas subidas, intenta luego'),
});
