import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const TipoSolicitud = sequelize.define('TipoSolicitud', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  nombre: { type: DataTypes.STRING(100), allowNull: false, unique: true },
}, {
  tableName: 'tipos_solicitud',
  timestamps: false,
});

export default TipoSolicitud;