import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Usuario from './Usuario.js';

const Sugerencia = sequelize.define('Sugerencia', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  mensaje: { type: DataTypes.TEXT, allowNull: false },
  es_anonima: { type: DataTypes.BOOLEAN, defaultValue: false },
  leida: { type: DataTypes.BOOLEAN, defaultValue: false },
  estudiante_id: { type: DataTypes.INTEGER, allowNull: true },
}, {
  tableName: 'sugerencias',
  timestamps: true,
});

Sugerencia.belongsTo(Usuario, { foreignKey: 'estudiante_id', as: 'estudiante' });
Usuario.hasMany(Sugerencia, { foreignKey: 'estudiante_id' });

export default Sugerencia;