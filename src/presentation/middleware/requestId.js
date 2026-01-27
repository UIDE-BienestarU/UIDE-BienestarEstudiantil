import { randomUUID } from 'crypto';

export const requestId = (req, res, next) => {
    const id = req.header('X-Request-Id') || randomUUID();
    req.requestId = id;
    res.setHeader('X-Request-Id', id);
    next();
};
