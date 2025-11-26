import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Usuario from './Usuario.js';

const Discapacidad = sequelize.define('Discapacidad', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  estudiante_id: { type: DataTypes.INTEGER, unique: true, allowNull: false },
  tipo: DataTypes.STRING(100),
  carnet_conadis: DataTypes.STRING(50),
  informe_medico: DataTypes.TEXT,
}, {
  tableName: 'discapacidades',
  timestamps: false,
});

Discapacidad.belongsTo(Usuario, { foreignKey: 'estudiante_id', as: 'estudiante' });
Usuario.hasOne(Discapacidad, { foreignKey: 'estudiante_id', as: 'discapacidad' });

export default Discapacidad;