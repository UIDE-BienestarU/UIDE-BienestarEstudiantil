// src/data/models/Estudiante.js
import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const Estudiante = sequelize.define('Estudiante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: false, 
    references: {
      model: 'usuario', 
      key: 'id'
    }
  },

  cedula: {
    type: DataTypes.STRING(10),
    allowNull: false, 
    unique: true,
    validate: {
      len: [10, 10],
      isNumeric: true
    }
  },

  matricula: {
    type: DataTypes.STRING(20),
    allowNull: false,
    unique: true,
    validate: {
      is: /^U\d{6,8}$/i 
    }
  },

  telefono: {
    type: DataTypes.STRING(15),
    allowNull: false,
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
    allowNull: false
  },

  semestre: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 10
    }
  }

}, {
  tableName: 'Estudiante',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['cedula']
    },
    {
      unique: true,
      fields: ['matricula']
    }
  ]
});

export default Estudiante;