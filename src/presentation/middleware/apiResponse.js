// src/presentation/middleware/apiResponse.js
export const ok = (res, { data = null, message = 'OK', code = 'OK', meta = null, status = 200 } = {}) => {
    const payload = { success: true, message, code, data };
    if (meta) payload.meta = meta;
    return res.status(status).json(payload);
};

export const fail = (res, { status = 400, message = 'Error', code = 'ERROR', errors = null } = {}) => {
    const payload = { success: false, message, code };
    if (errors) payload.errors = errors;
    return res.status(status).json(payload);
};
