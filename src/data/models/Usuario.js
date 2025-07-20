import { DataTypes } from 'sequelize';
import bcrypt from 'bcrypt';
import sequelize from '../database.js';
import Session from './Session.js'; 

const Usuario = sequelize.define('Usuario', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  correo_institucional: {
    type: DataTypes.STRING(100),
    unique: true,
    allowNull: false,
    validate: {
      isEmail: true,
      is: /^[a-z][a-z]?[a-z]+@uide\.edu\.ec$/i,
      isInstitutional(value) {
        if (!value.endsWith('@uide.edu.ec')) {
          throw new Error('El correo debe ser institucional (@uide.edu.ec)');
        }
      },
    },
  },
  contrasena_hash: {
    type: DataTypes.STRING(64),
    allowNull: false,
  },
  nombre_completo: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  rol: {
    type: DataTypes.ENUM('estudiante', 'administrador'),
    allowNull: false,
  },
}, {
  tableName: 'Usuario',
  timestamps: false,
  hooks: {
    beforeCreate: async (user) => {
      user.contrasena_hash = await bcrypt.hash(user.contrasena_hash, 12);
      await Session.destroy({ where: { userId: user.id, isActive: false } });
    },
    beforeUpdate: async (user) => {
      if (user.changed('contrasena_hash')) {
        user.contrasena_hash = await bcrypt.hash(user.contrasena_hash, 12);
      }
    },
  },
});

Usuario.prototype.getFullName = function () {
  return this.nombre_completo;
};

Usuario.prototype.getDisplayRole = function () {
  return this.rol === 'estudiante' ? 'Estudiante' : 'Administrador';
};

Usuario.prototype.validatePassword = async function (password) {
  return await bcrypt.compare(password, this.contrasena_hash);
};

Usuario.addScope('public', {
  attributes: ['id', 'correo_institucional', 'nombre_completo', 'rol'],
});

export default Usuario;