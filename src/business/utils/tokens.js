// src/business/utils/tokens.js
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

export const signAccessToken = (payload) =>
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_ACCESS_EXPIRE || '15m' });

export const signRefreshToken = (payload) =>
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d' });

export const verifyJwt = (token) => jwt.verify(token, process.env.JWT_SECRET);

export const hashToken = (token) =>
    crypto.createHash('sha256').update(token).digest('hex');

