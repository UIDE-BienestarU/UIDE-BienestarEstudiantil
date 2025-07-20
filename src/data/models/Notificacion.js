import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Solicitud from './Solicitud.js';

const Notificacion = sequelize.define('Notificacion', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  solicitud_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  mensaje: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  tipo: {
    type: DataTypes.ENUM('Alerta', 'Recordatorio', 'Rechazo', 'Actualización'),
    allowNull: false,
  },
  fecha_envio: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  leido: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'Notificacion',
  timestamps: false,
});

Notificacion.belongsTo(Solicitud, { foreignKey: 'solicitud_id' });
Solicitud.hasMany(Notificacion, { foreignKey: 'solicitud_id' });

export default Notificacion;