import Usuario from '../../data/models/Usuario.js';
import Estudiante from '../../data/models/Estudiante.js';
import Session from '../../data/models/Session.js';
import { signAccessToken, signRefreshToken, hashToken, verifyJwt } from '../utils/tokens.js';

class UsuarioService {
  static async register(userData) {
    const t = await Usuario.sequelize.transaction();
    try {
      const bcrypt = await import('bcrypt');

      const salt = await bcrypt.genSalt(12);
      const contrasenaHash = await bcrypt.hash(userData.contrasena, salt);

      // 1) Crear usuario
      const user = await Usuario.create({
        correo_institucional: userData.correo_institucional.toLowerCase().trim(),
        contrasena_hash: contrasenaHash,
        nombre_completo: userData.nombre_completo,
        rol: userData.rol || 'estudiante',
        // Si ya migraron a guardar estos datos en Usuario (como en tu modelo Usuario.js),
        // puedes setearlos aquí también y eliminar Estudiante.
      }, { transaction: t });

      // 2) Si rol estudiante, crear Estudiante (si todavía existe y la usan)
      let estudianteData = null;
      if (user.rol === 'estudiante') {
        estudianteData = await Estudiante.create({
          id: user.id,
          cedula: userData.cedula,
          matricula: userData.matricula,
          telefono: userData.telefono,
          carrera: userData.carrera,
          semestre: userData.semestre
        }, { transaction: t });
      }

      // 3) Tokens
      const accessToken = signAccessToken({ userId: user.id, rol: user.rol });
      const refreshToken = signRefreshToken({ userId: user.id, rol: user.rol });

      // 4) Guardar refresh en Session (hash)
      await Session.create({
        userId: user.id,
        tokenHash: hashToken(refreshToken),
        isActive: true,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 días
      }, { transaction: t });

      await t.commit();

      const userResponse = user.toJSON();
      delete userResponse.contrasena_hash;

      const finalResponse = estudianteData
        ? { ...userResponse, ...estudianteData.toJSON() }
        : userResponse;

      return { user: finalResponse, accessToken, refreshToken };
    } catch (error) {
      await t.rollback();
      throw error;
    }
  }

  static async login(correo, contrasena) {
    const user = await Usuario.findOne({ where: { correo_institucional: correo } });
    if (!user) throw new Error('Credenciales inválidas');

    const bcrypt = await import('bcrypt');
    const isValid = await bcrypt.compare(contrasena, user.contrasena_hash);
    if (!isValid) throw new Error('Credenciales inválidas');

    let additionalData = {};
    if (user.rol === 'estudiante') {
      const estudiante = await Estudiante.findByPk(user.id);
      if (estudiante) additionalData = estudiante.toJSON();
    }

    const accessToken = signAccessToken({ userId: user.id, rol: user.rol });
    const refreshToken = signRefreshToken({ userId: user.id, rol: user.rol });

    await Session.create({
      userId: user.id,
      tokenHash: hashToken(refreshToken),
      isActive: true,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    });

    const userResponse = user.toJSON();
    delete userResponse.contrasena_hash;

    return { user: { ...userResponse, ...additionalData }, accessToken, refreshToken };
  }

  static async refresh(refreshToken) {
    const decoded = verifyJwt(refreshToken);
    const tokenHash = hashToken(refreshToken);

    const session = await Session.findOne({
      where: { userId: decoded.userId, tokenHash, isActive: true }
    });

    if (!session) throw new Error('INVALID_SESSION');

    // Rotación: invalidar refresh anterior
    await session.update({ isActive: false });

    const accessToken = signAccessToken({ userId: decoded.userId, rol: decoded.rol });
    const newRefreshToken = signRefreshToken({ userId: decoded.userId, rol: decoded.rol });

    await Session.create({
      userId: decoded.userId,
      tokenHash: hashToken(newRefreshToken),
      isActive: true,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    });

    return { accessToken, refreshToken: newRefreshToken };
  }

  static async logout(userId, refreshToken) {
    const tokenHash = hashToken(refreshToken);
    await Session.update(
      { isActive: false },
      { where: { userId, tokenHash } }
    );
  }
}

export default UsuarioService;
