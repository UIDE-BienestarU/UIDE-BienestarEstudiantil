export const requireRole = (roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.rol)) {
      return res.status(403).json({
        error: 'No autorizado',
        message: 'No tienes permisos suficientes',
      });
    }
    next();
  };
};