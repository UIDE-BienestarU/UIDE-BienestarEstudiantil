// src/business/services/UsuarioService.js
import Usuario from '../../data/models/Usuario.js';
import Estudiante from '../../data/models/Estudiante.js';
import Session from '../../data/models/Session.js';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

class UsuarioService {
  static async register(userData) {
    const t = await Usuario.sequelize.transaction();
    try {
      const salt = await import('bcrypt').then(bcrypt => bcrypt.genSalt(12));
      const contrasenaHash = await import('bcrypt').then(bcrypt => 
        bcrypt.hash(userData.contrasena, salt)
      );

      // 1. Crear el registro BASE en Usuario
      const user = await Usuario.create({
        correo_institucional: userData.correo_institucional.toLowerCase().trim(),
        contrasena_hash: contrasenaHash,
        nombre_completo: userData.nombre_completo,
        rol: userData.rol || 'estudiante'
      }, { transaction: t });

      // 2. Si el rol es estudiante, crear el registro en la tabla ESTUDIANTE
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

      // 3. Generar Token
      const token = jwt.sign(
        { userId: user.id, rol: user.rol },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

      // 4. Crear Sesión
      await Session.create({
        userId: user.id,
        tokenHash,
        isActive: true,
        expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000)
      }, { transaction: t });

      // 5. Confirmar todo en la base de datos
      await t.commit();

      // 6. Preparar respuesta (Combinar datos de Usuario y Estudiante)
      const userResponse = user.toJSON();
      delete userResponse.contrasena_hash;
      

      const finalResponse = estudianteData 
        ? { ...userResponse, ...estudianteData.toJSON() } 
        : userResponse;

      return { user: finalResponse, token };

    } catch (error) {
      await t.rollback(); 
      console.error('ERROR EN REGISTRO:', error);
      throw error;
    }
  }

  static async login(correo, contrasena) {
    // Buscar usuario base
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

    // Si quieres devolver los datos académicos en el login también:
    let additionalData = {};
    if (user.rol === 'estudiante') {
       const estudiante = await Estudiante.findByPk(user.id);
       if (estudiante) additionalData = estudiante.toJSON();
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

    // Combinamos respuesta
    const finalResponse = { ...userResponse, ...additionalData };

    return { user: finalResponse, token };
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