import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import TipoSolicitud from './TipoSolicitud.js';

const SubtipoSolicitud = sequelize.define('SubtipoSolicitud', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  tipo_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  nombre_sub: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
}, {
  tableName: 'SubtipoSolicitud',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['tipo_id', 'nombre_sub'],
    },
  ],
});

SubtipoSolicitud.belongsTo(TipoSolicitud, { foreignKey: 'tipo_id' });
TipoSolicitud.hasMany(SubtipoSolicitud, { foreignKey: 'tipo_id' });

export default SubtipoSolicitud;