// src/data/models/Usuario.js
import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const Usuario = sequelize.define('Usuario', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },

  correo_institucional: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
      is: /^[a-zA-Z0-9._%+-]+@uide\.edu\.ec$/i, 
    }
  },

  // CONTRASEÑA HASH — Se llena desde el Service
  contrasena_hash: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },

  nombre_completo: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },

  rol: {
    type: DataTypes.ENUM('estudiante', 'administrador', 'bienestar'),
    allowNull: false,
    defaultValue: 'estudiante'
  },

  cedula: {
    type: DataTypes.STRING(10),
    allowNull: true,
    validate: {
      len: [10, 10],
      isNumeric: true
    }
  },

  matricula: {
    type: DataTypes.STRING(20),
    allowNull: true,
    validate: {
      is: /^U\d{6,8}$/i
    }
  },

  telefono: {
    type: DataTypes.STRING(15),
    allowNull: true,
    validate: {
      is: /^\d{9,10}$/
    }
  },

  carrera: {
    type: DataTypes.ENUM(
      'Ingeniería en Tecnologías de la Información',
      'Arquitectura',
      'Psicología',
      'Marketing',
      'Derecho',
      'Business'
    ),
    allowNull: true
  },

  semestre: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: {
      min: 1,
      max: 10
    }
  },
  fcm_token: {
    type: DataTypes.STRING,
    allowNull: true,
  },

}, {
  tableName: 'usuario',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['correo_institucional']
    }
  ]
});

export default Usuario;
