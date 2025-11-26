// src/business/services/UsuarioService.js
import Usuario from '../../data/models/Usuario.js';
import Session from '../../data/models/Session.js';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

class UsuarioService {
  static async register(userData) {
    const t = await Usuario.sequelize.transaction();
    try {
      // EL SECRETO ESTÁ AQUÍ: PASAMOS LA CONTRASEÑA COMO "contrasena_hash" DIRECTO
      // Porque tu modelo NO tiene hook que la hashee automáticamente (o no está funcionando)
      // Entonces lo hacemos NOSOTROS aquí, manualmente, y listo.
      const salt = await import('bcrypt').then(bcrypt => bcrypt.genSalt(12));
      const contrasenaHash = await import('bcrypt').then(bcrypt => 
        bcrypt.hash(userData.contrasena, salt)
      );

      const user = await Usuario.create({
        correo_institucional: userData.correo_institucional.toLowerCase().trim(),
        contrasena_hash: contrasenaHash,           // DIRECTO EL HASH
        nombre_completo: userData.nombre_completo,
        rol: userData.rol || 'estudiante',
        cedula: userData.cedula || null,
        matricula: userData.matricula || null,
        telefono: userData.telefono || null,
        carrera: userData.carrera || null,
        semestre: userData.semestre || null,
      }, { transaction: t });

      const token = jwt.sign(
        { userId: user.id, rol: user.rol },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

      await Session.create({
        userId: user.id,
        tokenHash,
        isActive: true,
        expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000)
      }, { transaction: t });

      await t.commit();

      const userResponse = user.toJSON();
      delete userResponse.contrasena_hash;

      return { user: userResponse, token };

    } catch (error) {
      await t.rollback();
      console.error('ERROR EN REGISTRO:', error);
      throw error;
    }
  }

  static async login(correo, contrasena) {
    const user = await Usuario.findOne({
      where: { correo_institucional: correo }
    });

    if (!user) {
      throw new Error('Credenciales inválidas');
    }

    const bcrypt = await import('bcrypt');
    const isValid = await bcrypt.compare(contrasena, user.contrasena_hash);

    if (!isValid) {
      throw new Error('Credenciales inválidas');
    }

    const token = jwt.sign(
      { userId: user.id, rol: user.rol },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

    await Session.create({
      userId: user.id,
      tokenHash,
      isActive: true,
      expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000)
    });

    const userResponse = user.toJSON();
    delete userResponse.contrasena_hash;

    return { user: userResponse, token };
  }

  static async logout(userId, token) {
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    await Session.update(
      { isActive: false },
      { where: { userId, tokenHash } }
    );
  }
}

export default UsuarioService;