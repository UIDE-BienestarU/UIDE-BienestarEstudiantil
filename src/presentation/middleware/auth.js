import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Op } from 'sequelize';
import Session from '../../data/models/Session.js';

const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Acceso denegado',
        code: 'NO_TOKEN',
        message: 'Token de autenticación requerido',
      });
    }

    const token = authHeader.replace('Bearer ', '');
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
        message: 'Por favor inicia sesión nuevamente',
      });
    }

    // ← MEJORA CLAVE: solo pasamos lo necesario y con nombres claros
    req.user = {
      userId: decoded.userId,
      rol: decoded.rol,
    };

    next();
  } catch (error) {
    return res.status(401).json({
      error: 'Token inválido',
      code: 'INVALID_TOKEN',
      message: 'El token proporcionado no es válido o ha expirado',
    });
  }
};

const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.rol)) {
      return res.status(403).json({
        error: 'Acceso denegado',
        code: 'FORBIDDEN',
        message: `Requiere uno de los siguientes roles: ${roles.join(', ')}`,
      });
    }
    next();
  };
};

export { verifyToken, restrictTo };