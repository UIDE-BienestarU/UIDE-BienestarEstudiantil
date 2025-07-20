import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Op } from 'sequelize';
import Session from '../../data/models/Session.js';

const verifyToken = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({
        error: 'Token no proporcionado',
        code: 'NO_TOKEN',
        message: 'Debe proporcionar un token de autenticación',
        details: [],
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const session = await Session.findOne({
      where: {
        tokenHash,
        userId: decoded.userId,
        isActive: true,
        expiresAt: { [Op.gt]: new Date() },
      },
    });

    if (!session) {
      return res.status(401).json({
        error: 'Sesión inválida o expirada',
        code: 'INVALID_SESSION',
        message: 'La sesión no es válida o ha expirado',
        details: [],
      });
    }

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      error: 'Token inválido',
      code: 'INVALID_TOKEN',
      message: error.message,
      details: [],
    });
  }
};

const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.rol)) {
      return res.status(403).json({
        error: 'No autorizado',
        code: 'FORBIDDEN',
        message: 'No tienes permisos para realizar esta acción',
        details: [],
      });
    }
    next();
  };
};

export { verifyToken, restrictTo };