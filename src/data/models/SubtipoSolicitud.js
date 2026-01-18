import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const SubtipoSolicitud = sequelize.define('SubtipoSolicitud', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  tipo_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'TipoSolicitud', key: 'id' },  // ← string aquí
    onDelete: 'CASCADE',
  },
  nombre_sub: { type: DataTypes.STRING(100), allowNull: false },
}, {
  tableName: 'SubtipoSolicitud',
  timestamps: false,
  indexes: [{ unique: true, fields: ['tipo_id', 'nombre_sub'] }],
});


export default SubtipoSolicitud;