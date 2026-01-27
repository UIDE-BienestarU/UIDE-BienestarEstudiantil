// src/presentation/middleware/auth.js
import { verifyJwt } from '../../business/utils/tokens.js';

const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        code: 'NO_TOKEN',
        message: 'Token de autenticación requerido',
      });
    }

    const token = authHeader.replace('Bearer ', '');
    const decoded = verifyJwt(token);

    req.user = { userId: decoded.userId, rol: decoded.rol };
    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      code: 'INVALID_TOKEN',
      message: 'Token inválido o expirado',
    });
  }
};

const restrictTo = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.rol)) {
    return res.status(403).json({
      success: false,
      code: 'FORBIDDEN',
      message: `Requiere uno de los siguientes roles: ${roles.join(', ')}`,
    });
  }
  next();
};

export { verifyToken, restrictTo };
