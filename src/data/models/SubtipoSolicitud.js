import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import TipoSolicitud from './TipoSolicitud.js';

const SubtipoSolicitud = sequelize.define('SubtipoSolicitud', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  tipo_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: TipoSolicitud, key: 'id' },
    onDelete: 'CASCADE',
  },
  nombre_sub: { type: DataTypes.STRING(100), allowNull: false },
}, {
  tableName: 'subtiposolicitud',
  timestamps: false,
  indexes: [{ unique: true, fields: ['tipo_id', 'nombre_sub'] }],
});

SubtipoSolicitud.belongsTo(TipoSolicitud, { foreignKey: 'tipo_id', as: 'tipo' });
TipoSolicitud.hasMany(SubtipoSolicitud, { foreignKey: 'tipo_id', as: 'subtipos' });

export default SubtipoSolicitud;