import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Solicitud from './Solicitud.js';

const Documento = sequelize.define('Documento', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  solicitud_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  nombre_documento: {
    type: DataTypes.STRING(100),
  },
  url_archivo: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  obligatorio: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  fecha_subida: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'Documento',
  timestamps: false,
});

Documento.belongsTo(Solicitud, { foreignKey: 'solicitud_id' });
Solicitud.hasMany(Documento, { foreignKey: 'solicitud_id' });

export default Documento;