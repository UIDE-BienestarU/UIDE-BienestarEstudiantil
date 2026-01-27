import morgan from 'morgan';

export const logger = morgan((tokens, req, res) => [
    tokens.method(req, res),
    tokens.url(req, res),
    tokens.status(req, res),
    `${tokens['response-time'](req, res)}ms`,
    `rid=${req.requestId || '-'}`,
    `ip=${req.ip}`,
].join(' '));
