import IdempotencyKey from '../../data/models/IdempotencyKey.js';
import { ok } from './apiResponse.js';
import { ApiError } from './errorHandler.js';

export const idempotency = (routeName) => async (req, res, next) => {
    const key = req.header('Idempotency-Key');
    if (!key) return next(); // si no mandan, normal

    if (!req.user?.userId) throw new ApiError(401, 'NO_AUTH', 'Auth requerida');

    const existing = await IdempotencyKey.findOne({
        where: { user_id: req.user.userId, idem_key: key, route: routeName }
    });

    if (existing) {
        // replay
        const body = JSON.parse(existing.response_body);
        return res.status(existing.response_code).json(body);
    }

    // hook para capturar respuesta
    const originalJson = res.json.bind(res);
    res.json = async (body) => {
        try {
            await IdempotencyKey.create({
                user_id: req.user.userId,
                idem_key: key,
                route: routeName,
                response_code: res.statusCode,
                response_body: JSON.stringify(body),
            });
        } catch (e) {
            // si hay carrera por el unique constraint, lo ignoramos
        }
        return originalJson(body);
    };

    next();
};
