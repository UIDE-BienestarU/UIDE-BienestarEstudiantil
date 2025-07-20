import Usuario from '../../data/models/Usuario.js';
import Estudiante from '../../data/models/Estudiante.js';
import Session from '../../data/models/Session.js';
import Solicitud from '../../data/models/Solicitud.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

class UsuarioService {
  static async register(userData) {
    const transaction = await Usuario.sequelize.transaction();
    try {
      const user = await Usuario.create({
        correo_institucional: userData.correo_institucional,
        contrasena_hash: userData.contrasena,
        nombre_completo: userData.nombre_completo,
        rol: userData.rol,
      }, { transaction });

      if (userData.rol === 'estudiante') {
        await Estudiante.create({
          id: user.id,
          cedula: userData.cedula,
          matricula: userData.matricula,
          telefono: userData.telefono,
          carrera: userData.carrera,
          semestre: userData.semestre,
        }, { transaction });
      }

      const token = jwt.sign({ userId: user.id, rol: user.rol }, process.env.JWT_SECRET, { expiresIn: '8h' });
      const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
      await Session.create({
        userId: user.id,
        tokenHash,
        isActive: true,
        expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000),
      }, { transaction });

      await transaction.commit();
      return { user, token };
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  static async login(correo_institucional, contrasena) {
    const user = await Usuario.findOne({ where: { correo_institucional } });
    if (!user || !(await user.validatePassword(contrasena))) {
      throw new Error('Credenciales inválidas');
    }

    const token = jwt.sign({ userId: user.id, rol: user.rol }, process.env.JWT_SECRET, { expiresIn: '8h' });
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    await Session.create({
      userId: user.id,
      tokenHash,
      isActive: true,
      expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000),
    });

    return { user, token };
  }

  static async logout(userId, token) {
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    await Session.update({ isActive: false }, { where: { userId, tokenHash } });
  }

  static async getEstudiantesConSolicitudes() {
    return await Usuario.findAll({
      where: { rol: 'estudiante' },
      include: [{
        model: Estudiante,
        include: [{
          model: Solicitud,
          attributes: [], 
          required: true, 
        }],
      }],
      attributes: ['id', 'correo_institucional', 'nombre_completo', 'rol'],
    });
  }
}

export default UsuarioService;