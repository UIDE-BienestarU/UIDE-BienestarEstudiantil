import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Estudiante from './Estudiante.js';

const Discapacidad = sequelize.define('Discapacidad', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  estudiante_id: {
    type: DataTypes.INTEGER,
    unique: true,
  },
  tipo: {
    type: DataTypes.STRING(100),
  },
  carnet_conadis: {
    type: DataTypes.STRING(50),
  },
  informe_medico: {
    type: DataTypes.TEXT,
  },
}, {
  tableName: 'Discapacidad',
  timestamps: false,
});

Discapacidad.belongsTo(Estudiante, { foreignKey: 'estudiante_id' });
Estudiante.hasOne(Discapacidad, { foreignKey: 'estudiante_id' });

export default Discapacidad;